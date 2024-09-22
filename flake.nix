{
  description = "Rudelblinken";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
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
        easyeda2kicad =
          with pkgs;
          python3Packages.buildPythonApplication {
            pname = "easyeda2kicad";
            version = "0.8.0";
            pyproject = true;

            src = pkgs.fetchFromGitHub {
              owner = "uPesy";
              repo = "easyeda2kicad.py";
              rev = "b477d9d4dfdb9a030a284a0644cd594b9a02cef0";
              hash = "sha256-3Nray+gN4yahMddzsk3Hn0yTc/wDcGAGzsUOhvi2TwU=";
            };

            build-system = with python3Packages; [ setuptools ];

            dependencies = with python3Packages; [
              pydantic
              requests
            ];
          };
      in
      {
        name = "rudelblinken";

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.go
            pkgs.steam-run
            pkgs.linux-wifi-hotspot
            pkgs.kicad
            pkgs.python3
            easyeda2kicad
          ];
          shellHook = ''
            function wrapProgram() {
              local directory="$(dirname $1)"
              local file="$(basename $1)"
              mv $directory/$file $directory/.unwrapped_$file
              cat <<EOF > $directory/$file
            #!/usr/bin/env bash
            steam-run $directory/.unwrapped_$file "\$@"
            EOF
            chmod a+x $directory/$file
            }

            # Add a directory for binaries that will be linked into path
            mkdir -p ~/.cache/hackyJaguarFlake/bin
            export PATH=~/.cache/hackyJaguarFlake/bin:$PATH

            # Install the latest jag via go into the user home
            go install github.com/toitlang/jaguar/cmd/jag@latest 

            # Create a steam-run wrapper in our bin directory
            cat <<EOF > ~/.cache/hackyJaguarFlake/bin/jag
            #!/usr/bin/env bash
            steam-run $HOME/go/bin/jag "\$@"
            EOF
            chmod a+x ~/.cache/hackyJaguarFlake/bin/jag

            # Download toit and jaguar tools
            # And wrap them in steam-run
            if ! jag setup --check ; then
              jag setup
              find $HOME/.cache/jaguar/sdk -type f -executable | while read line ; do
                wrapProgram $line
              done
            fi

            # Link jaguar tools into temporary bin
            find $HOME/.cache/jaguar/sdk/bin $HOME/.cache/jaguar/sdk/tools -type f -executable | while read line ; do
              ln -sf $line ~/.cache/hackyJaguarFlake/bin/$(basename $line)
            done

            # Open udp port 1990 for finding jaguar devices
            if which nft ; then
              sudo nft add rule inet nixos-fw input-allow udp dport 1990 accept
            else
              echo Make sure that UDP port 1990 is open, otherwise scanning for esp devices wont work
            fi
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
