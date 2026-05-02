{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

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

    # Ingeniería Inversa y Análisis Binario
    ghidra
    radare2
    cutter
    binwalk
    gdb
    #pwndbg  # no disponible en unstable
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
    python3
    python2
    python3Packages.impacket
    python3Packages.requests
    python3Packages.beautifulsoup4
    python3Packages.paramiko
    python3Packages.pycryptodome
    python3Packages.pyopenssl
    python3Packages.colorama
    python3Packages.termcolor
    python3Packages.pwntools
    ruby
    jdk

    # Tunneling y Pivoting
    ligolo-ng

    # Escaneo moderno
    nuclei
    feroxbuster
    sslscan

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
    # WiFi
    aircrack-ng
    pixiewps
    wifite2
    hcxtools        # captura y conversión de handshakes WPA
    hcxdumptool     # captura de paquetes WiFi (PMKID, EAPOL)
    cowpatty        # fuerza bruta WPA PSK offline
  ];

}
