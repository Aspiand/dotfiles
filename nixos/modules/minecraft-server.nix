{ ... }:
{
  flake.nixosModules.minecraft-server =
    {
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }:
    {
      services.minecraft-server = {
        enable = true;
        package = pkgs-unstable.papermc;
        eula = true;
        declarative = true;
        openFirewall = false;
        dataDir = "/var/lib/minecraft";

        jvmOpts = ''
          -Xms3G -Xmx3G
          -XX:+UseG1GC
          -XX:+ParallelRefProcEnabled
          -XX:MaxGCPauseMillis=200
          -XX:+UnlockExperimentalVMOptions
          -XX:+DisableExplicitGC
          -XX:+AlwaysPreTouch
          -XX:G1NewSizePercent=30
          -XX:G1MaxNewSizePercent=40
          -XX:G1HeapRegionSize=8M
          -XX:G1ReservePercent=20
          -XX:G1HeapWastePercent=5
          -XX:G1MixedGCCountTarget=4
          -XX:InitiatingHeapOccupancyPercent=15
          -XX:G1MixedGCLiveThresholdPercent=90
          -XX:G1RSetUpdatingPauseTimePercent=5
          -XX:SurvivorRatio=32
          -XX:+PerfDisableSharedMem
          -XX:MaxTenuringThreshold=1
          -Dusing.aikars.flags=https://mcflags.emc.gs
          -Daikars.new.flags=true
        '';

        serverProperties = {
          server-port = 25565;
          server-ip = "0.0.0.0";
          motd = "aspian's minecraft server";
          max-players = 10;
          online-mode = false;
          enforce-secure-profile = false;
          white-list = false;
          enforce-whitelist = false;
          difficulty = "normal";
          gamemode = "survival";
          force-gamemode = true;
          pvp = true;
          hardcore = false;
          allow-flight = false;
          enable-command-block = false;
          level-name = "world";
          spawn-protection = 0;

          # Memory/CPU knobs: fewer loaded chunks and ticking entities.
          view-distance = 6;
          simulation-distance = 4;
          entity-broadcast-range-percentage = 75;
          network-compression-threshold = 256;
          sync-chunk-writes = false;
          max-tick-time = -1; # Paper's watchdog handles hangs
          pause-when-empty-seconds = 300;
          enable-status = true;
          player-idle-timeout = 0;
        };
      };

      systemd.services.minecraft-server = {
        # Installed on every start so a wiped dataDir still gets the plugin.
        preStart = lib.mkAfter ''
          install -Dm444 ${pkgs.authme} plugins/AuthMe.jar
        '';

        # 3 GiB heap + ~1.5 GiB JVM overhead, leaving the rest of the box
        # untouched even under a leak.
        serviceConfig = {
          MemoryMax = "5G";
          MemorySwapMax = "1G";
          CPUWeight = 200;
          IOSchedulingClass = "best-effort";
          # Paper saves chunks on stop; give it time instead of SIGKILL.
          TimeoutStopSec = "120s";
        };
      };

      # Journald keeps the last few boots of server output for debugging.
      services.journald.extraConfig = "SystemMaxUse=1G";
    };
}
