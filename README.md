# nixos-config

NixOS flake with Home Manager. niri + Noctalia v5 on NVIDIA, CachyOS kernel and
CachyOS system tuning, CachyOS's gaming package set, Zed with Python, Rust and R.

Evaluated against nixos-unstable of 2026-11-07 (kernel 7.3.1-cachyos, NVIDIA
595.112, niri 26.04, Noctalia 5.4.1).

## Layout

```
flake.nix                    inputs, binary caches, host builder (mkHost)
vars.nix                     username, locale, keyboard, stateVersion
hosts/desktop/               i7-14700K + RTX 4070 SUPER
  default.nix                CachyOS kernel flavour, microcode, Plasma toggle
  hardware-configuration.nix PLACEHOLDER, replace with /etc/nixos's after installing
  filesystems.nix            btrfs mount options for the graphical installer's layout
  vm.nix                     QEMU test VM overrides (build-vm only)
  disko.nix                  alternative declarative layout (not imported)
modules/nixos/               system level
  core/boot.nix              Limine
  core/btrfs.nix             monthly scrub, snapper on /home
  core/                      nix + caches, locale, network, audio, users
  hardware/nvidia.nix        driver, VA-API, niri VRAM fix, nova_core blacklist
  kernel/cachyos.nix         xddxdd/nix-cachyos-kernel overlay
  kernel/tweaks.nix          cachyos-settings: sysctls, zram, ananicy, scx, ntsync
  desktop/                   niri, Noctalia services, optional Plasma, greetd/tuigreet, fonts
  gaming/                    Steam + Proton-CachyOS, launchers, Wine, gamescope
  dev.nix                    nix-ld
home/                        Home Manager (user level)
  shell.nix                  bash -> fish handoff, fastfetch hook, starship, git, gh, CLI tools
  btrfs.nix                  Steam/Games as nested subvolumes (kept out of snapshots)
  desktop/niri/config.kdl    niri config (validated at build time)
  desktop/noctalia.nix       Noctalia settings + systemd user service
  desktop/apps.nix           Zen browser, nautilus, GTK theme
  desktop/kitty.nix          kitty (Noctalia colours) + fastfetch
  editor/zed.nix             Zed, LSPs from nixpkgs
  dev/{python,rust,r}.nix    toolchains
```

## Disk layout

With "btrfs" picked, the graphical installer creates a 1 GiB ESP at `/boot`
and one btrfs partition with the root at the top level and two subvolumes:

| Subvolume | Mounted at | Notes |
|---|---|---|
| top level | `/` | |
| `home` | `/home` | hourly snapper snapshots |
| `nix` | `/nix` | store, never snapshotted |

`filesystems.nix` adds `compress=zstd:1,noatime` to all three (the generated
hardware file only records the subvolumes). On first boot, systemd creates
`/home/.snapshots` (snapper's storage) and `~/.local/share/Steam` and
`~/Games` as nested subvolumes, so game files never get pinned by `/home`
snapshots. No swap: zram covers it. Limine keeps a kernel + initrd per
generation on the ESP; 1 GiB fits the 10 generations it is capped at.

## CachyOS gaming packages, mapped

| CachyOS | Here |
|---|---|
| steam, lib32 libs | `programs.steam` (FHS env with 32-bit libs) |
| proton-cachyos-slr | `proton-cachy` flake input, in `extraCompatPackages` |
| protontricks | `programs.steam.protontricks` |
| wine-cachyos-opt, winetricks | `wineWow64Packages.staging`, `winetricks` |
| umu-launcher | `umu-launcher` |
| vulkan-tools | `vulkan-tools`, `mesa-demos` |
| lutris, heroic, faugus-launcher | same names |
| mangohud, goverlay | same names |
| gamescope | `programs.gamescope` |
| cachyos-settings, ananicy rules | `modules/nixos/kernel/tweaks.nix` |

Extras not in the CachyOS metas: Proton-GE, ProtonPlus, GameMode, controller udev rules.

## Install (graphical installer, then rebuild into this flake)

The installer only has to produce a bootable base system with the right disk
layout and user; the first rebuild replaces everything else (desktop,
bootloader, kernel).

In the BIOS first: Secure Boot off (Limine is unsigned here), and primary
display set to the PCIe GPU. The 14700K's iGPU is fine to keep for Quick Sync,
but niri must not pick it as its render device.

### 1. Run the installer

Boot the graphical ISO (GNOME or Plasma, same installer) and pick:

- **Users**: username `gabriel`, i.e. the same as `vars.username`. The password
  set here is kept.
- **Desktop**: "No desktop". Anything chosen here is replaced at the first rebuild.
- **Partitions**: "Erase disk", file system **btrfs**, swap **"No swap"**.
  Encryption is optional. If you enable it, check after install that
  `/etc/nixos/hardware-configuration.nix` contains `boot.initrd.luks.devices`,
  since that file is the only one carried over.

Reboot and log in on the text console.

### 2. Get the config from the private repo

Wired network works out of the box; for Wi-Fi run `nmtui`.

```sh
nix-shell -p git gh
gh auth login            # GitHub.com, HTTPS, "Login with a web browser":
                         # open the URL on your phone and enter the code
gh repo clone legabgob/nixos-config-vibe ~/nixos-config
cd ~/nixos-config
```

### 3. Bring in the machine-specific bits

```sh
cp /etc/nixos/hardware-configuration.nix hosts/desktop/
grep stateVersion /etc/nixos/configuration.nix   # must match vars.stateVersion
nix --extra-experimental-features "nix-command flakes" flake lock   # pins inputs, as you
git add -A                                       # flakes only see tracked files
```

Creating `flake.lock` here, as your user, matters: otherwise the root build in
step 4 would create it, owned by root.

### 4. First rebuild

```sh
sudo nixos-rebuild boot --flake path:.#desktop --option accept-flake-config true
reboot
```

Why this exact form, for this first build only:

- `boot` rather than `switch`, since kernel and bootloader change.
- `path:.` because Nix, running as root, refuses to read a git repository
  owned by your user ("repository path ... is not owned by current user").
  `path:` reads the folder as plain files, so the `git add` above is not even
  needed for this one build.
- `accept-flake-config` lets this build use the CachyOS-kernel and Noctalia
  binary caches before `nix.settings` has installed them.

Expect a long first build (large download, and the NVIDIA module is compiled
for the CachyOS kernel). You land in Limine, then tuigreet, then niri.

From then on, rebuild with `nh os switch` (alias `rebuild`) as your user: nh
evaluates and builds as you (no ownership problem; the caches are configured
system-wide and `@wheel` is a trusted user) and only uses sudo to activate.

Commit and push the hardware file and the lock file. git now has your name and
email, and gh is git's credential helper, from Home Manager:

```sh
cd ~/nixos-config && git commit -m "desktop: hardware configuration, lock" && git push
```

### 5. Optional cleanup

The installer's systemd-boot is still on the ESP and in the firmware boot menu.
Once Limine has booted fine:

```sh
sudo bootctl remove
sudo rm -rf /boot/EFI/nixos /boot/loader
```

Day to day: edit, `rebuild` (or `update` to also bump flake inputs), commit,
push. New files must be `git add`ed before nh can see them.

### Alternative: disko

For a fully declarative reinstall from the minimal ISO (flat `@`/`@home`/
`@nix`/`@log` layout, 2 GiB ESP), `hosts/desktop/disko.nix` describes the disk.
In `hosts/desktop/default.nix`, import `./disko.nix` instead of
`./filesystems.nix`, set `device` in `disko.nix` to the drive's
`/dev/disk/by-id/` name, then from the ISO (**wipes that drive**):

```sh
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#desktop
sudo nixos-generate-config --no-filesystems --show-hardware-config > hosts/desktop/hardware-configuration.nix
git add -A
sudo nixos-install --flake .#desktop --option accept-flake-config true
sudo nixos-enter --root /mnt -c 'passwd gabriel'
```

## Testing in a VM (from another Linux install, e.g. CachyOS)

`hosts/desktop/vm.nix` adds a QEMU variant of this exact system. It boots the
CachyOS kernel, greetd, niri, Noctalia, Home Manager and all the apps. It does
not test the NVIDIA driver (the VM gets a virtual GPU with Mesa instead),
Limine or the btrfs layout (the VM boots its kernel directly from a plain disk
image), or the two-monitor layout. The real system is unaffected by this file.

1. Install Nix on the host and let your user talk to the daemon:

   ```sh
   sudo pacman -S nix
   sudo systemctl enable --now nix-daemon.socket
   sudo usermod -aG nix-users $USER     # then log out and back in
   ```

2. Enable flakes and the two extra binary caches (otherwise the CachyOS kernel
   and Noctalia compile locally). Append to `/etc/nix/nix.conf`, then
   `sudo systemctl restart nix-daemon`:

   ```
   experimental-features = nix-command flakes
   extra-substituters = https://cache.lantian.pub/lantian https://noctalia.cachix.org
   extra-trusted-public-keys = lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ= noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=
   ```

3. Build the VM from a clone of this repo. Everything comes from binary caches;
   the store grows by roughly 20 GB.

   ```sh
   nix build .#nixosConfigurations.desktop.config.system.build.vm
   ```

4. Run it. Nix-built QEMU cannot find the host's NVIDIA OpenGL libraries on its
   own, and the virtual GPU needs them, so start it through nixGL:

   ```sh
   nix run --impure github:nix-community/nixGL -- ./result/bin/run-desktop-vm
   ```

   Log in as `gabriel` with password `vm`. Press Ctrl+Alt+G to grab keyboard
   and mouse, so Super shortcuts go to niri instead of the host desktop; press it
   again to release them.

5. State (home directory, settings) lives in `desktop.qcow2` in the directory
   you started it from. Delete that file for a fresh VM. To free the space
   afterwards: `rm result desktop.qcow2 && nix-collect-garbage -d`.

If the window stays black, nixGL could not set up the host driver. As a slow
fallback, replace the two display lines in `vm.nix` with `"-device virtio-vga"`
and `"-display gtk"` (software rendering), rebuild, and run
`./result/bin/run-desktop-vm` directly.

## Kernel

The host uses `linuxPackages-cachyos-latest-lto-x86_64-v3`, which matches
CachyOS's default kernel (EEVDF, Clang ThinLTO) built for x86-64-v3, the highest
level Raptor Lake supports (it has AVX2 but no AVX-512). If an out-of-tree module
ever fails to build against the LTO kernel, switch to the GCC build
`linuxPackages-cachyos-latest-x86_64-v3` in `hosts/desktop/default.nix`.

## Shell, terminal, browser

The login shell stays bash and every interactive bash hands over to fish (the
approach the NixOS wiki recommends over `users.users.<name>.shell = pkgs.fish`).
`nix-your-shell` makes `nix develop` / `nix-shell` open fish too. `bash --norc`
gets you a plain bash.

kitty is the terminal. Every new kitty window runs fastfetch once; shells
started inside it (`nix develop`, a nested fish) and other terminals, such as
Zed's, do not. kitty's colours come from the Noctalia palette and update live
when the theme changes.

Zen is the browser (from `github:0xc000022070/zen-browser-flake`, binary
`zen-beta`) and is set as the default for web links and HTML files. Telemetry,
studies, Pocket and its own updater are disabled by policy.

## Things to check after the first boot

- `nvidia-smi` shows the 4070 SUPER. If niri renders on the iGPU, add
  `render-drm-device "/dev/dri/renderD129"` (the NVIDIA node, see
  `ls -l /dev/dri/by-path`) to the `debug {}` block in `config.kdl`.
- Monitors: run `niri msg outputs`, put the two connector names into
  `vars.monitors`, rebuild. The rebuild prints a warning until you do. If the
  portrait screen is upside down, change its `transform` to `"270"`.
- `snapper -c home list` after an hour shows the first timeline snapshot.
- niri releases after 26.04 output 10-bit colour by default. If a future update
  leaves a screen black or white on this Intel + NVIDIA machine, add
  `disable-10bit-output` to the `debug {}` block.

## Monitors and HDR

The OLED (right, main, 280 Hz) and the portrait LCD (left, 180 Hz) are laid
out in the `output` blocks of `config.kdl`: highest refresh rate at 1440p,
portrait rotation and single-column layout on the LCD, on-demand VRR for games
on the OLED, hot corners on the outer edges. Noctalia's bar auto-hides on the
OLED except on empty workspaces to limit static content (burn-in).

niri has no HDR or colour management (as of 26.04 and its main branch in
November 2026), so both screens run in SDR under niri.

### Optional Plasma session for HDR

`modules/nixos/desktop/plasma.nix` adds KDE Plasma 6 as a second login session.
It is off. To turn it on, set `my.desktop.plasma.enable = true;` in
`hosts/desktop/default.nix` and rebuild. At the login screen, F3 lists the
sessions; tuigreet remembers the last one, so use F3 again to return to niri.
Setting it back to `false` and rebuilding removes Plasma again.

Inside Plasma:

- Set rotation, positions, refresh rates and HDR once in System Settings >
  Display & Monitor. Plasma stores this itself; niri's config is not used there.
- Noctalia does not start there (it is bound to `niri.service`); Plasma's own
  panel, notifications and polkit agent take over.
- Steam games with HDR through Proton's Wayland driver, as launch options:
  `PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 %command%`
  (Proton-CachyOS and Proton-GE support both). The alternative is nested
  gamescope: `gamescope --hdr-enabled -W 2560 -H 1440 -r 280 -- %command%`.

## Keybinds (niri)

Mod is Super. `Mod+Shift+/` shows them all.

| Keys | Action |
|---|---|
| Mod+Return / Mod+T | kitty |
| Mod+Space / Mod+D | Noctalia launcher |
| Mod+S | control center |
| Mod+Shift+, | Noctalia settings |
| Mod+Alt+V | clipboard history |
| Mod+Alt+L | lock |
| Mod+Shift+E | session menu |
| Mod+E / Mod+B / Mod+Z | files / Zen / zed |
| Mod+Q | close window |
| Mod+O | overview |
| Mod+Escape | release shortcuts to a game/VM |

## Language toolchains

Global toolchains are for quick work. For projects, put a `flake.nix` devShell in
the repo and `echo "use flake" > .envrc && direnv allow`. Zed picks up the
direnv environment (`load_direnv = "shell_hook"`).

- Python: `python3` with the scientific stack, `uv` for venvs (wheels work via nix-ld).
- Rust: stable from nixpkgs. Swap in `rustup` if you need nightly.
- R: packages are declared in `home/dev/r.nix`; `install.packages()` will not
  persist. `radian` is the nicer console.
