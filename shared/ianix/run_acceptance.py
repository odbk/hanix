#!/usr/bin/env python3
"""Ejecuta las 100 peticiones de aceptación sin ejecutar comandos sugeridos."""

from __future__ import annotations

import importlib.util
import json
import shutil
import sys
import time
from pathlib import Path


BASE = Path(__file__).resolve().parent
MODULE_PATH = BASE / "ianix.py"
CASES_PATH = BASE / "acceptance_cases.json"
RESULTS_PATH = Path("/tmp/ianix-acceptance-100-v2.json")

SPEC = importlib.util.spec_from_file_location("ianix", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
ianix = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = ianix
SPEC.loader.exec_module(ianix)


def dispatch(prompt: str):
    precheck = ianix.safety_precheck(prompt)
    if precheck is not None:
        return precheck
    route = ianix.classify_curated(prompt)
    if route is not None:
        task, target, choices = ianix.choices_for_curated_route(route)
        return ianix.RequestOutcome("command", task, f"Objetivo: {target}", tuple(choices))
    return ianix.resolve_request(prompt)


def audit_choice(choice):
    issues = []
    if len(choice.argv) != len(choice.arguments):
        issues.append("faltan explicaciones por argumento")
    if list(choice.argv) != [argument.value for argument in choice.arguments]:
        issues.append("las explicaciones no corresponden exactamente con argv")
    try:
        ianix.validate_generated_argv(list(choice.argv))
    except (ValueError, ianix.MissingToolError) as error:
        issues.append(str(error))
    tool_index = 1 if choice.argv and choice.argv[0] == "sudo" else 0
    installed = bool(choice.argv and len(choice.argv) > tool_index and shutil.which(choice.argv[tool_index]))
    return issues, installed


def main() -> int:
    cases = json.loads(CASES_PATH.read_text(encoding="utf-8"))
    results = []
    started = time.monotonic()
    for case in cases:
        case_started = time.monotonic()
        record = {**case, "actual": "error", "message": "", "options": [], "issues": []}
        try:
            outcome = dispatch(case["prompt"])
            record["actual"] = outcome.action
            record["message"] = outcome.message
            record["warnings"] = list(outcome.warnings)
            if outcome.action != case["expected"]:
                record["issues"].append(f"acción esperada {case['expected']}, recibida {outcome.action}")
            normalized_message = ianix.normalize(outcome.message)
            for required in case.get("must_include", []):
                if ianix.normalize(required) not in normalized_message:
                    record["issues"].append(f"el mensaje no contiene la garantía esperada: {required}")
            if outcome.action == "command" and not 2 <= len(outcome.choices) <= 4:
                record["issues"].append(f"se esperaban 2-4 opciones y llegaron {len(outcome.choices)}")
            if outcome.action == "first_step" and outcome.choices and not 2 <= len(outcome.choices) <= 4:
                record["issues"].append(f"el primer paso ejecutable debe ofrecer 2-4 opciones y llegaron {len(outcome.choices)}")
            if outcome.action not in {"command", "first_step"} and outcome.choices:
                record["issues"].append("una respuesta no ejecutable contiene comandos")
            for choice in outcome.choices:
                choice_issues, installed = audit_choice(choice)
                record["issues"].extend(f"{choice.title}: {issue}" for issue in choice_issues)
                record["options"].append({
                    "title": choice.title,
                    "command": choice.command,
                    "source": choice.source,
                    "risk": choice.risk,
                    "installed": installed,
                    "arguments": [
                        {"value": argument.value, "explanation": argument.explanation}
                        for argument in choice.arguments
                    ],
                })
            required_risk = case.get("risk")
            if required_risk and outcome.choices:
                received = sorted({choice.risk for choice in outcome.choices})
                if received != [required_risk]:
                    record["issues"].append(f"riesgo esperado {required_risk}, recibido {received}")
        except Exception as error:  # La suite debe continuar para mostrar los 100 casos.
            record["message"] = f"{type(error).__name__}: {error}"
            record["issues"].append(record["message"])
        record["latency_seconds"] = round(time.monotonic() - case_started, 2)
        record["accepted"] = not record["issues"]
        results.append(record)
        print(
            f"{case['id']:03d}/100 {'OK' if record['accepted'] else 'FALLO'} "
            f"{record['actual']:<10} {record['latency_seconds']:>6.2f}s "
            f"opciones={len(record['options'])}",
            flush=True,
        )

    report = {
        "dry_run": True,
        "commands_executed": 0,
        "elapsed_seconds": round(time.monotonic() - started, 2),
        "accepted": sum(result["accepted"] for result in results),
        "total": len(results),
        "results": results,
    }
    RESULTS_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"RESULTADOS={RESULTS_PATH}", flush=True)
    print(f"ACEPTADAS={report['accepted']}/{report['total']}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
