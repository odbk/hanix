# ── personal.nix ────────────────────────────────────────────────────────────
# Configuración personal que NO se comparte. Este fichero está commitado como
# stub. Para que git ignore tus cambios locales ejecuta UNA VEZ:
#
#   git update-index --skip-worktree shared/personal.nix
#
# Después edita este fichero con tus datos — nunca aparecerá en git status.
# ────────────────────────────────────────────────────────────────────────────

{ ... }:

{
  hanix.mainUser = "hanix";  # cambia por tu username real

  # ── Paquetes personales ────────────────────────────────────
  # environment.systemPackages = with pkgs; [
  #   alacritty
  # ];

  # ── Git ───────────────────────────────────────────────────
  # programs.git = {
  #   enable    = true;
  #   userName  = "Tu Nombre";
  #   userEmail = "tu@email.com";
  # };
}
