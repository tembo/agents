{pkgs}: let
  # Function to format package info
  formatPackage = pkg: "${pkg.name} -- ${pkg.version or "unknown"}";

  paths = import ../tools.nix {inherit pkgs;};

  # Loop through all packages in paths and format them
  allPackagesOutput = builtins.concatStringsSep "\n" (map formatPackage paths);
in
  # Create a simple script that displays the versions
  pkgs.writeShellScriptBin "versions" ''
    #!/bin/bash
    cat << 'EOF'
    ${allPackagesOutput}
    EOF
  ''
