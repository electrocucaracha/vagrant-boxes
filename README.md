# Vagrant boxes

<!-- markdown-link-check-disable-next-line -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/vagrant-boxes/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

<!-- markdown-link-check-disable-next-line -->

![visitors](https://visitor-badge.laobi.icu/badge?page_id=electrocucaracha.vagrant-boxes)
[![Scc Code Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=code)](https://github.com/boyter/scc/)
[![Scc COCOMO Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=cocomo)](https://github.com/boyter/scc/)

This repository builds Ubuntu Vagrant base boxes for the `libvirt`, `virtualbox`, and `utm` providers.

It contains the Packer templates, provisioning scripts, Vagrant metadata, and the `build.sh` entrypoint used to produce distro-versioned box artifacts plus `metadata.json` files for local publishing or hosted distribution.

## Purpose

The repository provides a repeatable way to create ready-to-use Vagrant boxes for:

- Ubuntu 22.04
- Ubuntu 24.04
- Ubuntu 26.04

The build flow is intentionally narrow in scope so the supported outputs are easier to maintain, validate, and publish.

## Benefits

- **Repeatable builds**: the same templates and provisioning steps can be used every time a box is rebuilt.
- **Provider-ready artifacts**: the output includes `.box` files, checksums, and `metadata.json` for Vagrant consumption.
- **Smaller maintenance surface**: the repository only keeps the distros and providers it actively builds.
- **Consistent guest setup**: the provisioning scripts apply the same user, networking, cleanup, and packaging behavior across builds.
- **Flexible publishing**: artifacts can be consumed locally with `file://` URLs or exposed from a hosted base URL.

## Building

Run:

```bash
./build.sh
```

By default this builds Ubuntu 22.04, 24.04, and 26.04 boxes for the `libvirt` and `virtualbox` providers and writes the published artifacts under `dist/electrocucaracha-boxes/`.

Deployment to `/var/www` is disabled by default. Enable it explicitly with `DEPLOY_WWW=true` if you want `build.sh` to mirror the published artifacts into a web root after the build completes.

If `WWW_ROOT` requires elevated permissions, set `SUDO_CMD` for the deploy step:

```bash
SUDO_CMD=sudo DEPLOY_WWW=true ./build.sh
```

If you want the build to automatically stop conflicting VirtualBox and libvirt
guests before validation, enable:

```bash
CLEANUP_ALL_VMS=true ./build.sh
```

UTM builds are available by selecting `utm` explicitly in `PROVIDERS`. Those builds target Ubuntu arm64 on macOS and emit boxes for the `vagrant_utm` provider plugin.

If a prior UTM build left behind a VM with the same generated name, `build.sh` removes that stale VM before retrying the build.

UTM builds use the forked `electrocucaracha/packer-plugin-utm` release `v4.0.3`, but they now avoid the plugin's flaky VNC-driven ISO install path. Instead, the UTM template imports the official Ubuntu arm64 cloud image for each distro and injects root login settings through a local `cidata` cloud-init seed.

The libvirt and VirtualBox builders continue using the distro-specific `http/ubuntu2204/`, `http/ubuntu2404/`, and `http/ubuntu2604/` NoCloud sources for unattended ISO installs. The UTM-specific `http/ubuntu2204-utm/`, `http/ubuntu2404-utm/`, and `http/ubuntu2604-utm/` directories are now consumed as cloud-init seed media, including a dedicated `network-config` file for the cloud-image workflow.

Libvirt builds perform a preflight KVM probe before invoking Packer so the
script fails fast when `/dev/kvm` is unavailable, inaccessible, or too busy to
create a VM.

Libvirt builds also fail fast when VirtualBox VM processes such as
`VBoxHeadless` or `VirtualBoxVM` are already running on the host, and the error
message includes either a `VBoxManage controlvm ... poweroff` loop for
registered VMs or a `kill <PID>` loop for orphaned VirtualBox processes, both
intended to be run only after confirming that those VMs should be stopped.

```bash
PROVIDERS=utm ./build.sh
```

Before using a generated UTM box with Vagrant, install the provider plugin:

```bash
vagrant plugin install vagrant_utm
```

## Testing

BDD-style shell tests use [ShellSpec](https://github.com/shellspec/shellspec).

Run:

```bash
make test
```

### `build.sh` environment variables

| Name                         | Default value                      | Description                                                                                                                       |
| ---------------------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `DEBUG`                      | `false`                            | Enables shell tracing with `set -o xtrace` when set to `true`.                                                                    |
| `OUTPUT_ROOT`                | `${SCRIPT_DIR}/dist`               | Root directory where published box artifacts and `metadata.json` files are written.                                               |
| `WORK_DIR`                   | `${SCRIPT_DIR}/output`             | Working directory used for intermediate build artifacts before they are moved to the publish directory.                           |
| `VERSION`                    | distro-specific Ubuntu version     | Optional global override for the box version embedded in generated box filenames and metadata.                                    |
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

When `VERSION` is unset, the generated box version follows the Ubuntu release
for each distro, for example `22.04.5`, `24.04.3`, or `26.04`.

Published artifact directories and metadata names use Ubuntu codenames, for
example `ubuntu-jammy`, `ubuntu-noble`, and `ubuntu-resolute`.

With the default namespace, metadata names look like
`electrocucaracha-boxes/ubuntu-jammy`.

When `CLEANUP_ALL_VMS=true`, the build stops running VirtualBox VMs, kills
orphaned VirtualBox processes, and destroys running libvirt domains before the
preflight validation runs.
