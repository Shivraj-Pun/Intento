# Intento

An AI-powered intent-to-cart shopping engine for iOS. Describe a shopping goal
in plain language ("butter chicken for 4 under ₹900", "movie night for 6") and
Intento extracts the intent, builds a complete cart with correct quantities,
resolves stock and substitutions, fits to budget, and lets you review, edit,
and check out.

## Requirements

- Xcode 16 or newer
- iOS 18.0 deployment target
- Swift 5 language mode (default actor isolation: MainActor)

## Architecture

Strict MVVM with protocol-oriented, dependency-injected services.

```
Intento/Intento/                 App target (file-system synchronized group)
  App/                           App entry, RootView, navigation, App Intents
  Core/
    Configuration/               .env loading + typed AppConfig
    Catalog/                     Catalog JSON DTO + decoder
    DesignSystem/                Colors, typography, spacing, shadows, buttons
    DI/                          AppContainer composition root + VM factories
    Services/                    Concrete services (mock data, engines, LLM, etc.)
  Shared/
    Models/                      Pure Codable/Sendable domain models
    Services/                    Service protocol definitions
    Components/                  Reusable SwiftUI views
  Features/
    Home/  Ask/  Cart/  Personalization/    Screens + ViewModels
  Resources/                     catalog.json, Environment.env
Intento/IntentoWidget/           WidgetKit extension (add target in Xcode)
Intento/IntentoTests/            Unit tests (add test target in Xcode)
```

- Models are pure value types, no UI or service dependencies.
- ViewModels use `Observation` (`@Observable`) and never import SwiftUI.
- Every external dependency is a protocol in `Shared/Services` with a concrete
  implementation wired at a single composition root (`AppContainer`).
- Business logic (quantity scaling, budget optimisation, substitution,
  intent parsing) lives in plain Swift types with unit tests.

## Intent extraction (Gemini + mock)

`LLMIntentExtracting` has two implementations:

- `GeminiIntentExtractor` — calls the Gemini `generateContent` API and parses
  structured JSON into a `ShoppingIntent`.
- `MockIntentExtractor` — a deterministic on-device parser used when no API key
  is set. The app is fully functional with no key.

`AppContainer` picks Gemini only when `USE_MOCK_SERVICES=false`, a key is
present, and the provider is `gemini`; otherwise it uses the mock.

## Catalog & inventory

`Resources/catalog.json` holds 113 SKUs across 11 categories with realistic
names, pack sizes, ₹ prices, and stock levels. A single JSON feeds both the
mock catalog and inventory services. A few SKUs are intentionally out of or low
on stock to demonstrate substitutions. Swapping in a real backend is a one-file
change: conform a type to `ProductCatalogServicing` / `InventoryServicing` and
wire it in `AppContainer`.

## Configuration & `.env`

Keys are read at launch and exposed via a single injected `AppConfig`. Nothing
reads `.env` directly except the loader. Resolution order: process environment,
then the bundled `Environment.env`.

iOS bundles resources but Xcode's synchronized groups skip dot-files, so the
runtime file is named `Environment.env` (not `.env`).

```bash
cp Intento/Intento/Resources/Environment.env.example \
   Intento/Intento/Resources/Environment.env
```

Then edit it:

```
LLM_PROVIDER=gemini
LLM_API_KEY=your_gemini_key
USE_MOCK_SERVICES=false
```

| Key                 | Default                                            |
| ------------------- | -------------------------------------------------- |
| `LLM_PROVIDER`      | `gemini`                                           |
| `LLM_API_KEY`       | _(empty → on-device mock)_                         |
| `LLM_BASE_URL`      | `https://generativelanguage.googleapis.com/v1beta` |
| `LLM_MODEL`         | `gemini-2.0-flash`                                 |
| `USE_MOCK_SERVICES` | `true`                                             |
| `CURRENCY_CODE`     | `INR`                                              |
| `LOCALE_IDENTIFIER` | `en_IN`                                            |

## Building

Open `Intento/Intento.xcodeproj` and run the `Intento` scheme on an iOS 18
simulator or device. The app builds and runs out of the box on mock data.

## One-time Xcode setup for the extra targets

These live in the repo but are separate targets that must be created once in
Xcode (they are deliberately kept outside the app's synchronized source group).

### Unit tests (`Intento/IntentoTests`)
1. File ▸ New ▸ Target ▸ Unit Testing Bundle, name it `IntentoTests`.
2. Remove the generated sample file and add the files from
   `Intento/IntentoTests` to the test target.
3. Run with Cmd-U. Coverage includes quantity scaling, budget optimisation,
   and intent parsing.

### Widget (`Intento/IntentoWidget`)
1. File ▸ New ▸ Target ▸ Widget Extension, name it `IntentoWidget`
   (uncheck "Include Configuration Intent").
2. Replace the generated files with those in `Intento/IntentoWidget`.
3. Add `Intento/Intento/App/MakeMissionIntent.swift` and
   `App/PendingMissionCenter.swift` to the widget target's membership so the
   interactive buttons can launch a mission.

### Custom fonts (optional)
The design system uses the system font by default. To use Inter, Roboto, and
JetBrains Mono, add the font files to the target, list them under `UIAppFonts`,
and set `Theme.useCustomFonts = true`.

## Notes on verification

Development happened in an environment with only the Swift Command Line Tools
(no full Xcode), so the app was validated with `swiftc` type-checks of all
non-UI code. The SwiftData models and SwiftUI views compile under Xcode's iOS
SDK (the CLT toolchain lacks the SwiftData macro plugin and the iOS UI SDK).
