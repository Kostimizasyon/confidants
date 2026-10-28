# Confidants

**Confidants** is an offline-first, privacy-focused mobile application for **Android & iOS** designed to securely ingest contact information, build rich personal profiles with dynamic custom attributes, automatically export privacy-conscious JSON context chunks, and enable conversational querying using on-device lightweight language models (LLMs).

---

## Key Features

- **Biometric App Vault**
  - Optional startup lock using device biometrics (fingerprint / face / PIN) powered by `local_auth`.
  - Identity must be confirmed before enabling the lock in Settings to prevent accidental lockout.

- **Rich Personal Knowledge Base**
  - Ingest device contacts via `flutter_contacts` or build profiles manually.
  - Track birthdays (with native date-picker), optional nicknames, phone numbers, email addresses, memory notes, likes, dislikes, and hobbies.
  - **Dynamic Custom Attributes:** Add arbitrary key-value pairs (e.g. *"Favorite Coffee"*, *"Shoe Size"*, *"Allergies"*, *"Pet Name"*).
  - Search profiles instantly by name, nickname, phone, or memory notes.

- **Privacy-First AI Context Chunks**
  - Per-profile opt-in toggle (*"Include in AI Knowledge Base"*).
  - Automatically exports qualified profiles as formatted JSON files in `<app documents>/ai_context_chunks/<sha256_hash>.json`.
  - Raw phone numbers and database primary keys are stripped from export chunks for privacy.
  - File changes and deletions are synchronized with an internal SQLite `file_mappings` checksum table.

- **On-Device LLM Architecture & Model Selection**
  - **Strictly Opt-In:** AI querying is disabled by default until the user explicitly enables it in Settings.
  - **Model Dropdown:** Select from vetted mobile GGUF models:
    - **SmolLM2 360M Instruct** (`~250 MB` storage • `~450 MB` RAM)
    - **Qwen 2.5 0.5B Instruct** *(Default)* (`~350 MB` storage • `~600 MB` RAM)
    - **Llama 3.2 1B Instruct** (`~750 MB` storage • `~1.3 GB` RAM)
    - **Qwen 2.5 1.5B Instruct** (`~1.0 GB` storage • `~1.8 GB` RAM)
    - **Llama 3.2 3B Instruct** (`~2.0 GB` storage • `~3.2 GB` RAM)
  - **Hardware Warning Cards:** Contextual cards below the dropdown warn users about storage footprint, RAM demand, and potential thermal or out-of-memory impact on budget devices.

- **Clean Design & Custom UI Elements**
  - Minimalist **Black, White, and Dark Blue** palette with complete Dark Mode & Light Mode support.
  - **Lucide Icons:** Clean iconography throughout the app (`lucide_icons_flutter`).
  - **Frosted Toast Overlay (`proteinBar`):** Non-intrusive floating glassmorphic toasts replace standard snackbars.
  - **Zero External State Management:** Pure Flutter architecture using `ValueNotifier` streams for reactive theme and setting updates.

- **Full Localization (i18n)**
  - Localized in **English (`en`)** and **Turkish (`tr`)** using official Flutter ARB files (`lib/l10n/`).
  - Zero hardcoded string literals across UI code.

---

## Architecture & Project Structure

```text
lib/
├── data_models/
│   ├── ai_model_config.dart          # Supported GGUF model presets & specs
│   ├── chat_message.dart             # Message entity with .user() and .ai() constructors
│   ├── contact_item.dart             # Imported contact transfer model
│   ├── custom_field.dart             # Dynamic key-value profile attribute
│   └── user_profile.dart             # Core profile entity, SQLite mapping & JSON export
├── frontend/
│   ├── chat_page/
│   │   ├── util/
│   │   │   ├── chat_bubble.dart      # Semantic message bubble with loading & error states
│   │   │   └── chat_input_bar.dart   # Chat input bar with send trigger
│   │   └── chat_page.dart            # AI conversation interface gated by opt-in setting
│   ├── profiles_page/
│   │   ├── util/
│   │   │   ├── custom_field_editor.dart  # Dynamic key-value row editor
│   │   │   ├── profile_card.dart     # Reusable compact & detailed profile cards
│   │   │   └── profile_form.dart     # Form with date-picker and preset field constructors
│   │   ├── profile_detail_page.dart  # Create, view, edit & delete individual profiles
│   │   └── profiles_page.dart        # Searchable list of profiles with contact importer
│   ├── settings_page/
│   │   ├── util/
│   │   │   ├── model_selector_card.dart  # Model dropdown & hardware warning cards
│   │   │   └── settings_toggle_tile.dart # Reusable preference switch cards
│   │   └── settings_page.dart        # Theme, biometric lock, and AI model settings
│   ├── theme/
│   │   ├── app_colors.dart           # Single source of truth for all color constants
│   │   └── app_theme.dart            # Material 3 light and dark theme configurations
│   └── util/
│       ├── auth_guard_screen.dart    # Biometric / PIN startup security gate
│       ├── contact_picker_dialog.dart# Modal contact selection sheet
│       ├── custom_app_bar.dart       # Header with preset named constructors
│       ├── l10n_extensions.dart      # context.l10n and L10nText resolution
│       ├── navigation_shell.dart     # 3-tab persistent BottomNavigationBar scaffold
│       └── proteinbar.dart           # Custom blurred overlay toast notification
├── l10n/
│   ├── app_en.arb                    # English localization template
│   └── app_tr.arb                    # Turkish translations
├── services/
│   ├── ai_service.dart               # Context assembly & LLM inference API handoff
│   ├── auth_service.dart             # Hardware biometric authentication wrapper
│   ├── contact_service.dart          # Device address book query service
│   ├── database_helper.dart          # SQLite database (profiles, custom_fields, file_mappings)
│   ├── export_service.dart           # Exports training-enabled profiles to JSON chunks
│   ├── hash_service.dart             # SHA-256 identifier and file checksum generator
│   └── preferences_service.dart      # SharedPreferences wrapper with ValueNotifiers
├── main.dart                         # Entry point, localization delegates, and theme listener
└── project-structure.md              # Living architecture log
```

---

## AI Model Integration (Where the API Lives)

All AI inference calls are decoupled from the UI and centralized in:
📁 **`lib/services/ai_service.dart`** (`generateResponse()`)

The service automatically loads and parses your exported context chunks and prepares the system prompt:

```dart
// lib/services/ai_service.dart:
Future<String> generateResponse({
  required String userQuery,
  ...
}) async {
  final contextChunks = await _exportService.listChunkFiles();
  final parsedChunks = await _readChunkPayloads(contextChunks);
  final systemPrompt = _buildSystemPrompt(parsedChunks);
  final model = activeModel;

  // =========================================================================
  // THE MODEL API CALL / INFERENCE BOUNDARY
  // =========================================================================
  // TODO: AI API call - Ingest context files from ExportService and dispatch prompt to local LLM
  // Expected input: List<File> contextChunks, String userQuery (plus AiModelConfig model & String systemPrompt)
  // Expected output: Stream<String> or Future<String> modelResponse
  ...
}
```

To connect an on-device GGUF runner (such as `llamadart`, LiteRT, or a custom engine), simply plug your model execution call into this method.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.13.7`)
- Android Studio / Xcode configured for mobile builds.

### Installation & Run

1. Clone or navigate to the repository:
   ```bash
   cd confidants
   ```

2. Fetch dependencies and generate localizations:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Launch on an Android emulator or connected device:
   ```bash
   flutter run
   ```

---

## Platform Permissions

- **Android (`AndroidManifest.xml`)**:
  - `android.permission.USE_BIOMETRIC` (for biometric authentication)
  - `android.permission.READ_CONTACTS` (for address book ingestion)
  - `android.permission.INTERNET` (only if model downloading is performed)
- **iOS (`Info.plist`)**:
  - `NSFaceIDUsageDescription` (for biometric authentication)
  - `NSContactsUsageDescription` (for contact import)
