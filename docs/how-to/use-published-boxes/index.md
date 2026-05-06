# Use published boxes from hosted or local metadata

Use these boxes through the generated `metadata.json` file rather than by
adding a `.box` file directly.

## Use hosted metadata

If the publisher generated metadata with `BOX_BASE_URL`, add the box from the
hosted `metadata.json` file:

```bash
vagrant box add https://<host>/electrocucaracha-boxes/ubuntu-jammy/metadata.json
```

Then initialize and start the environment:

```bash
mkdir jammy-demo
cd jammy-demo
vagrant init electrocucaracha-boxes/ubuntu-jammy
vagrant up --provider=virtualbox
```

Hosted metadata is the right choice when the box artifacts are shared with
other machines.

## Use local metadata

If the metadata was generated without `BOX_BASE_URL`, each provider entry uses
an absolute `file://` URL that points at the local `.box` file.

Add the box from the local metadata file:

```bash
vagrant box add /path/to/electrocucaracha-boxes/ubuntu-jammy/metadata.json
```

This mode works when the `metadata.json` file and the referenced `.box` files
are available on the same machine at the paths recorded in the metadata.

## Choose the right metadata source

| Situation                                                                 | Use                                                         |
| ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Someone published the boxes on a web server                               | Hosted `metadata.json`                                      |
| You are consuming artifacts directly from the machine that generated them | Local `metadata.json` with `file://` URLs                   |
| You need to move artifacts between machines                               | Regenerate metadata with `BOX_BASE_URL` and use hosted URLs |
