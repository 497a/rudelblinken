{
  description = "Rudelblinken";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        name = "rudelblinken";

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.go
            pkgs.steam-run
          ];
          shellHook = ''
            go install github.com/toitlang/jaguar/cmd/jag@latest 
            mkdir -p ~/.cache/hackyJaguarFlake/bin
            cat <<EOF > ~/.cache/hackyJaguarFlake/bin/jag
            #!/usr/bin/env bash
            steam-run $HOME/go/bin/jag "\$@"
            EOF
            chmod a+x ~/.cache/hackyJaguarFlake/bin/jag
            export PATH=~/.cache/hackyJaguarFlake/bin:$PATH
            sudo nft add rule inet filter input-allow udp dport 1990 accept
            # export PATH=~/go/bin/:$PATH
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
