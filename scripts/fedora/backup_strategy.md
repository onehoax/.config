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

## CREATE BTRFS PARTITION ON EXTERNAL DRIVE

Assuming you have an external drive which is part `nfts` for access from different systems and some unallocated space to create the `btrfs` partition.

1. Check free space

   ```bash
   sudo parted /dev/sda print free
   ```

2. Create the new parition

   ```bash
   sudo parted /dev/sda

   # inside parted - `mkpart TYPE START END` -> 476GB is the correct start boundary of the free region, not the amount of free space
   (parted) mkpart primary btrfs 476GB 100%
   (parted) quit

   # verify
   lsblk -f
   ```

3. Format as `btrfs`

   ```bash
   sudo mkfs.btrfs -L FEDORA_BACKUP /dev/sda2

   # reboot so you don't have to mount manually
   sudo systemctl reboot

   # verify
   lsblk -f
   ```

4. Send snapshots to external drive

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

# REFERENCES

- [Btrfs Official Docs](https://btrfs.readthedocs.io/en/latest/#)
- [Get Started with the Btrfs File System on Oracle Linux](https://www.youtube.com/watch?v=oJozWsiEVrQ)
- [Btrfs Subvolumes and Snapshots on Oracle Linux](https://www.youtube.com/watch?v=qUmtqbX1qRQ)
