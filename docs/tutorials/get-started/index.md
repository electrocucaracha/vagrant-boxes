# Get Started with a Published Box

This tutorial walks you through your first successful Vagrant workflow
using a published box.

## Goal

Start an Ubuntu VM from published box metadata,
connect to it with Vagrant,
and clean it up when you are done.

## Prerequisites

Before you begin, ensure you have:

- Vagrant installed
- The provider you want to use already installed on your host
- Access to a published `metadata.json` URL for one of the boxes

This example uses the `ubuntu-noble` box name and the `libvirt` provider.
Replace these with the box and provider you want to use.

## Step 1: Add the Box from Metadata

Add the box using its metadata file:

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-noble/metadata.json
```

Vagrant reads the metadata file
and selects the provider-specific artifact for the provider you use later.

## Step 2: Create a Working Directory

Create a directory for your environment and initialize it:

```bash
mkdir noble-demo
cd noble-demo
vagrant init electrocucaracha-boxes/ubuntu-noble
```

This creates a `Vagrantfile` that points to the box name from the metadata.

## Step 3: Start the Environment

Start the Vagrant environment:

```bash
vagrant up --provider=libvirt
```

## Step 4: Connect to the VM

Once the environment is running, connect to the VM:

```bash
vagrant ssh
```

## Step 5: Clean Up

When you're done, clean up the environment:

```bash
vagrant destroy
```
