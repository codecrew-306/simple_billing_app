# SimpleBill

SimpleBill is a mobile-first Flutter application designed for small Indian retail shops (kirana stores). It streamlines the daily operations of store owners by providing quick barcode-based product scanning, bill generation, transaction tracking, customer tab management (with partial payments), and basic sales analytics.

## Key Features

- **Barcode Billing**: Quickly scan items via phone camera or barcode scanner.
- **Customer Tabs**: Track credit tabs and partial payments for specific customers.
- **Sales Analytics**: Dashboard with visual graphs covering daily/weekly metrics.
- **Transactions Management**: Historical views of transactions, with fully detailed digital receipts.
- **Shop Profiles**: Store profiles supporting custom currencies and exportable data.

## Architecture

This project strictly follows the **MVVM** (Model-View-ViewModel) architecture.
- **State Management**: [Riverpod](https://riverpod.dev)
- **Routing**: [GetX](https://pub.dev/packages/get)
- **Backend / DB**: Firebase Auth & Cloud Firestore
- **Hardware Integration**: [mobile_scanner](https://pub.dev/packages/mobile_scanner)

## Getting Started

1. Ensure the Flutter SDK is installed.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Integrate Firebase by running `flutterfire configure` to generate the necessary platform configuration files (`google-services.json` and `GoogleService-Info.plist`).
5. Execute `flutter run` on target emulator or physical device.
