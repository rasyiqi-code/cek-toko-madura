# Cek Toko Madura 🏪

A premium Flutter application designed for **Audit & Stock Management** specifically tailored for the unique "Toko Madura" ecosystem.

## ✨ Core Features

- **Inventory Audit**: Seamlessly track and verify stock levels.
- **Serah Terima (Handover)**: Intelligent calculation of stock differences during shifts or keeper changes.
- **Financial Responsibility**: Automatically convert stock deficits into monetary values based on cost price.
- **Modern UI/UX**: Premium dark-themed interface built with `plus_jakarta_sans` and smooth micro-animations.
- **Multi-Platform**: Robust performance across Android and Web.

## 🧠 The Concept: "Stok Lama & Stok Baru"

This application implements a specific handover logic common in Indonesian "Toko Madura":
1. **Stok Lama**: The inventory count when a keeper begins their shift.
2. **Stok Baru**: The physical count when at the end of a shift/audit.
3. **Selisih**: Calculated as `Stok Lama - Stok Baru`.
4. **Value**: Deficits are calculated using the formula: `(Stok Lama - Stok Baru) × Harga Modal`.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.x+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Styling**: `google_fonts` (Plus Jakarta Sans) & `flutter_animate`
- **Utility**: `intl` for currency formatting, `share_plus` for report exports.

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Bun](https://bun.sh) (Recommended for scripts/backend tasks)

### Running the App
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -d chrome # For Web
   # OR
   flutter run # For default device (Android/iOS)
   ```

---
*Built with ❤️ for Juragan Madura.*
