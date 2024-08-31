# Enkripsi
## -
Membuat file image disk
```bash
$ dd if=/dev/zero of=data.img bs=1M count=1024 status=progress
```

### Standalone
#### Membuat
```bash
$ cryptsetup luksFormat ./data.img data

WARNING!
========
This will overwrite data on ./data.img irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for ./data.img: 
Verify passphrase: 
```

```bash
$ sudo cryptsetup open ./data.img data
Enter passphrase for ./data.img:
```

```bash
$ lsblk 
NAME   MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0    7:0    0     1G  0 loop  
└─test 252:0    0  1008M  0 crypt 
$ ls -l /dev/mapper/
total 0
lrwxrwxrwx 1 root root       7 Aug 31 08:57 data -> ../dm-0
```

```bash
$ sudo mkfs.ext4 /dev/mapper/data
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 258048 4k blocks and 64512 inodes
Filesystem UUID: a5992282-749c-4e6d-b5cf-294d27e839d9
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
```

```bash
$ sudo mount /dev/mapper/data /mnt/
$ sudo chown -R $USER: /mnt/
```

#### Menutup
```bash
sudo umount /mnt
sudo cryptsetup close data
```

#### Mengakses
```bash
$ sudo cryptsetup open ./data.img data
$ sudo mount /dev/mapper/data /mnt/
```

# Referensi
- https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system
- https://linux.die.net/man/8/losetup
- https://linux.die.net/man/8/cryptsetup
- https://gitlab.com/cryptsetup/cryptsetup/-/wikis/FrequentlyAskedQuestions