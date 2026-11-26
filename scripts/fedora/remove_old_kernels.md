- [DESCRIPTION](#description)

# DESCRIPTION

After a successful upgrade to a new fedora version.
After you boot into the latest kernel and test the system you can remove previous kernels.
Old kernels remain even after dnf autoremove to avoid unintentional removals.

1. Query existing kernels

   ```bash
   rpm -q kernel-core
   dnf repoquery --installonly -q
   rpm -qa | grep -E 'kmod-nvidia|akmod-nvidia' # there should be a corresponding item for each of the core kernels installed
   ```

2. Uninstall all kernel items related to the kernel version you want to remove (leave at least 1 old kernel from the previous fedora versions)

   ```bash
   # e.g.: remove kernel 7.3.4 from fedora 44; leave kernel 7.3.5 from fedora 44 as backup for a few weeks
   sudo dnf remove \
     kernel-7.3.4-200.fc44.x86_64 \
     kernel-core-7.3.4-200.fc44.x86_64 \
     kernel-devel-7.3.4-200.fc44.x86_64 \
     kernel-modules-7.3.4-200.fc44.x86_64 \
     kernel-modules-core-7.3.4-200.fc44.x86_64 \
     kernel-modules-extra-7.3.4-200.fc44.x86_64 \
     kmod-nvidia-7.3.4-200.fc44.x86_64-3:620.73.04-1.fc44.x86_64
   ```

3. Verify removal by re-running commands from step 1

4. Verify NVIDIA driver is active and running

   ```bash
   # look for "Kernel driver in use: nvidia"
   lspci -k | grep -A 3 -i nvidia
   ```
