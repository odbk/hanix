{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [

    # Explotación y Post-explotación
    metasploit
    sqlmap
    exploitdb
    msfpc
    netexec
    smbmap
    enum4linux
    
    # Escaneo y Recolección de Información
    amass
    nmap
    masscan
    caido
    burpsuite
    dirb
    dirbuster
    ffuf
    gobuster
    nikto
    wpscan
    whatweb
    theharvester
    dnsenum
    subfinder

    # Android Auditoría
    android-studio   # IDE + emulador + SDK manager
    android-tools    # adb, fastboot
    apktool          # desensamblar APK (smali + recursos)
    jadx             # decompila APK a Java/Kotlin legible

    # Ingeniería Inversa y Análisis Binario
    ghidra
    radare2
    cutter
    binwalk
    #pwndbg  # pendiente verificar disponibilidad en nixpkgs
    ltrace
    strace
    checksec

    # Criptografía y Fuerza Bruta
    hashcat
    john
    thc-hydra
    cewl
    crunch
    seclists
    rockyou
    wordlists
    wfuzz

    # Active Directory y Windows
    bloodhound
    evil-winrm
    kerbrute
    python3Packages.impacket
    python3Packages.pwntools

    # Tunneling y Pivoting
    ligolo-ng

    # Escaneo moderno
    nuclei
    feroxbuster
    sslscan
    httpx
    gowitness

    # Esteganografía (CTF)
    steghide
    stegseek
    exiftool

    # Análisis / SMT solver (crypto CTF)
    z3

    # Anonimato y Proxies
    tor
    proxychains

    # Herramientas de Red y MITM
    ettercap
    mitmproxy
    bettercap
    responder
    wireshark
    tcpdump
    dsniff
    netcat
    socat
    # WiFi — auditoría WPA/WPS
    aircrack-ng
    pixiewps        # pixie dust offline (calcula PSK desde PKE/PKR/E-Hash)
    reaverwps-t6x   # WPS PIN brute force + pixie dust integrado (-K)
    bully           # alternativa a reaver para APs problemáticos con WPS
    wifite2         # automatiza todo el proceso (reaver/aircrack/hcxtools)
    mdk4            # deauth masivo, beacon flood (fuerza reconexión/handshake)
    hcxtools        # conversión handshakes WPA (cap → hc22000 para hashcat)
    hcxdumptool     # captura PMKID y EAPOL en modo monitor
    cowpatty        # fuerza bruta WPA PSK offline contra capturas
    kismet          # sniffer/IDS WiFi pasivo, descubrimiento de redes ocultas
  ];

}
