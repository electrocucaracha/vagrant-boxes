# Contributing

This repository builds and publishes Ubuntu Vagrant base boxes for a maintained
set of distros and providers. This guide covers the contributor-facing workflow.

## Prerequisites

The build script requires these commands on every platform:

- `jq`
- `packer`
- `realpath`
- `sha256sum`
- `vagrant`

Provider-specific requirements depend on the selected `PROVIDERS` value:

| Provider     | Additional requirements                                                                      |
| ------------ | -------------------------------------------------------------------------------------------- |
| `libvirt`    | `qemu-system-x86_64`, `virsh`, KVM access, the HashiCorp `qemu` and `vagrant` Packer plugins |
| `virtualbox` | `VBoxManage`, the HashiCorp `virtualbox` and `vagrant` Packer plugins                        |
| `utm`        | `utmctl`, macOS, and the configured UTM Packer plugin source and version                     |

`build.sh` installs the required Packer plugins automatically when they are
missing.

## Build boxes

Run:

```bash
./build.sh
```

By default, this builds Ubuntu 22.04, 24.04, and 26.04 boxes for the
`libvirt` and `virtualbox` providers and publishes the results under
`dist/electrocucaracha-boxes/`.

### Common build variants

Build only UTM boxes:

```bash
PROVIDERS=utm ./build.sh
```

Override the distro list:

```bash
DISTROS="ubuntu2204 ubuntu2404" ./build.sh
```

Use a hosted base URL in generated metadata:

```bash
BOX_BASE_URL=https://example.invalid/releases ./build.sh
```

Copy the published artifact tree into a web root:

```bash
SUDO_CMD=sudo DEPLOY_WWW=true ./build.sh
```

Clean up conflicting VirtualBox and libvirt VMs before validation:

```bash
CLEANUP_ALL_VMS=true ./build.sh
```

## Testing

BDD-style shell tests use [ShellSpec](https://github.com/shellspec/shellspec).

Run:

```bash
make test
```

## Build behavior

- Default distros are `ubuntu2204`, `ubuntu2404`, and `ubuntu2604`.
- Default providers are `libvirt` and `virtualbox`.
- UTM builds are opt-in through `PROVIDERS=utm`.
- Libvirt and VirtualBox builds publish `x64` box filenames and `amd64`
  metadata entries.
- UTM builds publish `arm64` box filenames and `arm64` metadata entries.
- When `VERSION` is unset, generated box versions follow the distro-specific
  Ubuntu release:
  - `ubuntu2204` -> `22.04.5`
  - `ubuntu2404` -> `24.04.3`
  - `ubuntu2604` -> `26.04`
- Published metadata names use Ubuntu codenames such as `ubuntu-jammy`,
  `ubuntu-noble`, and `ubuntu-resolute`.

### Validation and cleanup

Before a build starts:

- libvirt builds fail fast when `/dev/kvm` is unavailable, inaccessible, or too
  busy to create a VM
- libvirt builds fail fast when VirtualBox VM processes are already running
- VirtualBox builds fail fast when running VirtualBox VMs are detected

When `CLEANUP_ALL_VMS=true`, the build attempts to stop running VirtualBox VMs,
kill orphaned VirtualBox processes, and destroy running libvirt domains before
validation continues.

### Provider-specific notes

#### libvirt and VirtualBox

The libvirt and VirtualBox builders use distro-specific NoCloud data from:

- `http/ubuntu2204/`
- `http/ubuntu2404/`
- `http/ubuntu2604/`

#### UTM

UTM builds target Ubuntu arm64 on macOS and emit boxes for the `vagrant_utm`
provider plugin.

If a prior UTM build left behind a VM with the same generated name, `build.sh`
removes that stale VM before retrying the build.

UTM builds use the forked `electrocucaracha/packer-plugin-utm` release
`v4.0.3`, but avoid the plugin's VNC-driven ISO install path. Instead, the UTM
template imports the official Ubuntu arm64 cloud image for each distro and
injects root login settings through a local `cidata` cloud-init seed.

The UTM-specific cloud-init seed directories are:

- `http/ubuntu2204-utm/`
- `http/ubuntu2404-utm/`
- `http/ubuntu2604-utm/`

## `build.sh` environment variables

| Name                         | Default value                      | Description                                                                                                                       |
| ---------------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `DEBUG`                      | `false`                            | Enables shell tracing with `set -o xtrace` when set to `true`.                                                                    |
| `OUTPUT_ROOT`                | `${SCRIPT_DIR}/dist`               | Root directory where published box artifacts and `metadata.json` files are written.                                               |
| `WORK_DIR`                   | `${SCRIPT_DIR}/output`             | Working directory used for intermediate build artifacts before they are moved to the publish directory.                           |
| `VERSION`                    | distro-specific Ubuntu version     | Optional global override for the box version embedded in generated filenames and metadata.                                        |
| `BOX_NAMESPACE`              | `electrocucaracha-boxes`           | Published namespace used in output paths and metadata names.                                                                      |
| `BOX_BASE_URL`               | empty                              | Base URL used in generated metadata box URLs. When unset, metadata uses local `file://` URLs.                                     |
| `CLEANUP_ALL_VMS`            | `false`                            | When set to `true`, cleans up conflicting host VMs before validation.                                                             |
| `DEPLOY_WWW`                 | `false`                            | When set to `true`, copies the published `${BOX_NAMESPACE}` tree into `WWW_ROOT` after the build finishes.                        |
| `WWW_ROOT`                   | `/var/www`                         | Destination root used when `DEPLOY_WWW=true`. The build publishes into `${WWW_ROOT}/${BOX_NAMESPACE}`.                            |
| `SUDO_CMD`                   | empty                              | Optional privilege command used only for the deploy step, for example `sudo` or `sudo -n`, when `WWW_ROOT` is not writable.       |
| `PACKER_GETTER_READ_TIMEOUT` | `90m`                              | Read timeout used by Packer's downloader for large remote assets such as Ubuntu ISOs. Increase it on slower networks.             |
| `UTM_PACKER_PLUGIN_SOURCE`   | `github.com/electrocucaracha/utm`  | Packer plugin source used for UTM builds. Override to test another compatible fork or release source.                             |
| `UTM_PACKER_PLUGIN_VERSION`  | `v4.0.3`                           | Version of the forked UTM Packer plugin installed for UTM builds.                                                                 |
| `DISTROS`                    | `ubuntu2204 ubuntu2404 ubuntu2604` | Comma- or space-separated list of distro identifiers to build. Supported values are `ubuntu2204`, `ubuntu2404`, and `ubuntu2604`. |
| `PROVIDERS`                  | `libvirt virtualbox`               | Comma- or space-separated list of providers to build. Supported values are `libvirt`, `virtualbox`, and `utm`.                    |
