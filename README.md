# Ask Blinkit (Intento)

An AI-powered intent-to-cart shopping engine for iOS. Describe a shopping goal
in plain language ("butter chicken for 4 under ₹900", "movie night for 6") and
the app extracts intent, builds a complete cart with correct quantities, and
lets you review, edit, and check out.

> **Status: Phase 1 complete — data foundation only.**
> This phase contains the pure data models, service protocol definitions, the
> configuration/`.env` mechanism, and the mock catalog data + decoder. No
> Views, ViewModels, or concrete service implementations exist yet; those land
> in Phase 2.

## Requirements

- Xcode 26+ (project object version 77, file-system synchronized groups)
- iOS 26.5 deployment target
- Swift 5 language mode (default actor isolation: `MainActor`)

## Project structure

```
Intento/                         # Xcode project root
  Intento/                       # App target sources (synchronized group)
    Core/
      Configuration/             # .env loading + typed AppConfig
      Catalog/                   # Catalog JSON DTOs + decoder
    Shared/
      Models/                    # Pure Codable domain models
      Services/                  # Service protocol definitions (no impls yet)
    Resources/
      catalog.json               # Mock product catalog (113 items, 11 categories)
      Environment.env(.example)  # Bundled runtime config (see below)
    IntentoApp.swift             # App entry point
```

Architecture follows strict MVVM with protocol-oriented, dependency-injected
services:

- **Models** are pure value types (`Codable`/`Sendable`), no UI or service deps.
- **Services** are defined as protocols in `Shared/Services`; concrete versions
  (starting with local mock data sources) arrive in Phase 2 and are wired at a
  single composition root.
- **Business logic** (quantity scaling, budget optimisation, substitution) is
  defined behind pure, unit-testable protocols.

## Configuration & `.env`

API keys and provider settings are **never hardcoded**. They are read at launch
through a small loader and exposed via a single typed `AppConfig` value that the
rest of the app receives by injection.

Resolution order (first non-empty wins):

1. Process environment (`ProcessInfo` — handy for CI / Xcode scheme env vars)
2. Bundled `Environment.env` resource

If nothing is set, `AppConfig` falls back to safe defaults and the app runs
entirely on local mock services.

### Creating your config

iOS apps can only read files bundled into the app, and Xcode's synchronized
groups skip dot-prefixed files — so the bundled config file is named
`Environment.env` (not `.env`). A repo-root `.env` is also provided for tooling.

```bash
# Bundled runtime config (read by the app at launch)
cp Intento/Intento/Resources/Environment.env.example \
   Intento/Intento/Resources/Environment.env

# Optional: repo-root file for local tooling
cp .env.example .env
```

Then edit the file and add your key:

```
LLM_PROVIDER=openai
LLM_API_KEY=sk-...your key...
USE_MOCK_SERVICES=false
```

Both `Environment.env` and `.env` are git-ignored. Only the `*.example`
templates are committed.

### Supported keys

| Key                 | Default                       | Purpose                                   |
| ------------------- | ----------------------------- | ----------------------------------------- |
| `LLM_PROVIDER`      | `openai`                      | Intent-extraction provider                |
| `LLM_API_KEY`       | _(empty)_                     | Provider API key; empty ⇒ on-device mock  |
| `LLM_BASE_URL`      | `https://api.openai.com/v1`   | API base URL (override for gateways)      |
| `LLM_MODEL`         | `gpt-4o-mini`                 | Model identifier                          |
| `USE_MOCK_SERVICES` | `true`                        | Use local mock data sources               |
| `CURRENCY_CODE`     | `INR`                         | Price formatting currency                 |
| `LOCALE_IDENTIFIER` | `en_IN`                       | Price formatting locale                   |

## Mock catalog

`Resources/catalog.json` holds a generously populated catalog (113 SKUs across
11 categories: produce, dairy, meat, bakery, pantry, snacks, beverages,
cleaning, party supplies, baby, first aid) with realistic names, pack sizes,
₹ prices, and stock levels. A single JSON feeds both the catalog and inventory
mock services. Swapping in a real backend later is a one-file change: conform a
new type to `ProductCatalogServicing` / `InventoryServicing` and wire it at the
composition root.
