{ inputs, ... }: {
  perSystem = { pkgs, ... }:
  let
    networkSpeed = pkgs.writeShellScript "network-speed" ''
      #!/bin/sh
      # Get network interface (exclude lo, docker, veth, etc.)
      interface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
      if [ -z "$interface" ]; then
        echo " Offline"
        exit 0
      fi

      # Read initial values
      read_rx() { cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0; }
      read_tx() { cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0; }

      rx1=$(read_rx)
      tx1=$(read_tx)
      sleep 1
      rx2=$(read_rx)
      tx2=$(read_tx)

      # Calculate speed in KB/s
      rx_speed=$(( (rx2 - rx1) / 1024 ))
      tx_speed=$(( (tx2 - tx1) / 1024 ))

      # Format output
      if [ $rx_speed -gt 1024 ]; then
        rx_display="$(awk "BEGIN {printf \"%.1f\", $rx_speed/1024}")MB/s"
      else
        rx_display="''${rx_speed}KB/s"
      fi

      if [ $tx_speed -gt 1024 ]; then
        tx_display="$(awk "BEGIN {printf \"%.1f\", $tx_speed/1024}")MB/s"
      else
        tx_display="''${tx_speed}KB/s"
      fi

      echo " ↑''$tx_display  ↓''$rx_display"
    '';

    tmuxConf = pkgs.writeText "tmux.conf" ''
      # ── Prefix ──
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # ── Indexing ──
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on

      # ── Mouse ──
      set -g mouse on

      # ── Scrollback ──
      set -g history-limit 10000
      set -g escape-time 0

      # ── UI ──
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*:Co256"
      set -g focus-events on
      set -g set-clipboard on

      # ── Splits (intuitive) ──
      bind | split-window -h
      bind - split-window -v

      # ── Status bar ──
      set -g status-interval 5
      set -g status-left-length 30
      set -g status-right-length 80

      # ── Status position ──
      set-option -g status-position top

      # ── Status right (network speed) ──
      set -g status-right "#(${networkSpeed}) "

      # ── Plugins (non-theme only) ──
      run-shell '${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux'
      run-shell '${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux'
      run-shell '${pkgs.tmuxPlugins.better-mouse-mode}/share/tmux-plugins/better-mouse-mode/better-mouse-mode.tmux'
      # run-shell '${pkgs.tmuxPlugins.nord}/share/tmux-plugins/nord/nord.tmux'  # theme, skip for now
    '';
  in {
    packages.tmux = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.tmux;
      env.TMUX_CONF = tmuxConf;
      flags."-f" = tmuxConf;
    };
  };
}
