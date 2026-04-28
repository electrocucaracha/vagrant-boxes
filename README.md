# Vagrant boxes

<!-- markdown-link-check-disable-next-line -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/vagrant-boxes/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

<!-- markdown-link-check-disable-next-line -->

![visitors](https://visitor-badge.laobi.icu/badge?page_id=electrocucaracha.vagrant-boxes)
[![Scc Code Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=code)](https://github.com/boyter/scc/)
[![Scc COCOMO Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=cocomo)](https://github.com/boyter/scc/)

This repository builds Ubuntu Vagrant base boxes for the `libvirt`, `virtualbox`, and `utm` providers.

It contains the Packer templates, provisioning scripts, Vagrant metadata, and the `build.sh` entrypoint used to produce versioned box artifacts plus `metadata.json` files for local publishing or hosted distribution.

## Purpose

The repository provides a repeatable way to create ready-to-use Vagrant boxes for:

- Ubuntu 22.04
- Ubuntu 24.04

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

By default this builds Ubuntu 22.04 and 24.04 boxes for the `libvirt` and `virtualbox` providers and writes the published artifacts under `dist/generic/`.

Deployment to `/var/www` is disabled by default. Enable it explicitly with `DEPLOY_WWW=true` if you want `build.sh` to mirror the published artifacts into a web root after the build completes.

UTM builds are available by selecting `utm` explicitly in `PROVIDERS`. Those builds target Ubuntu arm64 on macOS and emit boxes for the `vagrant_utm` provider plugin.

If a prior UTM build left behind a VM with the same generated name, `build.sh` removes that stale VM before retrying the build.

UTM builds use the forked `electrocucaracha/packer-plugin-utm` release `v4.0.3`, which carries the ISO-first boot-order fix and waits for autoinstall to power off before ejecting the installer ISO and rebooting from the installed disk.

```bash
PROVIDERS=utm ./build.sh
```

Before using a generated UTM box with Vagrant, install the provider plugin:

```bash
vagrant plugin install vagrant_utm
```

### `build.sh` environment variables

| Name           | Default value           | Description                                                                                              |
| -------------- | ----------------------- | -------------------------------------------------------------------------------------------------------- |
| `DEBUG`        | `false`                 | Enables shell tracing with `set -o xtrace` when set to `true`.                                           |
| `OUTPUT_ROOT`  | `${SCRIPT_DIR}/dist`    | Root directory where published box artifacts and `metadata.json` files are written.                      |
| `WORK_DIR`     | `${SCRIPT_DIR}/output`  | Working directory used for intermediate build artifacts before they are moved to the publish directory.  |
| `VERSION`      | `4.3.12`                | Box version embedded in generated box filenames and metadata.                                            |
| `BOX_BASE_URL` | empty                   | Base URL used in generated metadata box URLs. When unset, metadata uses local `file://` URLs.            |
| `DEPLOY_WWW`   | `false`                 | When set to `true`, copies the published `${BOX_NAMESPACE}` tree into `WWW_ROOT` after the build finishes. |
| `WWW_ROOT`     | `/var/www`              | Destination root used when `DEPLOY_WWW=true`. The build publishes into `${WWW_ROOT}/${BOX_NAMESPACE}`. |
| `PACKER_GETTER_READ_TIMEOUT` | `90m`     | Read timeout used by Packer's downloader for large remote assets such as Ubuntu ISOs. Increase it on slower networks. |
| `UTM_PACKER_PLUGIN_SOURCE` | `github.com/electrocucaracha/utm` | Packer plugin source used for UTM builds. Override to test another compatible fork or release source. |
| `UTM_PACKER_PLUGIN_VERSION` | `v4.0.3` | Version of the forked UTM Packer plugin installed for UTM builds. |
| `DISTROS`      | `ubuntu2204 ubuntu2404` | Comma- or space-separated list of distro identifiers to build. Supported values are `ubuntu2204` and `ubuntu2404`. |
| `PROVIDERS`    | `libvirt virtualbox`    | Comma- or space-separated list of providers to build. Supported values are `libvirt`, `virtualbox`, and `utm`.     |
