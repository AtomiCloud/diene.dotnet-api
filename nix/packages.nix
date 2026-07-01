{
  atomi,
  pkgs,
  pkgs-2605,
  pkgs-unstable,
}:
let
  all = rec {
    atomipkgs = (
      with atomi;
      rec {
        dotnetlint = atomi.dotnetlint.override { dotnetPackage = nix-2605.dotnet-sdk_10; };
        dn-inspect = atomi.dn-inspect.override { dotnetPackage = nix-2605.dotnet-sdk_10; };

        inherit
          atomiutils
          infralint
          infrautils
          pls
          sg
          ;
      }
    );

    nix-2605 = (
      with pkgs-2605;
      {
        inherit
          actionlint
          dotnet-sdk_10
          git
          gitlint
          go-task
          infisical
          pre-commit
          shellcheck
          skopeo
          treefmt
          ;
      }
    );

    nix-unstable = (
      with pkgs-unstable;
      {
      }
    );
  };
in
with all;
atomipkgs // nix-2605 // nix-unstable
