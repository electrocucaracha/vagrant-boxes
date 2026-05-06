# Use UTM boxes

Use this guide when you want to run the arm64 UTM variant of a published box.

## Before you begin

You need:

- macOS
- Vagrant
- UTM
- the `vagrant_utm` provider plugin
- access to a published UTM `metadata.json` file

Install the Vagrant provider plugin:

```bash
vagrant plugin install vagrant_utm
```

## Add the box

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-noble/metadata.json
```

The UTM boxes use the `utm` provider and publish `arm64` artifacts.

## Initialize and start the guest

```bash
mkdir noble-utm-demo
cd noble-utm-demo
vagrant init electrocucaracha-boxes/ubuntu-noble
vagrant up --provider=utm
```

## Connect to the guest

```bash
vagrant ssh
```

## Notes

- UTM support is opt-in at build time, so only published UTM artifacts can be
  consumed with `--provider=utm`.
- The UTM boxes are intended for Ubuntu arm64 guests on macOS hosts.
