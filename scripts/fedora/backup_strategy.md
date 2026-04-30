- [DESCRIPTION](#description)
- [LOCAL](#local)
- [EXTERNAL](#external)
- [REFERENCES](#references)

# DESCRIPTION

Backup strategy: local and external.

# LOCAL

- Local snapshot-based backup strategy
- Use snapper + DNF pre/post action hooks to take automatic snaphots for root `/`.
- DNF pre/post hooks activates on DNF5 transactions that trigger:
  - pre_transaction
  - post_transaction

So any command that performs a real package transaction can trigger it.

Typical commands that trigger snapshots

```bash
sudo dnf upgrade
sudo dnf upgrade --refresh
sudo dnf install vim
sudo dnf remove firefox
sudo dnf reinstall bash
sudo dnf distro-sync
sudo dnf downgrade package
sudo dnf group install ...
sudo dnf autoremove
```

Because they modify the RPM database / installed packages.

## INSTALL DEPS

```bash
sudo dnf install snapper libdnf5-plugin-actions
```

## CREATE DNF PRE/POST HOOK

- Only runs for `root` config.
- DNF pre/post snapshots do NOT include `/home` because there is a lot of constant noise in this subvolume; create on a per-need basis
- Command 'rollback' cannot be used on a non-root subvolume /home - therefore just use for browsing old versions, selective restore - Use btrbk for full backup/restore.
- `snapper rollback` is intended for root filesystem rollbacks.

```bash
sudo bash -c "cat > /etc/dnf/libdnf5-plugins/actions.d/snapper.actions" <<'EOF'
# Get snapshot description
pre_transaction::::/usr/bin/sh -c echo\ "tmp.cmd=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"

# Creates pre snapshot before the transaction and stores the snapshot number in the "tmp.snapper_pre_number"  variable.
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -c\ number\ -p\ -d\ '${tmp.cmd}')"

# If the variable "tmp.snapper_pre_number" exists, it creates post snapshot after the transaction and removes the variable "tmp.snapper_pre_number".
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ --pre-number\ "${tmp.snapper_pre_number}"\ -c\ number\ -d\ "${tmp.cmd}"\ ;\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.cmd
EOF

sudo cat /etc/dnf/libdnf5-plugins/actions.d/snapper.actions
```

## CREATEA SNAPPER CONFIGS

```bash
sudo snapper -c root create-config /
sudo snapper -c home create-config /home
sudo snapper list-configs
sudo ls -al /.snapshots
sudo ls -al /home/.snapshots/
```

## RESTORE THE CORRECT SELINUX CONTEXTS FOR THE .SNAPSHOTS DIRECTORIES

```bash
sudo restorecon -RFv /.snapshots
sudo restorecon -RFv /home/.snapshots
```

### VERIFY SELINUX LABELS: THEY ALL SHOULD HAVE `SNAPPERD_DATA_T`

```bash
ls -1dZ /.snapshots /home/.snapshots
```

## VERIFY CORRESPONDING SUBVOLUMES: SHOULD SEE `PATH .SNAPSHOTS` AND `PATH HOME/.SNAPSHOTS`

```bash
sudo btrfs subvolume list /
```

## VERIFY SNAPSHOTS

```bash
sudo snapper -c root ls
sudo snapper -c home ls
```

## ENABLE SNAPSHOT CLEANUP SERVICE

This service runs periodically to clean up snapshots based on retention policies defined for each snapper config;
since we disable the time-based policy below, the cleanup service runs accordingly only to the number-based policy we modify below.

```bash
sudo systemctl enable --now snapper-cleanup.timer
sudo systemctl status snapper-cleanup.timer
systemctl list-timers snapper-cleanup.timer
```

### ENABLE TIME-BASED SNAPSHOT CREATION SERVICE (OPTIONAL)

```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl status snapper-timeline.timer
```

### DISABLE TIME-BASED SNAPSHOTS

Would need the service `snapper-timeline.timer` to be enabled if switched to `yes`.

```bash
sudo snapper -c root set-config TIMELINE_CREATE=no TIMELINE_CLEANUP=no
sudo snapper -c home set-config TIMELINE_CREATE=no TIMELINE_CLEANUP=no
```

### MODIFY RETENTION POLICY

- Retain a max of 10 normal and 5 important snapshots; the cleanup service removes old ones according to this
- Important snapshots are have to be created with a special flag (see docs); most of the time we only deal with regular ones

```bash
sudo snapper -c root set-config NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5
sudo snapper -c home set-config NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5
```

### VERIFY CONFIG CHANGES

```bash
sudo cat /etc/snapper/configs/root
sudo cat /etc/snapper/configs/home
```

## WORK FLOWS

### DNF PRE/POST HOOK + SNAPSHOTS (`ROOT`)

```bash
sudo dnf upgrade --refresh
sudo snapper -c root list
sudo snapper -c root status 1..2
sudo ls -al /.snapshots
sudo snapper -c root rollback <SNAP_ID>
sudo systemctl reboot
```

### MANUAL SNAPSHOTS (`HOME`)

```bash
sudo snapper -c home create -d "sample"
sudo ls -al /home/.snapshots
sudo snapper -c home status 0..1
sudo snapper undochange 0..1
sudo snapper undochange 1..0
sudo snapper -c home remove 1
sudo snapper -c home ls

# e.g.: sudo cp -a /home/.snapshots/1/snapshot/andres/.bashrc /home/andres/.bashrc
# Using -a helps preserve original ownership
```

## DIFFERENCE BETWEEN SNAPPER `ROLLBACK` AND `UNDOCHANGE`

The primary difference between snapper rollback and snapper undochange lies in their scope and implementation: rollback performs a subvolume swap to restore the entire system state, while undochange performs a file-level restoration of specific changes.

System Rollback (snapper rollback): This command sets a previous snapshot as the default subvolume. It is an atomic operation that reverts the root filesystem, kernel, and bootloader configuration simultaneously. This is the preferred method for full system recovery (e.g., after a failed update) on distributions like openSUSE, as it ensures consistency across the entire root subvolume.

Undo Changes (snapper undochange): This command compares two snapshots and reverts specific file modifications between them without changing the default subvolume. It is useful for selective restoration (e.g., undoing a single package installation or config change) but may leave the package manager database out of sync with the filesystem state. On some systems, using undochange on the root filesystem without subsequent package manager synchronization can lead to boot issues.

In summary, use rollback for disaster recovery and full system reverts, and undochange for granular, file-level corrections where a full system reboot is undesirable.

# EXTERNAL

-

# REFERENCES

- [BTRFS Official Docs](https://btrfs.readthedocs.io/en/latest/#)
- [Btrfs Subvolumes and Snapshots on Oracle Linux](https://www.youtube.com/watch?v=qUmtqbX1qRQ)
- [Fedora 44: Snapper + Rollback Setup](https://www.youtube.com/watch?v=d-CafjZf2M4)
- [Snapper + DNF hooks](https://sysguides.com/install-fedora-42-with-snapshot-and-rollback-support#5-set-up-snapper-grubbtrfs-and-btrfs-assistant)
