{
  description = "picturium - a lightweight thumbnail server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage ./package.nix { };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer
            pkg-config
            clang
            vips
            libpng
            zstd
            libffi
            libxcrypt-legacy
            ffmpeg
            mpv
          ];
          LD_LIBRARY_PATH = "${pkgs.boehmgc}/lib:${pkgs.libexif}/lib:${pkgs.libpng}/lib:${pkgs.zstd}/lib:${pkgs.libffi}/lib:${pkgs.libxcrypt-legacy}/lib";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        };
      }
    ) // {
      # NixOS module (system-independent)
      nixosModules.default = import ./module.nix;
      nixosModules.picturium = import ./module.nix;
    };
}
