{ pkgs, packages }:
with packages;
{
  dev = [
    git
    infisical
    pls
    skopeo
  ];

  lint = [
    actionlint
    dn-inspect
    dotnetlint
    gitlint
    go-task
    infralint
    pre-commit
    sg
    shellcheck
    treefmt
  ];

  main = [
    dotnet-sdk_10
  ];

  releaser = [
    sg
  ];

  system = [
    atomiutils
    infrautils
  ];
}
