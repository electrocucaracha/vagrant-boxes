# Use UTM Boxes

This guide provides step-by-step instructions for running the arm64 UTM variant
of a published box.

## Prerequisites

Before you begin, ensure you have:

- macOS
- Vagrant
- UTM
- The `vagrant_utm` provider plugin
- Access to a published UTM `metadata.json` file

Install the Vagrant provider plugin:

```bash
vagrant plugin install vagrant_utm
```

## Add the Box

Add the box from the published metadata file:

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-noble/metadata.json
```

The UTM boxes use the `utm` provider and publish `arm64` artifacts.

## Initialize and Start the Guest

1. Create a new directory for your environment:

   ```bash
   mkdir noble-utm-demo
   cd noble-utm-demo
   ```

2. Initialize the Vagrant environment:

   ```bash
   vagrant init electrocucaracha-boxes/ubuntu-noble
   ```

3. Start the environment:

   ```bash
   vagrant up --provider=utm
   ```

## Connect to the Guest

Once the environment is running, connect to the guest:

```bash
vagrant ssh
```

## Notes

- UTM support is opt-in at build time,
  so only published UTM artifacts can be consumed with `--provider=utm`.
- The UTM boxes are intended for Ubuntu arm64 guests on macOS hosts.
