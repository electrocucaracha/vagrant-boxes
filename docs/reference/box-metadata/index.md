# Box Metadata and Artifact Layout

This reference describes the structure and fields of the metadata files
used for published boxes.

## Published Layout

The directory structure for published distributions includes a `metadata.json`
file and provider-specific `.box` files:

```text
<namespace>/
  <distro-slug>/
    metadata.json
    <distro-slug>-<provider>-<build-arch>-<version>.box
    <distro-slug>-<provider>-<build-arch>-<version>.box.sha256
```

### Example

```text
electrocucaracha-boxes/
  ubuntu-noble/
    metadata.json
    ubuntu-noble-libvirt-x64-24.04.3.box
    ubuntu-noble-libvirt-x64-24.04.3.box.sha256
```

## Metadata Fields

The `metadata.json` file includes the following fields:

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
          "url": "https://<host>/electrocucaracha-boxes/ubuntu-noble/ubuntu-noble-libvirt-x64-24.04.3.box"
        }
      ]
    }
  ]
}
```
