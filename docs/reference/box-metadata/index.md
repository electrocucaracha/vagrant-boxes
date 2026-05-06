# Box metadata and artifact layout

Each published distro directory contains a `metadata.json` file plus one or
more provider-specific `.box` files and checksum files.

## Published layout

```text
<namespace>/
  <distro-slug>/
    metadata.json
    <distro-slug>-<provider>-<build-arch>-<version>.box
    <distro-slug>-<provider>-<build-arch>-<version>.box.sha256
```

Example:

```text
electrocucaracha-boxes/
  ubuntu-noble/
    metadata.json
    ubuntu-noble-libvirt-x64-24.04.3.box
    ubuntu-noble-libvirt-x64-24.04.3.box.sha256
```

## Metadata fields

The generated metadata uses this shape:

```json
{
  "name": "electrocucaracha-boxes/ubuntu-noble",
  "description": "Ubuntu Noble 24.04",
  "versions": [
    {
      "version": "24.04.3",
      "providers": [
        {
          "name": "libvirt",
          "url": "https://<host>/electrocucaracha-boxes/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box",
          "checksum_type": "sha256",
          "checksum": "<sha256>",
          "architecture": "amd64",
          "default_architecture": true
        }
      ]
    }
  ]
}
```

## URL behavior

| Metadata mode           | Provider URLs                    |
| ----------------------- | -------------------------------- |
| `BOX_BASE_URL` is set   | Hosted `https://...` URLs        |
| `BOX_BASE_URL` is unset | Absolute local `file://...` URLs |

## Architecture selection

Each provider entry records its architecture explicitly:

- `libvirt` and `virtualbox` use `amd64`
- `utm` uses `arm64`

When a distro has both `amd64` and `arm64` provider entries, the metadata marks
the `amd64` entry as the default architecture.
