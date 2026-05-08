# Why the Project Keeps a Narrow Support Matrix

This explanation provides the rationale behind the project's deliberate focus
on a small set of Ubuntu releases and provider targets.

## The Goal

The primary objective is to publish a maintained set of boxes
that remain predictable and reliable for consumers,
rather than attempting to cover every distribution and provider.

## Benefits of a Narrow Scope

A smaller support matrix enables the project to:

- Rebuild boxes consistently and reliably.
- Maintain consistent provisioning behavior across providers.
- Validate generated artifacts with greater accuracy.
- Publish metadata and checksums with minimal operational drift.

## What This Means for Users

For consumers, the narrow scope ensures:

- Predictable naming schemes for boxes.
- Consistent metadata layouts across distributions.
- Explicit provider support.
- Clear separation of UTM support from default builds
  (e.g., `libvirt` and `virtualbox`).

This trade-off prioritizes well-defined, predictable artifacts
over broader but less maintainable coverage.
