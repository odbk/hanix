#!/usr/bin/env python3

import importlib.util
import sys
import unittest
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).with_name("ianix.py")
SPEC = importlib.util.spec_from_file_location("ianix", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
ianix = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = ianix
SPEC.loader.exec_module(ianix)


PROFILE_CASES = {
    "subfinder_domain": ("enumera subdominios de example.com", ("subfinder", "-d", "example.com", "-silent")),
    "amass_passive": ("haz recon pasivo de example.com", ("amass", "enum", "-passive", "-d", "example.com")),
    "whatweb_url": ("tecnologías de https://example.com", ("whatweb", "--color=always", "https://example.com")),
    "nmap_ping": ("descubre hosts en 192.0.2.0/28", ("nmap", "-sn", "192.0.2.0/28")),
    "smbmap_host": ("enumera SMB de 192.0.2.10", ("smbmap", "-H", "192.0.2.10")),
    "ldapsearch_root": (
        "enumera LDAP de 192.0.2.10",
        ("ldapsearch", "-x", "-H", "ldap://192.0.2.10", "-s", "base", "-b", "", "namingContexts"),
    ),
    "snmpwalk_host": (
        "consulta SNMP de 192.0.2.10 con la comunidad public",
        ("snmpwalk", "-v", "2c", "-c", "public", "192.0.2.10"),
    ),
    "apktool_decode": ("analiza la APK app.apk", ("apktool", "d", "app.apk", "-o", "app-apktool")),
    "checksec_file": ("protecciones de ./reto", ("checksec", "file", "./reto")),
    "tshark_pcap": ("analiza trafico.pcap", ("tshark", "-r", "trafico.pcap")),
    "yara_baseline": (
        "busca indicadores YARA en ./muestra",
        ("yara", "-r", ianix.DEFAULT_YARA_RULES, "./muestra"),
    ),
}


class IAnixTests(unittest.TestCase):
    def test_fuzz_marker_is_added_and_normalized(self):
        self.assertEqual(
            ianix.canonical_fuzz_url("https://example.test/admin"),
            "https://example.test/admin/FUZZ",
        )

    def test_query_fuzz_only_offers_exact_substitution_tools(self):
        choices = ianix.build_web_fuzz_choices("https://example.test/?id=FUZZ", "/tmp/words")
        self.assertEqual([choice.argv[0] for choice in choices], ["ffuf", "wfuzz"])

    def test_verified_profiles_build_exact_argv_and_explanations(self):
        for profile, (request, expected) in PROFILE_CASES.items():
            with self.subTest(profile=profile):
                choice = ianix.profile_choice(profile, request)
                self.assertEqual(choice.argv, expected)
                self.assertEqual(list(choice.argv), [item.value for item in choice.arguments])

    def test_port_request_without_literal_nmap_reaches_planner(self):
        self.assertIsNone(ianix.classify_curated("escanea servicios TCP de 192.0.2.10"))
        self.assertEqual(
            ianix.classify_curated("usa nmap para 192.0.2.10"),
            ("port_scan", "192.0.2.10"),
        )

    def test_plan_only_accepts_known_profiles_and_two_to_four_options(self):
        plan = ianix.parse_plan({
            "action": "command",
            "task": "subdominios",
            "message": "Propongo alternativas pasivas.",
            "profiles": ["subfinder_domain", "amass_passive"],
            "generic_tools": [],
            "risk": "standard",
        })
        self.assertEqual(plan.task, "subdominios")
        self.assertEqual(plan.profiles, ("subfinder_domain", "amass_passive"))
        self.assertEqual(plan.generic_tools, ())
        with self.assertRaises(ValueError):
            ianix.parse_plan({
                "action": "command",
                "task": "x",
                "message": "Plan inválido.",
                "profiles": ["inventado", "amass_passive"],
                "generic_tools": [],
                "risk": "standard",
            })

    def test_non_command_plan_discards_model_tool_filler(self):
        result = {
            "action": "clarify",
            "task": "objetivo desconocido",
            "message": "Necesito el host que quieres revisar.",
            "profiles": [],
            "generic_tools": [],
            "risk": "standard",
        }
        self.assertEqual(ianix.parse_plan(result).action, "clarify")
        result["profiles"] = ["nmap_services"]
        plan = ianix.parse_plan(result)
        self.assertEqual(plan.action, "clarify")
        self.assertEqual(plan.profiles, ())
        self.assertEqual(plan.generic_tools, ())

    def test_profile_named_as_task_beats_model_filler_and_model_risk(self):
        plan = ianix.RequestPlan(
            "command", "hosts_add", "Se ha añadido la asociación.",
            (), ("httpx", "ffuf"), "elevated",
        )
        with mock.patch("ianix.shutil.which", return_value="/bin/tool"):
            outcome = ianix.build_command_outcome(
                "quiero que al escribir prueba.htb se use 20.20.20.20", plan,
            )
        self.assertEqual(len(outcome.choices), 1)
        self.assertEqual(outcome.choices[0].argv[1], "sed")
        self.assertEqual(outcome.choices[0].risk, "standard")
        self.assertIn("todavía no se ha ejecutado nada", outcome.message)

    def test_attached_short_flags_are_checked_by_base_flag(self):
        help_text = "Usage: nmap [-T<0-5>] [-p <ports>]"
        ianix.validate_help_flags(("nmap", "-T5", "-p80,443", "127.0.0.1"), help_text)

    def test_all_acceptance_cases_have_a_deterministic_safe_route(self):
        cases = __import__("json").loads(Path(__file__).with_name("acceptance_cases.json").read_text())

        def fake_which(tool):
            return None if tool == "superscan9000" else f"/bin/{tool}"

        with mock.patch("ianix.shutil.which", side_effect=fake_which):
            with mock.patch.object(ianix, "chat_json", side_effect=AssertionError("no debía consultar el modelo")):
                for case in cases:
                    with self.subTest(case=case["id"]):
                        outcome = ianix._resolve_classic(case["prompt"])
                        self.assertEqual(outcome.action, case["expected"])
                        if outcome.action == "command":
                            self.assertGreaterEqual(len(outcome.choices), 2)
                            self.assertLessEqual(len(outcome.choices), 4)
                        if case.get("risk") and outcome.choices:
                            self.assertEqual({choice.risk for choice in outcome.choices}, {case["risk"]})

    def test_safety_precheck_rejects_shell_injection(self):
        injected = ianix.safety_precheck("escanea 10.10.10.10; rm -rf /")
        self.assertIsNotNone(injected)
        self.assertEqual(injected.action, "decline")

    def test_safety_precheck_does_not_moralize_about_authorization(self):
        # HaNiX es un entorno de pentest: no se rechaza por autorización.
        self.assertIsNone(ianix.safety_precheck("escanea una empresa que no es mía"))

    def test_short_hostname_is_accepted_for_hosts_entry(self):
        self.assertEqual(
            ianix.extract_hosts_entry("mete kali como 10.10.10.5 en el hosts"),
            ("10.10.10.5", "kali"),
        )
        self.assertEqual(
            ianix.extract_hosts_entry("añade 10.10.10.5 academy.htb al hosts"),
            ("10.10.10.5", "academy.htb"),
        )

    def test_scan_of_own_computer_is_a_local_authorized_target(self):
        with mock.patch.object(ianix, "chat_json", side_effect=AssertionError("no debía consultar el modelo")):
            for request in ("escanea mi pc", "escanea este equipo", "scan my computer"):
                with self.subTest(request=request):
                    outcome = ianix._resolve_classic(request)
                    self.assertEqual(outcome.action, "command")
                    self.assertEqual(outcome.task, "escaneo local de puertos")
                    self.assertEqual(len(outcome.choices), 2)
                    self.assertEqual({choice.argv[-1] for choice in outcome.choices}, {"127.0.0.1"})

    def test_hosts_entry_is_validated_and_does_not_use_a_shell(self):
        with mock.patch.object(ianix, "chat_json", return_value={"intent": "hosts_add"}) as classifier:
            for request in (
                "agrega 10.10.222.22 prueba.htb al host",
                "mete prueba.htb al host con ip 10.10.222.22",
                "haz que prueba.htb resuelva localmente a 10.10.222.22",
                "acomoda 10.10.222.22 y prueba.htb en el fichero que usa el equipo para nombres locales",
            ):
                with self.subTest(request=request):
                    outcome = ianix._resolve_classic(request)
                    self.assertEqual(outcome.action, "command")
                    self.assertEqual(outcome.task, "entrada local en /etc/hosts")
                    self.assertEqual(len(outcome.choices), 1)
                    self.assertEqual(
                        outcome.choices[0].argv,
                        ("sudo", "sed", "-i", "-e", "$a10.10.222.22 prueba.htb", "/etc/hosts"),
                    )
                    self.assertEqual(outcome.choices[0].risk, "standard")
        self.assertEqual(classifier.call_count, 4)

    def test_listing_hosts_is_a_read_only_profile_without_model(self):
        with mock.patch("ianix.shutil.which", return_value="/bin/getent"):
            with mock.patch.object(ianix, "chat_json", side_effect=AssertionError("no debía consultar el modelo")):
                for request in ("listame los dominios del hosts", "listame los dominios del host", "muéstrame el contenido de /etc/hosts"):
                    with self.subTest(request=request):
                        outcome = ianix._resolve_classic(request)
                        self.assertEqual(outcome.action, "command")
                        self.assertEqual(outcome.choices[0].argv, ("getent", "hosts"))

    def test_hosts_semantic_classifier_distinguishes_a_read_only_question(self):
        request = "comprueba si prueba.htb ya apunta a 10.10.222.22"
        with mock.patch.object(ianix, "chat_json", return_value={"intent": "other"}):
            self.assertIsNone(ianix.semantic_precheck(request))

    def test_one_selected_profile_expands_to_verified_family(self):
        self.assertEqual(
            ianix.expand_profiles(["openssl_tls"]),
            ["openssl_tls", "testssl_tls", "sslscan_tls", "nmap_tls"],
        )
        self.assertEqual(
            ianix.expand_profiles(["ldapsearch_root"]),
            ["ldapsearch_root", "nmap_ldap"],
        )

    def test_grounded_flags_must_exist_in_local_help(self):
        help_text = "Usage: tool [--target VALUE] [-v]"
        ianix.validate_help_flags(("tool", "--target", "x", "-v"), help_text)
        with self.assertRaisesRegex(ValueError, "--inventado"):
            ianix.validate_help_flags(("tool", "--inventado", "x"), help_text)

    def test_generated_command_rejects_shell_composition(self):
        with mock.patch("ianix.shutil.which", return_value="/bin/tool"):
            for argv in (
                ["bash", "-c", "nmap 127.0.0.1"],
                ["nmap", "127.0.0.1", "|", "tee", "out"],
                ["nmap", "$(id)"],
                ["/tmp/nmap", "127.0.0.1"],
            ):
                with self.subTest(argv=argv), self.assertRaises(ValueError):
                    ianix.validate_generated_argv(argv)

    def test_read_only_filter_pipe_is_allowed_but_writers_are_not(self):
        with mock.patch("ianix.shutil.which", return_value="/bin/tool"):
            argv = ianix.validate_generated_argv(["whois", "google.com", "|", "grep", "-i", "registrar"])
            self.assertEqual(ianix.pipeline_segments(argv), [["whois", "google.com"], ["grep", "-i", "registrar"]])
            for bad in (
                ["nmap", "127.0.0.1", "|", "tee", "out"],      # tee no es filtro de solo lectura
                ["cat", "x", "|", "awk", "{print}"],            # awk excluido
                ["whois", "x", "|", "grep", "a", ">", "f.txt"], # redirección
            ):
                with self.subTest(bad=bad), self.assertRaises(ValueError):
                    ianix.validate_generated_argv(bad)

    def test_empty_ldap_base_survives_argv_validation(self):
        with mock.patch("ianix.shutil.which", return_value="/bin/ldapsearch"):
            argv = list(PROFILE_CASES["ldapsearch_root"][1])
            self.assertEqual(ianix.validate_generated_argv(argv)[7], "")

    def test_server_is_cpu_only_and_bound_to_loopback(self):
        args = ianix.model_server_arguments("llama-server", Path("/tmp/model.gguf"))
        self.assertEqual(args[args.index("--n-gpu-layers") + 1], "0")
        self.assertEqual(args[args.index("--host") + 1], "127.0.0.1")
        self.assertIn("--sleep-idle-seconds", args)

    def test_package_and_url_injection_are_rejected(self):
        for package in ("--impure", "ripgrep;id", "$(id)"):
            with self.subTest(package=package), self.assertRaises(ValueError):
                ianix.validate_package_name(package)
        with self.assertRaises(ValueError):
            ianix.validate_url("https://user:secret@example.test/FUZZ")

    def test_dry_run_never_calls_execute(self):
        with mock.patch.object(ianix, "classify_curated", return_value=("port_scan", "127.0.0.1")):
            with mock.patch.object(ianix, "execute_choice") as execute:
                status = ianix.main(["--solo-mostrar", "--opcion", "B", "scan"])
        self.assertEqual(status, 0)
        execute.assert_not_called()

    def test_destructive_command_confirms_before_running(self):
        choice = ianix.explained_choice(
            "destructivo", "prueba", ("tool", "arg"), ("ejecutable", "argumento"),
            risk="destructive",
        )
        with mock.patch("ianix.shutil.which", return_value="/bin/tool"):
            with mock.patch("builtins.input", return_value="n"):
                with mock.patch("ianix.subprocess.run") as run:
                    self.assertEqual(ianix.execute_choice(choice), 0)
                    run.assert_not_called()
            with mock.patch("builtins.input", return_value="s"):
                with mock.patch("ianix.subprocess.run") as run:
                    run.return_value.returncode = 0
                    self.assertEqual(ianix.execute_choice(choice), 0)
                    run.assert_called_once_with(["/bin/tool", "arg"], check=False)

    def test_standard_command_runs_without_typing_anything(self):
        choice = ianix.explained_choice(
            "normal", "prueba", ("tool", "arg"), ("ejecutable", "argumento"),
        )
        with mock.patch("ianix.shutil.which", return_value="/bin/tool"):
            with mock.patch("builtins.input", side_effect=AssertionError("no debe pedir confirmación")):
                with mock.patch("ianix.subprocess.run") as run:
                    run.return_value.returncode = 0
                    self.assertEqual(ianix.execute_choice(choice), 0)
                    run.assert_called_once_with(["/bin/tool", "arg"], check=False)

    def test_injection_precheck_runs_before_curated_routes(self):
        with mock.patch.object(ianix, "classify_curated") as classify:
            with mock.patch.object(ianix, "execute_choice") as execute:
                status = ianix.main(["--solo-mostrar", "fuzzea https://example.test/FUZZ; rm -rf /"])
        self.assertEqual(status, 0)
        classify.assert_not_called()
        execute.assert_not_called()


if __name__ == "__main__":
    unittest.main()
