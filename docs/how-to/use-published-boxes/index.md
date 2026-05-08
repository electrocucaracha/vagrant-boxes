# Use Published Boxes from Hosted or Local Metadata

Use published boxes through the generated `metadata.json` file
rather than adding a `.box` file directly.
Follow the steps below based on your metadata setup.

## Using Hosted Metadata

If the publisher generated metadata with `BOX_BASE_URL`,
you can add the box from the hosted `metadata.json` file:

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-jammy/metadata.json
```

### Initialize and Start the Environment

1. Create a new directory for your environment:

   ```bash
   mkdir jammy-demo
   cd jammy-demo
   ```

2. Initialize the Vagrant environment:

   ```bash
   vagrant init electrocucaracha-boxes/ubuntu-jammy
   ```

3. Start the environment:

   ```bash
   vagrant up --provider=virtualbox
   ```

Hosted metadata is ideal when sharing box artifacts with multiple machines.

## Using Local Metadata

If the metadata was generated without `BOX_BASE_URL`,
each provider entry uses an absolute `file://` URL
pointing to the local `.box` file.

Add the box from the local metadata file:

```bash
vagrant box add /path/to/electrocucaracha-boxes/ubuntu-jammy/metadata.json
```

### Requirements

Ensure the `metadata.json` file and the referenced `.box` files
are available on the same machine.
