{config, ...}: {
  nix.extraOptions = ''
    !include /home/srghma/.dotfiles/secrets-ignored/nix-extra-config.conf
  '';
  # nix.extraOptions = ''
  #   !include ${config.sops.templates."nix-extra-config".path}
  # '';
  # nix.checkConfig = false;
  # sops.templates."nix-extra-config" = {
  #   content = ''
  #     access-tokens = github.com=${config.sops.placeholder."nano/github-token"}
  #   '';
  #   group = config.users.groups.nix-access-tokens.name;
  #   mode = "0440";
  # };
  # users.groups.nix-access-tokens.gid = config.ids.gids.nix-access-tokens;
  # sops.secrets."nano/github-token" = {
  #   sopsFile = config.sops-file.get "common.yaml";
  #   restartUnits = ["nix-daemon.service"];
  # };
}
