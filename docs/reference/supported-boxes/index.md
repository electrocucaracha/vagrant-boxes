# Supported boxes

This reference lists the distro names,
published box names,
providers,
and architectures used by this project.

## Distros and box names

<!-- markdownlint-disable MD013 -->

| Distro ID    | Published box name                       | Ubuntu release        | Default box version |
| ------------ | ---------------------------------------- | --------------------- | ------------------- |
| `ubuntu2204` | `electrocucaracha-boxes/ubuntu-jammy`    | Ubuntu Jammy 22.04    | `22.04.5`           |
| `ubuntu2404` | `electrocucaracha-boxes/ubuntu-noble`    | Ubuntu Noble 24.04    | `24.04.3`           |
| `ubuntu2604` | `electrocucaracha-boxes/ubuntu-resolute` | Ubuntu Resolute 26.04 | `26.04`             |

<!-- markdownlint-enable MD013 -->

## Provider matrix

<!-- markdownlint-disable MD013 -->

| Provider     | Box filename architecture | Metadata architecture | Notes                                                       |
| ------------ | ------------------------- | --------------------- | ----------------------------------------------------------- |
| `libvirt`    | `x64`                     | `amd64`               | Included in the default build set                           |
| `virtualbox` | `x64`                     | `amd64`               | Included in the default build set                           |
| `utm`        | `arm64`                   | `arm64`               | Optional build target intended for macOS with `vagrant_utm` |

<!-- markdownlint-enable MD013 -->

## Naming patterns

Published metadata names follow this pattern:

```text
<namespace>/<distro-slug>
```

Example:

```text
electrocucaracha-boxes/ubuntu-noble
```

Published box filenames follow this pattern:

```text
<distro-slug>-<provider>-<build-arch>-<version>.box
```

Example:

```text
ubuntu-noble-virtualbox-x64-24.04.3.box
```
