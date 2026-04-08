# azel

Host NixOS independen berbasis flake untuk instalasi ke external drive dengan layout berikut:

- Boot `UEFI/EFI` saja, bukan legacy BIOS
- `systemd-boot`
- `disko`
- `LUKS2`
- `Btrfs` dengan subvolume `@root`, `@home`, `@nix`, `@log`, `@persist`
- `zram` swap sebesar 50% RAM dengan prioritas lebih tinggi
- swap partition on-disk 8G dengan prioritas lebih rendah
- `Hyprland` + `caelestia-shell` via Home Manager
- declarative persistence via `/persist`

## Struktur

- `flake.nix`: flake host independen
- `configuration.nix`: base system config
- `disko.nix`: partisi GPT + ESP + LUKS + Btrfs
- `hardware-configuration.nix`: template hardware generik
- `home.nix`: config user untuk `Hyprland` dan `caelestia-shell`
- `TODO.md`: catatan lanjutan untuk hardware portability

## Sebelum install

Edit dua file berikut dulu:

1. Ganti disk target di `disko.nix`

```nix
device = "/dev/disk/by-id/CHANGE-ME";
```

Pakai path `by-id`, jangan `/dev/sdX` kalau bisa, supaya lebih stabil.

2. Kalau perlu, ganti user awal di `flake.nix`, `configuration.nix`, dan `home.nix`

3. Kalau perlu, sesuaikan ukuran swap disk di `disko.nix`

Default saat ini:

```nix
swap = {
  size = "8G";
};
```

Default saat ini:

- username: `aka`
- password awal: `nixos`
- hostname: `azel`
- timezone: `Asia/Makassar`
- `zram` priority: `100`
- swap disk priority: `10`

## Persistence

`/persist` sekarang dipakai aktif untuk state sistem yang penting, tanpa membuat root menjadi ephemeral dulu.

Path yang dipersist secara deklaratif saat ini:

- `/etc/ssh`
- `/etc/machine-id`
- `/var/lib/nixos`
- `/var/lib/NetworkManager`
- `/var/lib/bluetooth`
- `/var/lib/systemd/coredump`

`/var/log` tetap tidak dimasukkan ke `/persist/system`, karena sudah dipisah lewat subvolume `@log`.

## Langkah install dari mesin NixOS yang sedang menyala

Contoh asumsi:

- repo ini ada di `/home/ao/.config/dotfiles`
- target adalah external drive yang sudah Anda pilih dengan benar
- install dilakukan dari sistem NixOS lain yang sedang hidup

### 1. Masuk ke direktori host

```bash
cd /home/ao/.config/dotfiles/nixos/hosts/azel
```

### 2. Pastikan target disk benar

Lihat disk dan ID:

```bash
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id
```

Lalu edit `disko.nix` dan isi `device` dengan disk external yang benar.

### 3. Partisi, format, enkripsi, dan mount pakai disko

Perintah ini akan menghapus isi disk target.

```bash
sudo nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko ./disko.nix
```

Setelah selesai, target akan ter-mount ke `/mnt` sesuai mountpoint di `disko.nix`.

### 4. Generate hardware config aktual

Template `hardware-configuration.nix` di repo ini sengaja generik. Ganti dengan hasil scan mesin target:

```bash
tmpdir="$(mktemp -d)"
sudo nixos-generate-config --root /mnt --dir "$tmpdir"
cp "$tmpdir/hardware-configuration.nix" ./hardware-configuration.nix
rm -rf "$tmpdir"
```

Lalu buang blok `fileSystems` dan `swapDevices` dari file hasil generate itu, karena mount layout dan swap sudah dikelola oleh `disko.nix`.

Yang dipertahankan umumnya:

- `imports`
- `boot.initrd.availableKernelModules`
- `boot.initrd.kernelModules`
- `boot.kernelModules`
- `boot.extraModulePackages`
- `nixpkgs.hostPlatform`
- firmware / microcode yang memang terdeteksi

### 5. Install ke `/mnt` memakai flake host ini

Jalankan dari direktori `nixos/hosts/azel`:

```bash
sudo nixos-install --root /mnt --flake .#azel
```

Karena konfigurasi ini memakai `systemd-boot` dan ESP di `/boot`, hasilnya adalah boot mode `UEFI/EFI`, bukan legacy boot.

### 6. Reboot dan pilih boot UEFI external drive

```bash
sudo reboot
```

Di firmware boot menu, pilih entry UEFI dari external drive tersebut.

## Catatan penting untuk external drive

- `boot.loader.efi.canTouchEfiVariables = false` dipakai agar install tidak mengubah NVRAM mesin yang sedang dipakai untuk instalasi.
- Ini tetap instalasi EFI, hanya tidak memaksa menulis boot entry ke firmware host installer.
- Pada beberapa mesin, Anda mungkin perlu memilih manual entry UEFI external drive dari boot menu firmware.
- Swap disk dibuat dengan `randomEncryption = true`, jadi cocok sebagai fallback swap tetapi bukan untuk hibernation / resume.

## Verifikasi setelah boot

Pastikan hasilnya benar:

```bash
[ -d /sys/firmware/efi ] && echo EFI || echo Legacy
findmnt -no SOURCE /
findmnt -no FSTYPE /
sudo cryptsetup status cryptroot
sudo btrfs subvolume list /
swapon --show
```

Yang diharapkan:

- `/sys/firmware/efi` ada
- root berada di `btrfs`
- `cryptroot` aktif
- subvolume Btrfs tampil
- `zram` muncul dengan prioritas lebih tinggi daripada swap disk

## Referensi

- https://wiki.nixos.org/wiki/Btrfs
- https://nixos.org/manual/nixos/stable/#sec-installation-manual
- https://github.com/caelestia-dots/shell
