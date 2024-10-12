{ config, pkgs, lib, ... }:

with lib; let cfg = config.programs.utils.neovim; in

{
  options.programs.utils.neovim.enable = mkEnableOption "Neovim";

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.nodejs ];
      file."/home/aspian/.local/share/applications/neovim.desktop".text = ''
        [Desktop Entry]
        Name=Neovim wrapper
        GenericName=Text Editor
        GenericName[ckb]=دەستکاریکەری دەق
        GenericName[de]=Texteditor
        GenericName[fr]=Éditeur de texte
        GenericName[ru]=Текстовый редактор
        GenericName[sr]=Едитор текст
        GenericName[tr]=Metin Düzenleyici
        Comment=Edit text files
        Comment[af]=Redigeer tekslêers
        Comment[am]=የጽሑፍ ፋይሎች ያስተካክሉ
        Comment[ar]=حرّر ملفات نصية
        Comment[az]=Mətn fayllarını redaktə edin
        Comment[be]=Рэдагаваньне тэкставых файлаў
        Comment[bg]=Редактиране на текстови файлове
        Comment[bn]=টেক্স্ট ফাইল এডিট করুন
        Comment[bs]=Izmijeni tekstualne datoteke
        Comment[ca]=Edita fitxers de text
        Comment[ckb]=دەستکاریی فایلی دەق بکە
        Comment[cs]=Úprava textových souborů
        Comment[cy]=Golygu ffeiliau testun
        Comment[da]=Redigér tekstfiler
        Comment[de]=Textdateien bearbeiten
        Comment[el]=Επεξεργασία αρχείων κειμένου
        Comment[en_CA]=Edit text files
        Comment[en_GB]=Edit text files
        Comment[es]=Edita archivos de texto
        Comment[et]=Redigeeri tekstifaile
        Comment[eu]=Editatu testu-fitxategiak
        Comment[fa]=ویرایش پرونده‌های متنی
        Comment[fi]=Muokkaa tekstitiedostoja
        Comment[fr]=Éditer des fichiers texte
        Comment[ga]=Eagar comhad Téacs
        Comment[gu]=લખાણ ફાઇલોમાં ફેરફાર કરો
        Comment[he]=ערוך קבצי טקסט
        Comment[hi]=पाठ फ़ाइलें संपादित करें
        Comment[hr]=Uređivanje tekstualne datoteke
        Comment[hu]=Szövegfájlok szerkesztése
        Comment[id]=Edit file teks
        Comment[it]=Modifica file di testo
        Comment[ja]=テキストファイルを編集します
        Comment[kn]=ಪಠ್ಯ ಕಡತಗಳನ್ನು ಸಂಪಾದಿಸು
        Comment[ko]=텍스트 파일을 편집합니다
        Comment[lt]=Redaguoti tekstines bylas
        Comment[lv]=Rediģēt teksta failus
        Comment[mk]=Уреди текстуални фајлови
        Comment[ml]=വാചക രചനകള് തിരുത്തുക
        Comment[mn]=Текст файл боловсруулах
        Comment[mr]=गद्य फाइल संपादित करा
        Comment[ms]=Edit fail teks
        Comment[nb]=Rediger tekstfiler
        Comment[ne]=पाठ फाइललाई संशोधन गर्नुहोस्
        Comment[nl]=Tekstbestanden bewerken
        Comment[nn]=Rediger tekstfiler
        Comment[no]=Rediger tekstfiler
        Comment[or]=ପାଠ୍ଯ ଫାଇଲଗୁଡ଼ିକୁ ସମ୍ପାଦନ କରନ୍ତୁ
        Comment[pa]=ਪਾਠ ਫਾਇਲਾਂ ਸੰਪਾਦਨ
        Comment[pl]=Edytor plików tekstowych
        Comment[pt]=Editar ficheiros de texto
        Comment[pt_BR]=Edite arquivos de texto
        Comment[ro]=Editare fişiere text
        Comment[ru]=Редактирование текстовых файлов
        Comment[sk]=Úprava textových súborov
        Comment[sl]=Urejanje datotek z besedili
        Comment[sq]=Përpuno files teksti
        Comment[sr]=Уређујте текст фајлове
        Comment[sr@Latn]=Izmeni tekstualne datoteke
        Comment[sv]=Redigera textfiler
        Comment[ta]=உரை கோப்புகளை தொகுக்கவும்
        Comment[th]=แก้ไขแฟ้มข้อความ
        Comment[tk]=Metin faýllary editle
        Comment[tr]=Metin dosyaları düzenleyin
        Comment[uk]=Редактор текстових файлів
        Comment[vi]=Soạn thảo tập tin văn bản
        Comment[wa]=Asspougnî des fitchîs tecses
        Comment[zh_CN]=编辑文本文件
        Comment[zh_TW]=編輯文字檔
        TryExec=nvim
        Exec=nvim %F
        Terminal=true
        Type=Application
        Keywords=Text;editor;
        Keywords[ckb]=دەق;دەستکاریکەر;
        Keywords[fr]=Texte;éditeur;
        Keywords[ru]=текст;текстовый редактор;
        Keywords[sr]=Текст;едитор;
        Keywords[tr]=Metin;düzenleyici;
        Icon=nvim
        Categories=Utility;TextEditor;
        StartupNotify=false
        MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
      '';
    };
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        coc-nvim
        neovim-sensible
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter
        nvim-surround

        vim-airline
        vim-airline-clock
        vim-commentary
        vim-fugitive
        vim-gitgutter
        vim-indent-guides

        {
          plugin = dracula-nvim;
          config = ''
            colorscheme dracula
            syntax enable
          '';
        } {
          plugin = lazy-lsp-nvim;
          type = "lua";
          config = ''
            require("lazy-lsp").setup {
              excluded_servers = {
                "ccls", "zk",
              },
              -- preferred_servers = {
              --   markdown = {},
              --   python = { "pyright", "ruff_lsp" },
              -- }

            }
          '';
        } {
          plugin = vim-airline-themes;
          config = "let g:airline_theme='wombat'";
        }
      ];

      extraConfig = ''
        set cursorline
        set scrolloff=5
      '';

      # https://www.youtube.com/live/lZshGG4Mcws?si=RYcPcNlWpn_RVC0E 1:33:00
    };
  };
}