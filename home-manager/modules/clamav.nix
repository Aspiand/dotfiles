{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.clamav;
  dir = "${cfg.dir}";
  log_dir = "${dir}/log";
  db_dir = "${dir}/database";
  config_dir = "${config.home.homeDirectory}/.config/clamav";
  username = config.home.username;
in

{
  options.programs.clamav = {
    enable = mkEnableOption "ClamAV";
    dir = mkOption {
      type = types.path;
      default = "${config.xdg.dataHome}/clamav";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.clamav ];

    home.shellAliases = {
      clamscan = "${pkgs.clamav}/bin/clamscan --database ${db_dir}";
      clamd = "${pkgs.clamav}/bin/clamd --config-file ${config_dir}/clamd.conf";
      clamdscan = "${pkgs.clamav}/bin/clamdscan --config-file ${config_dir}/clamd.conf";
      freshclam = "${pkgs.clamav}/bin/freshclam --config-file ${config_dir}/freshclam.conf";
    };

    home.activation.clamavSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for dir in "${cfg.dir}" "${config_dir}" "${db_dir}" "${log_dir}"; do
        [ ! -d "$dir" ] && mkdir -vp "$dir"
      done

      # Clamd
      cat <<EOF > ${config_dir}/clamd.conf
      LocalSocket ${dir}/clamd.ctl
      FixStaleSocket true
      LocalSocketGroup ${username}
      LocalSocketMode 666
      # TemporaryDirectory is not set to its default /tmp here to make overriding
      # the default with environment variables TMPDIR/TMP/TEMP possible
      User ${username}
      ScanMail true
      ScanArchive true
      ArchiveBlockEncrypted false
      MaxDirectoryRecursion 15
      FollowDirectorySymlinks true
      FollowFileSymlinks true
      ReadTimeout 180
      MaxThreads 12
      MaxConnectionQueueLength 15
      PreludeEnable no
      PreludeAnalyzerName ClamAV
      DatabaseDirectory ${db_dir}
      OfficialDatabaseOnly true
      SelfCheck 3600
      Foreground false
      Debug false
      ScanPE true
      MaxEmbeddedPE 10M
      ScanOLE2 true
      ScanPDF true
      ScanHTML true
      MaxHTMLNormalize 10M
      MaxHTMLNoTags 2M
      MaxScriptNormalize 5M
      MaxZipTypeRcg 1M
      ScanSWF true
      ExitOnOOM false
      LeaveTemporaryFiles false
      AlgorithmicDetection true
      ScanELF true
      IdleTimeout 30
      CrossFilesystems true
      PhishingSignatures true
      PhishingScanURLs true
      PhishingAlwaysBlockSSLMismatch false
      PhishingAlwaysBlockCloak false
      PartitionIntersection false
      DetectPUA false
      ScanPartialMessages false
      HeuristicScanPrecedence false
      StructuredDataDetection false
      CommandReadTimeout 30
      SendBufTimeout 200
      MaxQueue 100
      ExtendedDetectionInfo true
      OLE2BlockMacros false
      AllowAllMatchScan true
      ForceToDisk false
      DisableCertCheck false
      DisableCache false
      MaxScanTime 120000
      MaxScanSize 100M
      MaxFileSize 25M
      MaxRecursion 16
      MaxFiles 10000
      MaxPartitions 50
      MaxIconsPE 100
      PCREMatchLimit 10000
      PCRERecMatchLimit 5000
      PCREMaxFileSize 25M
      ScanXMLDOCS true
      ScanHWP3 true
      MaxRecHWP3 16
      StreamMaxLength 25M
      LogFile ${log_dir}/clamd.log
      LogTime true
      LogFileUnlock false
      LogFileMaxSize 10M
      LogRotate true
      LogFacility LOG_LOCAL6
      LogClean false
      LogVerbose false
      Bytecode true
      BytecodeSecurity TrustSigned
      BytecodeTimeout 60000
      OnAccessMaxFileSize 5M
      EOF

      cat <<EOF > ${config_dir}/freshclam.conf
      DatabaseOwner ${username}
      UpdateLogFile ${log_dir}/freshclam.log
      LogVerbose true
      LogSyslog false
      LogFacility LOG_LOCAL6
      LogFileMaxSize 10M
      LogRotate true
      LogTime true
      Foreground false
      Debug false
      MaxAttempts 5
      DatabaseDirectory ${db_dir}
      DNSDatabaseInfo current.cvd.clamav.net
      ConnectTimeout 30
      ReceiveTimeout 0
      TestDatabases yes
      ScriptedUpdates yes
      CompressLocalDatabase yes
      Bytecode true
      NotifyClamd yes
      NotifyClamd ${config_dir}/clamd.conf
      Checks 24
      DatabaseMirror db.local.clamav.net
      DatabaseMirror database.clamav.net
      PidFile ${dir}/freshclam.pid
      EOF

      find "${cfg.dir}" -type d -not -perm "700" -exec chmod -v 700 {} \;
      find "${cfg.dir}" -type f -not -perm "600" -exec chmod -v 600 {} \;
    '';
  };
}