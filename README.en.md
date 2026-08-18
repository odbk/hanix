<p align="center">
  <img src="shared/images/boot.png" width="480" alt="HaNiX">
</p>

<p align="center">
  <a href="README.md">Español</a> · <strong>English</strong>
</p>

<p align="center">
  NixOS 25.11 flake for hacking and cybersecurity — a hacker environment with i3, Polybar and greetd,<br>
  100+ preinstalled security tools, a custom boot splash and a<br>
  <strong>local (offline) AI that writes and explains commands so you learn</strong>.
</p>

---

## Screenshots

| Login | Desktop | Shell |
|-------|---------|-------|
| ![greetd](screenshots/greetd.png) | ![desktop](screenshots/screen1.png) | ![shell](screenshots/shell.png) |

## Desktop environment

- **i3** with gaps and picom (transparency/blur)
- **Polybar** matrix-green theme
  - Top bar: workspaces · CPU · RAM · disk (click = usage popup) · network · volume · updates · power menu
  - Bottom bar: active IPs (click = copy + notification) · system tray
- **greetd + tuigreet** TUI login with HaNiX ASCII art
- **Plymouth** boot splash with custom HaNiX logo + green progress bar
- **GTK** catppuccin-mocha-green theme (Thunar, Geany, pavucontrol...)
- **Thunar + Xfconf** with persistent views, preferences, thumbnails and plugins
- **IAnix** local (offline) AI that writes and explains commands in your language; `-v` details every argument
- **Rofi** launcher and hacker-styled modals
- **VS Code and Geany** for editing, plus Kitty, Alacritty and Foot
- **Fastfetch** logo on terminal launch
- **tmux** with a matrix-green status bar (prefix `Ctrl+a`)
- **dunst** notifications — VPN connect/disconnect automatically
- **udiskie** USB automount with notification
- **flameshot** screenshots (`Print` = full, `mod+p` = area, `mod+Shift+p` = annotate)
- **i3lock-color** lock screen with HaNiX logo (`mod+Escape`)
- **Auto-detected** bootloader (systemd-boot UEFI / GRUB BIOS)

## Included security tools

### Exploitation & Post-exploitation
`metasploit` `sqlmap` `exploitdb` `msfpc` `netexec` `smbmap` `enum4linux` `git-dumper`

### Scanning & Reconnaissance
`nmap` `masscan` `amass` `subfinder` `dnsx` `naabu` `katana` `gau` `arjun` `dalfox` `theharvester` `dnsenum` `whatweb` `wafw00f` `nikto` `gobuster` `ffuf` `feroxbuster` `dirb` `dirbuster` `burpsuite` `caido` `nuclei` `nuclei-templates` `sslscan` `testssl` `httpx` `gowitness`

Nuclei templates ship inside the image at `/etc/hanix-data/nuclei-templates`, so they work without downloading anything on first boot:

```bash
nuclei -duc -t /etc/hanix-data/nuclei-templates -u https://target.test
```

### Code & secrets auditing
`semgrep` `gitleaks` `git-dumper`

### Active Directory & Windows
`bloodhound` `bloodhound-python` `evil-winrm` `kerbrute` `certipy` `coercer` `impacket` `ldapsearch` `kinit` `klist` `xfreerdp`

### Service clients
`snmpwalk` `snmpget` `showmount` `psql` `mysql` `redis-cli`

### Reverse Engineering & Binary Analysis
`ghidra` `radare2` `cutter` `binwalk` `gdb` `gef` `ltrace` `strace` `checksec` `pwninit` `patchelf` `qemu-user` `ropper` `pwntools`

### Cryptography & Brute force
`hashcat` `john` `thc-hydra` `cewl` `crunch` `wfuzz` `seclists` `rockyou` `wordlists` `sage` `z3` `xortool`

### Forensics, malware & steganography
`volatility3` `yara` `sleuthkit` `steghide` `stegseek` `zsteg` `pngcheck` `exiftool`

### Network, MITM & Pivoting
`wireshark` `ettercap` `mitmproxy` `bettercap` `responder` `tcpdump` `dsniff` `socat` `scapy` `arp-scan` `hping` `ike-scan` `ligolo-ng` `aircrack-ng` `pixiewps` `wifite2`

### Anonymity & Proxies
`tor` `proxychains`

### Android
`android-studio` `adb` `fastboot` `apktool` `jadx` `frida-tools` `objection`

## IAnix: local AI that writes and explains commands

`ianix` is a command assistant powered by a **local LLM baked into the ISO itself**. Describe the task in natural language (Spanish or **English** — it answers in your language) and **the model writes the command**; Python only validates safety. It runs **100% offline from first boot**: no Ollama, no API keys, nothing leaves your machine.

```bash
ianix what is my public ip           # → curl -s https://ifconfig.me
ianix scan the ports of 10.10.10.10
ianix fuzz paths on https://target.test/FUZZ
ianix whois google.com but only the registrar records   # → whois ... | grep -iE ...
```

**How it works.** By default it shows the command(s) and marks a default one **[A]**. Press **Enter** to run it, a **letter** to run another option, or **q** to cancel. Nothing else to type; only **destructive** commands ask for an extra `[y/N]` confirmation.

**Learn the why (`-v`).** With `-v` it explains what the command does and **what each argument is for**:

```bash
$ ianix -v scan the ports of 10.10.10.10
  [A] nmap -sV --open -T3 --top-ports 1000 10.10.10.10   · default (Enter)
      Detects services and versions on the host's open ports.
        nmap          network scanner
        -sV           detects the service and version of each port
        -T3           medium timing speed
        --top-ports   limits the scan to the most common ports
```

**Safe by design.** The command runs as an argument list **with no shell interpreter**: no `;`, `&&`, redirections or substitutions. The only exception is a **pipe into read-only filters** (`grep`, `cut`, `sort`, `uniq`, `head`, `jq`…) so you can ask for "only give me X of the output".

**System-aware.** It knows the installed tools and the **real resource paths**: wordlists at `/etc/hanix-data/wordlists` (SecLists, rockyou) and Nuclei templates at `/etc/hanix-data/nuclei-templates`. It never invents paths. If you name an installed tool (e.g. `use dnsenum on example.com`), it builds the command straight from that tool's `--help`.

**Verbose / inspect without running:**

```bash
ianix -v <request>              # explains every argument
ianix --solo-mostrar <request>  # shows the command, never runs it
ianix modelo                    # model and local server info
```

The model is [Qwen3-4B-Instruct-2507 GGUF](https://huggingface.co/lmstudio-community/Qwen3-4B-Instruct-2507-GGUF) (Q4_K_M, ~2.4 GB) served by [llama.cpp](https://github.com/ggml-org/llama.cpp). It starts on demand and sleeps after 30 minutes idle. It also shows up as **IAnix** in the Rofi launcher (`mod+d`).

## Installation

### Live ISO

The ISO boots i3 automatically with user `hanix` and password `hanix`. Those credentials belong only to the distributable live environment. The installer asks for and stores the installed system's user, hostname and password separately.

### 0. Prerequisites (fresh NixOS install)

```bash
nix-shell -p git
```

Or permanently in `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
environment.systemPackages = [ pkgs.git ];
```

```bash
sudo nixos-rebuild switch
```

### 1. Clone

```bash
git clone https://github.com/odbk/hanix
cd hanix
```

### 2. Initial setup

```bash
./setup
```

Creates the standard directories (`~/Images`, `~/CTF`, `~/Hacking`...) and marks `personal.nix` as skip-worktree.

### 3. Personal config

Edit `shared/personal.nix`:

```nix
{ ... }: {
  hanix.mainUser = "youruser";

  # Optional: limit Plymouth to your GPU module.
  # Defaults include amdgpu, radeon, i915, nouveau and virtio_gpu.
  hanix.plymouthGpuModules = [ "amdgpu" ];

  # Optional — if you cloned into another directory:
  # hanix.flakePath = "/home/youruser/hanix";

  # Optional — GRUB disk on BIOS systems (default /dev/sda):
  # hanix.grubDevice = "/dev/sda";
}
```

Enable skip-worktree so git never uploads your data:

```bash
git update-index --skip-worktree shared/personal.nix
```

### 4. Apply

```bash
./rebuild
```

If `hardware-configuration.nix` doesn't exist, the script copies it from `/etc/nixos`. On a clone that already includes one, replace it with the machine's before the first rebuild:

```bash
cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

It then detects whether the system is UEFI or BIOS and applies the right configuration.

> For the Plymouth boot splash to appear on the first boot use `./rebuild boot` instead of `./rebuild`.

## Layout

```
flake.nix                    # inputs and configurations
rebuild                      # install/update script
setup                        # initial setup script (run before the first rebuild)
hardware-configuration.nix   # machine-specific; the installer generates it
shared/
  configuration.nix          # system base (audio, locale, bluetooth, bootloader, aliases...)
  programs.nix               # programs with NixOS integration (Thunar, Xfconf, Wireshark, tmux...)
  ianix.nix                  # package and local runtime for the IAnix assistant
  ianix/                     # IAnix CLI, prompts and tests
  essentials.nix             # core packages and services without a specific programs.* module
  extras.nix                 # extra software (telegram, vlc, redshift...)
  hacking.nix                # 100+ security tools
  default-user.nix           # defines the user from hanix.mainUser
  user-option.nix            # customizable hanix.* options
  personal.nix               # ← YOUR private config (skip-worktree, never uploaded)
  themes/
    appearance.nix           # graphical environment (i3, polybar, greetd, GTK, fonts, dotfiles sync)
    plymouth.nix             # HaNiX boot splash
    plymouth/hanix/          # Plymouth theme assets (logo, script)
  images/
    boot.png                 # original HaNiX logo
  .config/                   # dotfiles (i3, polybar, rofi, dunst, tmux, fastfetch...)
```

## Customizable options (`personal.nix`)

| Option | Default | Description |
|--------|---------|-------------|
| `hanix.mainUser` | `"hanix"` | Main user name |
| `hanix.flakePath` | `/home/<user>/hanix` | Path to the repo (for the `rebuild` alias) |
| `hanix.grubDevice` | `"/dev/sda"` | GRUB install disk (BIOS systems only) |
| `hanix.plymouthGpuModules` | common GPUs | KMS modules for the boot splash (`amdgpu`, `radeon`, `i915`, `nouveau`, `virtio_gpu`) |

## Programs and packages

[`shared/programs.nix`](shared/programs.nix) uses `programs.*` modules as the declarative interface when NixOS is meant to install or configure the program. Many also add D-Bus/systemd registration, settings persistence, plugins, environment variables or capability-limited wrappers. That's where Thunar/Xfconf, Dconf, Tumbler, FZF, Git, Java, Ghidra, Evince, Firefox, VS Code, tmux, i3lock, ADB, MTR, tcpdump and Wireshark live.

Apps whose module only manages policies, requires configuration HaNiX shouldn't impose, or depends on a `graphical-session.target` that i3 doesn't activate stay in `environment.systemPackages`. That's the case for Chromium/Chrome, Proxychains, Rofi, Kitty and the applets launched by i3.

`programs.<name>.enable = true` is the idiomatic way to enable a NixOS module. IAnix, being an in-house app, is packaged explicitly from [`shared/ianix.nix`](shared/ianix.nix).

On installed systems HaNiX runs the Nix garbage collector and optimizer weekly. The collector keeps 30 days of generations for a reasonable rollback window; the timers are disabled on the live ISO, whose store is immutable and temporary.
