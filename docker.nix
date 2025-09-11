{
  nix2containerPkgs,
  config,
  scripts,
  tools,
  pkgs,
  ...
}: let
  l = pkgs.lib // builtins;

  user = "user";
  group = "user";
  uid = "1000";
  gid = "1000";

  zshrc = pkgs.writeText "zshrc" ''
    export PROMPT="tembo> "
  '';

  mkUser = pkgs.runCommand "mkUser" {} ''
    mkdir -p $out/etc/pam.d

    echo "${user}:x:${uid}:${gid}::" > $out/etc/passwd
    echo "${user}:!x:::::::" > $out/etc/shadow

    echo "${group}:x:${gid}:" > $out/etc/group
    echo "${group}:x::" > $out/etc/gshadow

    cat > $out/etc/pam.d/other <<EOF
    account sufficient pam_unix.so
    auth sufficient pam_rootok.so
    password requisite pam_unix.so nullok sha512
    session required pam_unix.so
    EOF

    touch $out/etc/login.defs
    mkdir -p $out/home/${user}
    cp ${zshrc} $out/home/${user}/.zshrc

  '';

  buildArgs = {
    name = "ai-agents";
    tag = "latest";
    config = {
      entrypoint = ["${config.packages.motd}/bin/motd"];
      user = "user";
      workingDir = "/home/user";
      env = [
        "HOME=/home/user"
        "NIX_PAGER=cat"
        "USER=user"
      ];
    };

    perms = [
      {
        path = mkUser;
        regex = "/home/${user}";
        mode = "0744";
        uid = l.toInt uid;
        gid = l.toInt gid;
        uname = user;
        gname = group;
      }
    ];

    copyToRoot = with pkgs; [
      coreutils
      bashInteractive
      mkUser
      (buildEnv {
        name = "ai-tools";
        paths =
          tools
          ++ scripts
          ++ [
            pkgs.busybox
          ];
        pathsToLink = ["/bin"];
      })
    ];
  };
in
  nix2containerPkgs.nix2container.buildImage buildArgs
