- [DESCRIPTION](#description)
- [BACKUP](#backup)
- [ROLLBACK](#rollback)
- [EXTERNAL](#external)
- [REFERENCES](#references)

# DESCRIPTION

Backup strategy.

# BACKUP

1. Create temporary mountpoint

   ```bash
   sudo mkdir -p /mnt/btrfs-top
   ```

2. Mount top-level btrfs tree (id 5)

   ```bash
   # find encrypted disk partition after it has been unlocked (the real phyisical parition is `/dev/nvme0n1p6` - check with lsblk)
   # it'll be `/dev/mapper/luks...`
   sudo btrfs filesystem show /

   # mount top-level tree
   sudo mount -o subvolid=5 /dev/mapper/luks-503a86d9-f195-4d8d-9a76-78ae4f3b7c84 /mnt/btrfs-top/

   # verify mount
   ls -al /mnt/btrfs-top/ # should see `root` and `home`
   sudo btrfs subvolume list / # note `var/lib/machines`
   sudo btrfs subvolume list /mnt/btrfs-top # note `root/var/lib/machines`
   mount | grep btrfs # note `subvolid=` and `subvol=`
   ```

3. Create top-level snapshot subvolume

   ```bash
   sudo btrfs subvolume create /mnt/btrfs-top/snapshots
   sudo btrfs subvolume list /mnt/btrfs-top/
   sudo mkdir -p /mnt/btrfs-top/snapshots/{root,home}
   ls -al /mnt/btrfs-top/ # should see `root`, `home`, `snapshots/{root,home}`
   ```

4. Create/delete snapshots

   ```bash
   # create (read-only)
   sudo btrfs subvolume snapshot -r /mnt/btrfs-top/root/ /mnt/btrfs-top/snapshots/root/<snapshot_name>_$(date +%F_%H_%M)
   sudo btrfs subvolume snapshot -r /mnt/btrfs-top/home/ /mnt/btrfs-top/snapshots/home/<snapshot_name>_$(date +%F_%H_%M)
   sudo btrfs subvolume list /mnt/btrfs-top

   # delete
   sudo btrfs subvolume delete /mnt/btrfs-top/snapshots/root/<snapshot>
   sudo btrfs subvolume delete /mnt/btrfs-top/snapshots/home/<snapshot>
   sudo btrfs subvolume list /mnt/btrfs-top
   ls -al /mnt/btrfs-top/snapshots/root/
   ls -al /mnt/btrfs-top/snapshots/home/
   ```

5. Unmount top-level btrfs after changes have been made

   ```bash
   sudo umount /mnt/btrfs-top
   mount | grep btrfs
   ```

# ROLLBACK

## IN-PLACE ROLLBACK (SYSTEM STILL BOOTS)

This assumes:

- your root is subvolume root
- snapshots live in `snapshots/root/...`
- top-level is mounted at `/mnt/btrfs-top`

1. Mount top-level (temporary admin view)

   ```bash
   sudo mount -o subvolid=5 /dev/mapper/luks-... /mnt/btrfs-top
   ```

2. Identify snapshot

   ```bash
   # e.g.: pre-upgrade-2026-04-30
   ls /mnt/btrfs-top/snapshots/root
   ```

3. Stop modifying system (important)

   ```bash
   # or boot from TTY (CTRL+ALT+F[3...6]; CTRL+ALT+F[1|2|7] -> return to login/desktop session)
   sudo systemctl isolate multi-user.target
   ```

4. Replace current root subvolume

   ```bash
   # rename current root (safety fallback)
   sudo mv /mnt/btrfs-top/root /mnt/btrfs-top/root.broken

   # restore snapshot as new root
   # does not replace anything - just creates a new subvolume - clone snapshot into place - now the snapshot becomes the new root
   sudo btrfs subvolume snapshot /mnt/btrfs-top/snapshots/root/pre-upgrade-2026-04-30 /mnt/btrfs-top/root
   ```

5. Reboot

   ```bash
   # system boots into restored root
   sudo reboot
   ```

## FULL DISASTER RECOVERY (SYSTEM DOES NOT BOOT)

This is your LiveUSB scenario.

1. Boot LiveUSB
2. Unlock disk
   ```bash
   sudo cryptsetup open /dev/nvme0n1p6 cryptroot
   ```
3. Ensure correct boot config
   ```bash
   # usually unchanged if same subvolume structure.
   cat /mnt/btrfs-top/root/etc/fstab
   ```
4. Execute steps 1 to 5 from [above](#in-place-rollback-system-still-boots)

## RESTORING A SINGLE FILE (SAFER ALTERNATIVE)

Instead of full rollback:

```bash
cp /mnt/btrfs-top/snapshots/root/.../etc/xyz /mnt/btrfs-top/root/etc/xyz
```

## IMPORTANT

- you are not editing snapshots
- you are replacing subvolumes

Snapshots are immutable (if created with -r).

Best practice recommendation for your setup:

- snapshots for rollback points
- external backup (btrfs send) for disaster recovery layer

# EXTERNAL

## FORMAT EXTERNAL DRIVE AS BTRFS

1. Identify device

   ```bash
   lsblk -f
   ```

2. Wipe existing partition table

   ```bash
   # if `lsblk -f` still shows the device as `ntfs` then old filesystem signatures remain inside the partition itself, not just the disk header
   # in that case wipe the partition too: `sudo wipefs -a /dev/sda1`
   sudo wipefs -a /dev/sda
   ```

3. Create a new GPT table

   ```bash
   sudo parted /dev/sda -- mklabel gpt
   ```

4. Create one large partition

   ```bash
   sudo parted /dev/sda -- mkpart primary 1MiB 100%
   lsblk -f
   ```

5. Encrypt drive

   ```bash
   sudo cryptsetup --force-password luksFormat /dev/sda1
   sudo cryptsetup open /dev/sda1 external_crypt
   ```

6. Format as `btrfs`

   ```bash
   sudo mkfs.btrfs -L external_data /dev/mapper/external_crypt

   # verify
   lsblk -f
   # /dev/sda1          crypto_LUKS
   # └─external_crypt   btrfs  external_data
   ```

7. Mount it somewhere

   ```bash
   sudo mkdir -p /mnt/external
   sudo mount /dev/mapper/external_crypt /mnt/external/
   ```

8. Create subvolumes

   ```bash
   sudo btrfs subvolume create /mnt/external/files
   sudo btrfs subvolume create /mnt/external/fedora_backups
   ```

9. Copy your files into external drive using rsync

   ```bash
   sudo rsync -avh --progress ~/Downloads/ /mnt/external/files/
   du -sh ~/Downloads
   du -sh /mnt/external/files
   ```

## MOUNT

In case you've umounted manually because otherwise the system automatically mounts to `/run/media/andres/...`.

```bash
sudo cryptsetup open /dev/sda1 external_crypt
sudo mount /dev/mapper/external_crypt /mnt/external
```

## SEND SNAPSHOTS TO EXTERNAL DRIVE

```bash
# mount top-level btrfs tree
sudo mount -o subvolid=5 /dev/mapper/luks-... /mnt/btrfs-top/

# create subdirs in external drive
sudo mkdir -p /run/media/andres/FEDORA_BACKUP/snapshots/{root,home}

# first time send
sudo btrfs send /mnt/btrfs-top/snapshots/root/<snapshot_name> | sudo btrfs receive /run/media/andres/FEDORA_BACKUP/snapshots/{root,home}/

# verify with UUID - Received UUID of the one in external drive should be the same as UUID of the original one
sudo btrfs subvolume show /mnt/btrfs-top/snapshots/root/root_2026-04-30_17_09/
sudo btrfs subvolume show /run/media/andres/FEDORA_BACKUP/snapshots/root/root_2026-04-30_17_09/

# incremental send
sudo btrfs send -p OLD_SNAPSHOT NEW_SNAPSHOT | btrfs receive DEST
```

## UMOUNT

```bash
sudo umount /mnt/external
sudo cryptsetup close external_crypt
```

# REFERENCES

- [Btrfs Official Docs](https://btrfs.readthedocs.io/en/latest/#)
- [Get Started with the Btrfs File System on Oracle Linux](https://www.youtube.com/watch?v=oJozWsiEVrQ)
- [Btrfs Subvolumes and Snapshots on Oracle Linux](https://www.youtube.com/watch?v=qUmtqbX1qRQ)
