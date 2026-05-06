# Get started with a published box

This tutorial walks through a first successful Vagrant workflow with one of the
published boxes.

## Goal

Start an Ubuntu VM from published box metadata, connect to it with Vagrant, and
clean it up when you are done.

## Before you begin

You need:

- Vagrant installed
- the provider you want to use already installed on your host
- access to a published `metadata.json` URL for one of the boxes

This example uses the `ubuntu-noble` box name and the `libvirt` provider. Swap
them for the published box and provider you want to use.

## 1. Add the box from its metadata

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-noble/metadata.json
```

Vagrant reads the metadata file and selects the provider-specific artifact for
the provider you use later.

## 2. Create a working directory

```bash
mkdir noble-demo
cd noble-demo
vagrant init electrocucaracha-boxes/ubuntu-noble
```

This creates a `Vagrantfile` that points at the box name from the metadata.

## 3. Start the VM

```bash
vagrant up --provider=libvirt
```

Use the provider that matches the published artifact you added.

## 4. Connect to the guest

```bash
vagrant ssh
```

At this point you are inside the Ubuntu guest created from the published box.

## 5. Remove the environment when finished

```bash
exit
vagrant destroy -f
```

## Next steps

- If your boxes are published behind a web server, see
  [Use published boxes from hosted or local metadata](../../how-to/use-published-boxes/).
- If you want to use the arm64 UTM provider, see
  [Use UTM boxes](../../how-to/use-utm-boxes/).
