{ pkgs, unstablePkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  environment.systemPackages = (with pkgs; [

    # Explotación y Post-explotación
    metasploit
    sqlmap
    exploitdb
    msfpc
    netexec
    smbmap
    enum4linux
    git-dumper
    
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
    dnsrecon
    subfinder
    assetfinder
    dnsx
    naabu
    rustscan
    katana
    gau
    waybackurls
    ddgr
    arjun
    dalfox
    wafw00f
    testssl

    # Android Auditoría
    android-studio   # IDE + emulador + SDK manager
    apktool          # desensamblar APK (smali + recursos)
    jadx             # decompila APK a Java/Kotlin legible
    frida-tools      # instrumentación dinámica de aplicaciones nativas/móviles

    # Ingeniería Inversa y Análisis Binario
    radare2
    cutter
    binwalk
    #pwndbg  # pendiente verificar disponibilidad en nixpkgs
    ltrace
    strace
    checksec
    gef
    pwninit
    patchelf
    qemu-user
    python3Packages.ropper

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
    sage
    xortool

    # Active Directory y Windows
    bloodhound
    bloodhound-py
    evil-winrm
    kerbrute
    certipy
    coercer
    python3Packages.impacket
    python3Packages.pwntools
    openldap       # ldapsearch y utilidades LDAP
    krb5           # kinit, klist y clientes Kerberos
    freerdp        # xfreerdp para RDP

    # Enumeración de servicios y clientes de bases de datos
    net-snmp       # snmpwalk, snmpget...
    nfs-utils      # showmount y utilidades NFS
    postgresql     # psql
    mariadb.client # cliente mysql/mariadb sin habilitar servidor
    redis          # redis-cli; el servicio no se habilita

    # Tunneling y Pivoting
    ligolo-ng

    # Escaneo moderno
    nuclei
    nuclei-templates
    feroxbuster
    sslscan
    httpx
    gowitness
    semgrep
    gitleaks
    trufflehog
    trivy

    # Esteganografía (CTF)
    steghide
    stegseek
    exiftool
    zsteg
    pngcheck

    # Forense y análisis de malware
    volatility3
    yara
    yara-x
    sleuthkit

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
    dsniff
    nftables
    netcat
    socat
    python3Packages.scapy
    arp-scan
    fping
    hping
    ike-scan
    onesixtyone
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
    hostapd         # daemon AP — levantar punto de acceso propio
  ]) ++ [
    # Objection aún no está en nixos-25.11, pero sí en el input unstable fijado.
    unstablePkgs.objection
  ];

  # Copia inmutable y versionada de las plantillas. Así la LiveCD no depende
  # de descargarlas en el primer uso y IAnix dispone de una ruta estable.
  environment.etc."hanix-data/nuclei-templates".source =
    "${pkgs.nuclei-templates}/share/nuclei-templates";

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];

}
