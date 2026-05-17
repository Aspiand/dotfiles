{ config, ... }:
{
  xdg.configFile."fresh/config.json".source = config.lib.file.mkOutOfStoreSymlink ./fresh.json;
}
