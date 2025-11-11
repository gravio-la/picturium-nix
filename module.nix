# This file is ready to be copied to nixpkgs as:
# nixos/modules/services/web-apps/picturium.nix
# And added to: nixos/modules/module-list.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.services.picturium;
in
{
  options.services.picturium = with lib; {
    enable = mkEnableOption "Picturium thumbnail service";

    package = mkPackageOption pkgs "picturium" { };

    log = mkOption {
      type = types.str;
      default = "info";
      description = "Log level for Picturium. (debug, info, warn, error)";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host for Picturium to bind to.";
    };

    port = mkOption {
      type = types.port;
      default = 20045;
      description = "Port for Picturium to listen on.";
    };

    cors = mkOption {
      type = types.str;
      default = "";
      description = "CORS settings for Picturium.";
    };

    secretKey = mkOption {
      type = types.str;
      default = "";
      description = ''
        A secret string used for HMAC verification in requests.
        Must be a secure, random string (e.g., 32+ chars).
        Leave empty to disable token authorization.
      '';
    };

    avifEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AVIF support in Picturium.";
    };

    cache = mkOption {
      type = types.path;
      default = "/var/cache/picturium";
      description = "Cache directory for Picturium.";
    };

    cacheEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable caching in Picturium.";
    };

    cacheCapacity = mkOption {
      type = types.ints.positive;
      default = 10;
      description = "Cache capacity in GB.";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory containing files to serve. This must be explicitly configured.";
    };

    videoBackend = mkOption {
      type = types.enum [ "auto" "native" "ffmpeg" "mpv" ];
      default = "native";
      description = ''
        Video thumbnail backend.
        - auto: Automatically detect (native > ffmpeg > mpv)
        - native: Use native FFmpeg (libav bindings, best performance)
        - ffmpeg: Use command-line ffmpeg
        - mpv: Use command-line mpv
      '';
    };

    videoThumbnailPositions = mkOption {
      type = types.str;
      default = "25%,20%,15%,0";
      example = "10%,50%,90%";
      description = ''
        Comma-separated list of positions to sample for video thumbnails.
        Supports percentages (e.g., '25%,50%') or frame numbers (e.g., '100,200').
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.picturium = {
      description = "Picturium Thumbnail Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/picturium";
        Restart = "on-failure";
        
        # Security hardening
        DynamicUser = true;
        StateDirectory = "picturium";
        CacheDirectory = "picturium";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        
        Environment = [
          "LOG=${cfg.log}"
          "HOST=${cfg.host}"
          "PORT=${toString cfg.port}"
          "CORS=${cfg.cors}"
          "KEY=${cfg.secretKey}"
          "AVIF_ENABLE=${lib.boolToString cfg.avifEnable}"
          "CACHE=${cfg.cache}"
          "CACHE_ENABLE=${lib.boolToString cfg.cacheEnable}"
          "CACHE_CAPACITY=${toString cfg.cacheCapacity}"
          "DATA_DIR=${cfg.dataDir}"
          "VIDEO_BACKEND=${cfg.videoBackend}"
          "VIDEO_THUMBNAIL_POSITIONS=${cfg.videoThumbnailPositions}"
        ];
      } // lib.optionalAttrs (cfg.videoBackend != "native") {
        # Only add command-line video tools to PATH if not using native backend
        PATH = lib.makeBinPath (
          lib.optionals (cfg.videoBackend == "auto" || cfg.videoBackend == "ffmpeg") [ pkgs.ffmpeg ] ++
          lib.optionals (cfg.videoBackend == "auto" || cfg.videoBackend == "mpv") [ pkgs.mpv ]
        );
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}

