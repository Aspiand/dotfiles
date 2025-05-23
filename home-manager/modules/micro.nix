{ config, ... }:

{
  programs.micro.settings = {
    autoindent = true;
    autosave = 5;
    autosu = true;
    backup = true;
    backupdir = "${config.xdg.dataHome}/micro";
    basename = true;
    clipboard = "external"; # terminal internal
    cursorline = true;
    diffgutter = false;
    eofnewline = true;
    helpsplit = "hsplit";
    ignorecase = true;
    incsearch = true;
    keepautoindent = false;
    matchbrace = true;
    matchbraceleft = true;
    matchbracestyle = "highlight";
    mkparents = true;
    mouse = true;
    multiopen = "tab";
    permbackup = false;
    pluginrepos = [ ];
    relativeruler = false;
    reload = "prompt";
    ruler = true;
    savecursor = true;
    savehistory = true;
    saveundo = true;
    smartpaste = true;
    statusline = true;
    syntax = true;
    tabhighlight = true;
    tabmovement = true;
    tabreverse = true;
    tabsize = 4;
  };
}
