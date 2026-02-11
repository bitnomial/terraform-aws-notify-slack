let
  # commit hash nixos-25.11 as of 2026-02-11
  nixpkgs-rev = "2db38e08fdad";

  nixpkgs-src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
    # obtained with 'nix-prefetch-url --unpack <url>'
    sha256 = "0jxwdhln3glrn11l3s4p5wzv6rsgyqdijw530xchcsh0ka0nydnn";
  };

  pkgs = import nixpkgs-src {};
in
pkgs.mkShell {
  packages = [
    (pkgs.python311.withPackages (ps: with ps; [
      boto3
      botocore
      pytest
      pytest-cov
      # snapshottest (~=0.6, from Pipfile) is omitted here. It transitively
      # depends on wasmer-compiler-cranelift, which fails to build in this
      # nixpkgs pin (undefined symbol: __rust_probestack).
      #
      # The snapshot tests in notify_slack_test.py use a `snapshot` pytest
      # fixture provided by snapshottest. They run every message type
      # (CloudWatch, GuardDuty, Security Hub, Health, Backup, etc.) through
      # get_slack_message_payload() and compare the output against saved
      # snapshots in functions/snapshots/snap_notify_slack_test.py. Without
      # snapshottest, those 2 tests will error at collection; the other 7
      # non-snapshot tests still pass fine.
      #
      # If we ever want to submit a PR upstream for the Block Kit changes
      # (see upstream issue #268), we'll need to regenerate the snapshots
      # with `pipenv run test:updatesnapshots`. At that point, either fix
      # snapshottest in nix (try a newer nixpkgs pin or override the wasmer
      # dependency) or just use pipenv for the snapshot update step.
      mypy
      flake8
      black
      isort
    ]))
  ];
}
