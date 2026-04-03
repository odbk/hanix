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
    pwndbg
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
    aircrack-ng
    pixiewps
    wifite2
  ];

}
