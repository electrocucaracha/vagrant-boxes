---
description: "Markdown writing instructions for documentation changes in vagrant-boxes"
applyTo: "**/*.md"
---

# Markdown writing instructions

Use these instructions
when creating or editing Markdown files in this repository.

## Semantic line breaks

Write new or revised prose using semantic line breaks.
Add a line break after each substantial unit of thought
without changing the rendered Markdown output.

Apply these rules when writing prose:

1. Break lines after a sentence ending in `.`, `!`, or `?`.
2. Prefer breaking after an independent clause ending in `,`, `;`, `:`, or `—`
   when that improves readability in source.
3. You may break after a dependent clause when it clarifies structure.
4. Do not insert a semantic line break inside a hyphenated word.
5. Do not force line breaks that change Markdown rendering.

## Scope

Apply semantic line breaks to normal prose paragraphs.
Do not reflow code blocks, tables, link reference definitions,
or other syntax where line structure is part of the Markdown format.

When updating an existing document,
use semantic line breaks for new or revised text
instead of reformatting unrelated paragraphs.

## Example

Instead of writing a long wrapped paragraph like this:

```md
This repository builds Ubuntu Vagrant base boxes for several providers,
and it publishes artifacts that can be consumed by Vagrant
through metadata files.
```

Write it like this:

```md
This repository builds Ubuntu Vagrant base boxes for several providers,
and it publishes artifacts that can be consumed by Vagrant through metadata
files.
```
