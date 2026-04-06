{ config, pkgs, ... }: {
  users.users.${config.hanix.mainUser} = {
    isNormalUser = true;
    description  = config.hanix.mainUser;
    extraGroups  = [ "networkmanager" "wheel" ];
    shell        = pkgs.zsh;
  };
}
