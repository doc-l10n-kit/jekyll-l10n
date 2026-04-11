# jekyll-l10n

A Jekyll plugin for localizing AsciiDoc-based sites using standard PO (Portable Object) files. Part of the [doc-l10n-kit](https://github.com/doc-l10n-kit) ecosystem.

## Overview

jekyll-l10n extracts translatable strings from Jekyll sites that use AsciiDoc (via [jekyll-asciidoc](https://github.com/asciidoctor/jekyll-asciidoc)) and manages them through the widely-adopted [GNU gettext](https://www.gnu.org/software/gettext/) PO file format. Translators work with familiar PO editors, and translations are applied automatically during site generation.

### What Gets Extracted

| Source | Content |
|---|---|
| Jekyll FrontMatter | `title`, `synopsis` (documents), `title`, `intro` (pages) |
| AsciiDoc content | Section titles (`=` through `====`), paragraphs, admonitions (NOTE, TIP, IMPORTANT), list items, table cells, block titles, block quotes |

Code blocks, comments, and attributes are not extracted.

## Installation

Add to your Jekyll site's `Gemfile`:

```ruby
gem "jekyll-l10n", git: "https://github.com/doc-l10n-kit/jekyll-l10n.git"
```

Then run:

```bash
bundle install
```

## Configuration

Add to your `_config.yml`:

```yaml
l10n:
  mode: update_po    # or 'translate'
  po:
    baseDir: _l10n   # directory for PO files
```

Alternatively, use environment variables:

```bash
export L10N_MODE=update_po
export L10N_PO_BASE_DIR=_l10n
```

### Modes

| Mode | Description |
|---|---|
| `update_po` | Extracts translatable strings and creates/updates PO files |
| `translate` | Applies translations from PO files during site rendering |

## Usage

### Step 1: Extract Strings

Set mode to `update_po` and build your site:

```bash
L10N_MODE=update_po bundle exec jekyll build
```

This generates PO files mirroring your content structure:

```
_l10n/
  _posts/
    2024-01-01-getting-started.adoc.po
    2024-02-15-advanced-guide.adoc.po
  _pages/
    about.adoc.po
```

### Step 2: Translate

Open the PO files in any PO editor (e.g., [Poedit](https://poedit.net/), [Lokalize](https://apps.kde.org/lokalize/), [Weblate](https://weblate.org/)) and fill in translations:

```po
#. type: Title =
msgid "Getting Started"
msgstr "はじめに"

#. type: Plain Text
msgid "This guide walks you through the initial setup."
msgstr "このガイドでは、初期セットアップについて説明します。"
```

Entries marked as `fuzzy` are skipped during translation — remove the fuzzy flag once the translation is confirmed.

### Step 3: Build Translated Site

Set mode to `translate` and build:

```bash
L10N_MODE=translate bundle exec jekyll build
```

The generated site will contain the translated content.

## How It Works

jekyll-l10n hooks into Jekyll's build lifecycle at three points:

1. **`site:after_init`** — Registers Asciidoctor extensions (preprocessor to enable sourcemap tracking, tree processor for translation)
2. **`site:post_render`** — In `update_po` mode, walks all documents/pages, extracts sentences, and writes PO files
3. **`documents:pre_render`** — In `translate` mode, replaces FrontMatter fields (title, synopsis) with translations from PO files

The Asciidoctor tree processor handles the AsciiDoc body content: it walks the parsed document tree, and either collects sentences for extraction or replaces them with translations depending on the current mode.

## Architecture

```
lib/
├── jekyll-l10n.rb                  # Entry point — registers Jekyll hooks
└── jekyll/l10n/
    ├── l10n_config.rb              # Configuration (YAML + env vars)
    ├── site_processor.rb           # Extracts sentences from all documents/pages
    ├── document_processor.rb       # Translates individual document FrontMatter
    ├── po_repository.rb            # PO file loading, caching, and saving
    ├── util.rb                     # Path resolution utilities
    ├── asciidoctor_l10n_preprocessor.rb   # Enables Asciidoctor sourcemap
    ├── asciidoctor_l10n_tree_processor.rb # Tree processor for extraction/translation
    └── model/
        ├── sentence.rb             # Base class for translatable content
        ├── asciidoc.rb             # Recursive tree walker for sentence extraction
        ├── po.rb                   # PO file model (read/write/update)
        ├── document_title.rb       # Jekyll document title
        ├── document_synopsis.rb    # Jekyll document synopsis
        ├── page_title.rb           # Jekyll page title
        ├── page_intro.rb           # Jekyll page intro
        ├── section_title.rb        # AsciiDoc section headers
        ├── block.rb                # AsciiDoc paragraph blocks
        ├── block_title.rb          # AsciiDoc block titles
        ├── table_title.rb          # AsciiDoc table titles
        ├── list_title.rb           # AsciiDoc list titles
        ├── cell.rb                 # AsciiDoc table cells
        └── list_item.rb            # AsciiDoc list items
```

## Development

### Prerequisites

- Ruby >= 2.6.0
- Bundler

### Setup

```bash
bin/setup
```

### Running Tests

```bash
bundle exec rspec
```

### Dependencies

- [jekyll](https://jekyllrb.com/) — Static site generator
- [asciidoctor](https://asciidoctor.org/) — AsciiDoc processor
- [gettext](https://rubygems.org/gems/gettext) (3.4.9) — PO file parsing and generation
