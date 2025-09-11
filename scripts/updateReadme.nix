{pkgs}: let
  # Function to format package info
  formatPackage = pkg: {
    name = pkg.name;
    version = pkg.version or "unknown";
  };

  paths = import ../tools.nix {inherit pkgs;};

  # Loop through all packages in paths and format them
  allPackagesOutput = builtins.toJSON (map formatPackage paths);
in
   # Create a simple script that displays the versions
   pkgs.writers.writeJSBin "updateReadme" {
     libraries = [];
   } ''
     const fs = require('fs');
     const allPackagesOutput = JSON.parse('${allPackagesOutput}');
     const readme = fs.readFileSync('README.md', 'utf8');

     // Generate markdown table
     function generateTable(packages) {
       let table = "| Package | Version |\n|---------|---------|\n";
       packages.forEach(pkg => {
         table += "| " + pkg.name + " | " + pkg.version + " |\n";
       });
       return table;
     }

     const table = generateTable(allPackagesOutput);

     // Replace or add the Versions section
     const versionsSection = "## Versions\n\n" + table;
     let newReadme;
     if (readme.includes("## Versions")) {
       // Replace existing section
       newReadme = readme.replace(/(## Versions\n\n)[\s\S]*?(?=\n##|$)/, "$1" + table);
     } else {
       // Add new section at the end
       newReadme = readme + "\n" + versionsSection;
     }

     fs.writeFileSync('README.md', newReadme);
     console.log("README.md updated with versions table.");
   ''
