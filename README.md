# HaNiX

NixOS flake compartido — entorno hacker/cyberpunk con i3, polybar, greetd y nixvim.

## Características

- **i3** con gaps, picom (transparencias), wallpaper automático
- **Polybar** tema matrix verde con módulos: i3, bluetooth, wifi, volumen, CPU, RAM, disco, reloj
- **greetd + tuigreet** como display manager con ASCII art HaNiX
- **Rofi** launcher estilo hacker
- **Nixvim** configuración declarativa de neovim (catppuccin mocha, LSP, treesitter, etc.)
- **Fastfetch** al abrir terminal
- **Bluetooth** con blueman-applet

## Uso

### 1. Clonar

```bash
git clone https://github.com/tuusuario/hanixpkg
cd hanixpkg
```

### 2. Añadir tu hardware

Los ficheros `hosts/` contienen configuración específica de hardware (UUIDs de disco, módulos del kernel). Necesitas generar los tuyos:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/mipc.nix
```

Añade tu host en `flake.nix` siguiendo el patrón de `pc` o `laptop`, cambiando el hostname.

### 3. Configuración personal

```bash
cp shared/personal.nix shared/personal.nix.bak  # opcional
# Edita shared/personal.nix con tu usuario y datos
git update-index --skip-worktree shared/personal.nix
```

El fichero `personal.nix` define tu usuario y paquetes personales. Con `skip-worktree` git ignora tus cambios locales y nunca los subirás accidentalmente.

### 4. Aplicar

```bash
git add .
sudo nixos-rebuild switch --flake .#mihost
```

## Estructura

```
flake.nix               # entradas y hosts
hosts/                  # hardware específico (UUIDs, módulos kernel) — NO compartir
  pc.nix
  laptop.nix
  vm.nix
shared/
  configuration.nix     # base del sistema (audio, locale, bluetooth...)
  appearance.nix        # entorno gráfico (i3, polybar, greetd, fuentes...)
  essentials.nix        # paquetes esenciales
  extras.nix            # chats, fastfetch, utilidades extra
  hacking.nix           # herramientas de seguridad
  nixvim.nix            # configuración de neovim
  personal.nix          # ← TU usuario y config privada (skip-worktree)
  .config/              # dotfiles (i3, polybar, rofi, picom, fastfetch...)
```

## Añadir un nuevo host

En `flake.nix`, dentro de `nixosConfigurations`:

```nix
mipc = mkNixosSystem "mipc" [
  ./hosts/mipc.nix
  ./shared/appearance.nix
  { networking.hostName = "mipc"; }
];
```
