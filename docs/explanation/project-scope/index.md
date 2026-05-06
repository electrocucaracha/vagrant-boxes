# Why the project keeps a narrow support matrix

This project deliberately supports a small set of Ubuntu releases
and provider targets.

## The goal

The goal is not to cover every distro and every Vagrant provider.
The goal is to publish a maintained set of boxes
that stay predictable for consumers.

## Why the matrix stays small

A smaller support matrix helps the project:

- rebuild boxes repeatably
- keep provisioning behavior consistent across providers
- validate generated artifacts more reliably
- publish metadata and checksums with less operational drift

## What that means for users

For consumers,
the narrow scope makes the published boxes easier to understand:

- box names follow one naming scheme
- metadata layout stays consistent across distros
- provider support is explicit instead of implicit
- UTM support remains separate
  from the default `libvirt` and `virtualbox` builds

This trade-off favors predictable, well-defined artifacts
over broad but harder-to-maintain coverage.
