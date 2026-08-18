{ pkgs, unstablePkgs, ... }:

let
  ianixModel = pkgs.fetchurl {
    name = "qwen3-4b-instruct-2507-q4_k_m.gguf";
    url = "https://huggingface.co/lmstudio-community/Qwen3-4B-Instruct-2507-GGUF/resolve/4edb920b6f14e3b9284d4502a6485103d72cde05/Qwen3-4B-Instruct-2507-Q4_K_M.gguf";
    hash = "sha256-jNtXy7iA0xNzapvE49PSSF8UW14ZzzN4N0bnU+gmQfw=";
  };

  ianix = pkgs.writeShellApplication {
    name = "ianix";

    runtimeInputs = [
      pkgs.python3
      unstablePkgs.llama-cpp
    ];

    text = ''
      export IANIX_MODEL="''${IANIX_MODEL:-${ianixModel}}"
      export IANIX_WORDLIST="''${IANIX_WORDLIST:-/etc/hanix-data/wordlists/seclists/Discovery/Web-Content/raft-small-words.txt}"
      export IANIX_ROCKYOU="''${IANIX_ROCKYOU:-/etc/hanix-data/wordlists/rockyou.txt}"
      export IANIX_NUCLEI_TEMPLATES="''${IANIX_NUCLEI_TEMPLATES:-/etc/hanix-data/nuclei-templates}"
      export IANIX_YARA_RULES="''${IANIX_YARA_RULES:-/etc/hanix-data/yara/hanix-baseline.yar}"
      exec ${pkgs.python3}/bin/python3 ${./ianix}/ianix.py "$@"
    '';
  };

  ianixTerminalSession = pkgs.writeShellApplication {
    name = "ianix-terminal-session";
    runtimeInputs = [ ianix ];
    text = ''
      set +e
      ianix
      status=$?
      printf '\nPulsa Enter para cerrar IAnix...'
      read -r _
      exit "$status"
    '';
  };

  ianixLauncher = pkgs.writeShellApplication {
    name = "ianix-launcher";
    runtimeInputs = [ pkgs.kitty ianixTerminalSession ];
    text = ''
      exec kitty --class IAnix --title IAnix ianix-terminal-session
    '';
  };

  ianixDesktop = pkgs.makeDesktopItem {
    name = "ianix";
    desktopName = "IAnix";
    genericName = "Asistente de comandos de HaNiX";
    comment = "Prepara y explica comandos antes de ejecutarlos";
    exec = "ianix-launcher";
    icon = "${./images/boot.png}";
    categories = [ "System" "Utility" ];
    keywords = [ "HaNiX" "seguridad" "comandos" "IA" ];
    terminal = false;
  };
in
{
  # Runtime y modelo quedan dentro de la closure: IAnix funciona offline desde
  # el primer arranque y no necesita Ollama ni una caché mutable del usuario.
  environment.systemPackages = [ ianix ianixLauncher ianixDesktop ];

  # Rutas estables y legibles para los comandos y para uso manual. Los datos
  # siguen viviendo de forma inmutable en el Nix store.
  environment.etc."hanix-data/wordlists/seclists".source =
    "${pkgs.seclists}/share/wordlists/seclists";
  environment.etc."hanix-data/wordlists/rockyou.txt".source =
    "${pkgs.rockyou}/share/wordlists/rockyou.txt";
  environment.etc."hanix-data/yara/hanix-baseline.yar".source =
    ./ianix/yara/hanix-baseline.yar;
  environment.etc."hanix-data/models/Qwen3-4B-Instruct-2507-Q4_K_M.gguf".source =
    ianixModel;
}
