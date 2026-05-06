# Vagrant boxes

<!-- markdown-link-check-disable-next-line -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/vagrant-boxes/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

<!-- markdown-link-check-disable-next-line -->

![visitors](https://visitor-badge.laobi.icu/badge?page_id=electrocucaracha.vagrant-boxes)
[![Scc Code Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=code)](https://github.com/boyter/scc/)
[![Scc COCOMO Badge](https://sloc.xyz/github/electrocucaracha/vagrant-boxes?category=cocomo)](https://github.com/boyter/scc/)

## Overview

This repository produces Ubuntu Vagrant base boxes for the `libvirt`,
`virtualbox`, and `utm` providers.

It focuses on a small, maintained set of Ubuntu releases:

- Ubuntu 22.04
- Ubuntu 24.04
- Ubuntu 26.04

## Benefits

- **Repeatable builds**: the same templates and provisioning flow can be used
  every time a box is rebuilt.
- **Provider-ready artifacts**: published outputs include `.box` files,
  checksums, and Vagrant `metadata.json`.
- **Consistent guests**: the boxes apply the same user, networking, cleanup,
  and packaging behavior across providers.
- **Smaller maintenance surface**: the project keeps a narrow distro and
  provider matrix so the outputs stay easier to validate and publish.
- **Flexible distribution**: artifacts can be consumed from local `file://`
  metadata or a hosted base URL.
