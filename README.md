# Picturium Nix Flake

This repository contains the Nix flake for building and deploying [Picturium](https://github.com/gravio-la/picturium), a fast and caching media server for processing images and generating thumbnails.

## Quick Start

### Building Picturium

```bash
nix build
```

The built binary will be available in `result/bin/picturium`.

### Running Picturium

```bash
nix run
```

### Development Shell

Enter a development environment with all dependencies:

```bash
nix develop
```

## NixOS Module

This flake provides a NixOS module for easy deployment.

### Usage in your NixOS configuration

Add this flake as an input in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    picturium.url = "github:gravio-la/picturium-nix";
  };

  outputs = { self, nixpkgs, picturium, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        picturium.nixosModules.picturium
        {
          services.picturium = {
            enable = true;
            host = "0.0.0.0";
            port = 20045;
            dataDir = "/var/lib/picturium/data";
            cache = "/var/cache/picturium";
            cacheCapacity = 10; # GB
            videoBackend = "auto"; # auto, ffmpeg, or mpv
            videoThumbnailPositions = "25%,20%,15%,0";
            secret_key = "your-secret-key-here";
          };
        }
      ];
    };
  };
}
```

## Configuration Options

The NixOS module provides the following options:

- `services.picturium.enable` - Enable the Picturium service (default: `false`)
- `services.picturium.host` - Host to bind to (default: `127.0.0.1`)
- `services.picturium.port` - Port to listen on (default: `20045`)
- `services.picturium.log` - Log level: debug, info, warn, error (default: `info`)
- `services.picturium.cors` - CORS settings (default: `""`)
- `services.picturium.secret_key` - Secret key for HMAC verification (default: `""`)
- `services.picturium.avifEnable` - Enable AVIF support (default: `true`)
- `services.picturium.cache` - Cache directory (default: `/var/cache/picturium`)
- `services.picturium.cacheEnable` - Enable caching (default: `true`)
- `services.picturium.cacheCapacity` - Cache capacity in GB (default: `10`)
- `services.picturium.dataDir` - Data directory (default: `/var/lib/picturium/data`)
- `services.picturium.videoBackend` - Video thumbnail backend: auto, ffmpeg, or mpv (default: `auto`)
- `services.picturium.videoThumbnailPositions` - Positions to sample for video thumbnails (default: `"25%,20%,15%,0"`)

## Video Thumbnail Support

Picturium supports generating thumbnails from video files using multiple backends:

1. **Native FFmpeg** (enabled by default in this Nix build) - Best performance
2. **Command-line FFmpeg** - Good performance, fallback option
3. **Command-line MPV** - Alternative fallback

The `videoBackend` option controls which backend to use:
- `auto` - Automatically detect and prefer native > ffmpeg > mpv
- `ffmpeg` - Use command-line ffmpeg only
- `mpv` - Use command-line mpv only

## Updating the Source

To update the picturium source commit:

1. Change the `rev` in `flake.nix` to the desired commit hash or tag
2. Update the `sha256` hash:
   ```bash
   nix flake update
   # or manually calculate with:
   nix-prefetch-git --url git@github.com:gravio-la/picturium.git --rev <commit-hash>
   ```

## License

See the [main Picturium repository](https://github.com/gravio-la/picturium) for license information.

