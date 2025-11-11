# This file is ready to be copied to nixpkgs as:
# pkgs/by-name/pi/picturium/package.nix

{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, clang
, vips
, ffmpeg
, llvmPackages
}:

rustPlatform.buildRustPackage rec {
  pname = "picturium";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "gravio-la";
    repo = "picturium";
    rev = "v0.1.5-video";
    sha256 = "sha256-fRsH6qfB5guXsJuo6HEOsOowyg9SBTajZKmnqN0K/xc=";
  };

  cargoHash = "sha256-oZ8H0+nFvejqXjPDLK9H0QWFW4V6xoWIwzEF6jAZVb0=";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    vips
    ffmpeg
  ];

  # Enable native-ffmpeg feature for better performance
  buildFeatures = [ "native-ffmpeg" ];

  # Required for bindgen (used by ffmpeg-next)
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  doCheck = false;

  meta = with lib; {
    description = "Fast and caching media server for processing images, generating thumbnails and serving files on the fly";
    homepage = "https://github.com/picturium/picturium";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "picturium";
    platforms = platforms.linux;
  };
}

