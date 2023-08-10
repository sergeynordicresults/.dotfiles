{ pkgs, ... }:

{
  # This function makes a copy of package and adds `.nix_runtime_deps_references` file containing links to other packages

  # This function can be used to prevent garbage-collection of packages that were generated/downloaded during import from derivation (IFD) and make them last as long as the imported package do.

  # Check https://github.com/NixOS/nix/issues/954#issuecomment-365281661 for more.
  # Check https://stackoverflow.com/questions/34769296/build-versus-runtime-dependencies-in-nix how runtime dependencies work.

  # Example:

  # {
  #   environment.systemPackages =
  #     let
  #       packageSrc = fetchFromGitHub { owner = ..., .... };
  #       package = import "${packageSrc}/release.nix";
  #     in
  #       [
  #         package
  #       ]
  # }

  # Here the `package` will not be garbage-collected on next `sudo nix-collect-garbage -d`, but `packageSrc` do

  # But with

  # {
  #   environment.systemPackages =
  #     let
  #       packageSrc = fetchFromGitHub { owner = ..., .... };
  #       package = import "${packageSrc}/release.nix";
  #       imrovedPackage = addAsRuntimeDeps [packageSrc] package;
  #     in
  #       [
  #         imrovedPackage
  #       ]
  # }

  # neither `package`, not `packageSrc` will not be garbage-collected

  # TODO:
  # make addAsRuntimeDeps composable with itself by appending links if drv already contains nix_runtime_deps_references
  # E.g. addAsRuntimeDeps [src2] (addAsRuntimeDeps [src1] drv)

  addAsRuntimeDeps = deps: drv:
    assert (pkgs.lib.isDerivation drv);
    let
      fileWithLinks = pkgs.writeText "fileWithLinks" (
        pkgs.lib.concatMapStringsSep "\n" toString deps + "\n"
      );

      drvName = drv: builtins.unsafeDiscardStringContext (pkgs.lib.substring 33 (pkgs.lib.stringLength (builtins.baseNameOf drv)) (builtins.baseNameOf drv));
    in
      pkgs.runCommand (drvName drv) { } ''
        ${pkgs.coreutils}/bin/mkdir -p $out
        ${pkgs.coreutils}/bin/cp ${fileWithLinks} $out/.nix_runtime_deps_references
        ${pkgs.rsync}/bin/rsync -a ${drv}/ $out/
      '';
}
