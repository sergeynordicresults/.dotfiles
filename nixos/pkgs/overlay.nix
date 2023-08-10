pkgs: pkgsOld:

rec {
  nixpkgsUnstable =
    let
      # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
      # nixpkgs-unstable-src = fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz;
      nixpkgs-unstable-src = <nixpkgs-unstable>;
    in import nixpkgs-unstable-src { config = { allowUnfree = true; }; };

  nixpkgsMaster = import <nixpkgs-master> { config = { allowUnfree = true; }; };

  nixpkgsLocal = import /home/srghma/projects/nixpkgs { config = { allowUnfree = true; }; };

  mypkgs = {
    all-hies                      = pkgs.callPackage ./all-hies {};
    arion                         = pkgs.callPackage ./arion {};
    auto-hie-wrapper              = pkgs.callPackage ./auto-hie-wrapper {};
    cachix                        = pkgs.callPackage ./cachix {};
    dropbox-nixpkgs               = pkgs.callPackage ./dropbox-nixpkgs {};
    dunsted-volume                = pkgs.callPackage ./dunsted-volume {};
    easy-purescript-nix-automatic = pkgs.callPackage ./easy-purescript-nix-automatic {};
    fix-github-https-repo         = pkgs.callPackage ./fix-github-https-repo {};
    hubstaff                      = pkgs.callPackage ./hubstaff {};
    kb-light                      = pkgs.callPackage ./kb-light {};
    linted-git-commit             = pkgs.callPackage ./linted-git-commit {};
    nix-lsp                       = pkgs.callPackage ../../pkgs/nix-lsp {};
    nixfmt                        = pkgs.haskellPackages.callPackage ../../pkgs/nixfmt {};
    nixfromnpm                    = pkgs.callPackage ./nixfromnpm {};
    obelisk                       = pkgs.libsForQt5.callPackage ./obelisk {};
    pgFormatter                   = pkgs.callPackage ./pgFormatter {};
    pgmodeler                     = pkgs.libsForQt5.callPackage ./pgmodeler {};
    randomize_background          = pkgs.callPackage ./randomize_background {};
    switch_touchpad               = pkgs.callPackage ./switch_touchpad {};
    tmuxx                         = pkgs.callPackage ./tmuxx {};
    umsf                          = pkgs.callPackage ./umsf {};
    yed                           = pkgs.callPackage ./yed {};
    update-module-name-purs       = pkgs.callPackage ./update-module-name-purs {};
    openbcigui                    = pkgs.callPackage ./openbcigui {};
    neuromore                     = pkgs.callPackage ./neuromore {};
    signal-desktop                = pkgs.callPackage ./signal-desktop {};
    i3-battery-popup              = pkgs.callPackage ./i3-battery-popup {};
  };

  inherit (mypkgs.dropbox-nixpkgs) dropbox-cli dropbox;

  lorri  = nixpkgsMaster.pkgs.lorri;
  direnv = nixpkgsUnstable.pkgs.direnv;
  pcscd  = nixpkgsUnstable.pkgs.pcscd;
}
