# FlutterStoreKit Library

FlutterStoreKit is a Flutter library that provides functionality for managing in-app purchases and subscriptions. This documentation outlines how to use the FlutterStoreKit library in your Flutter app.

## Installation

Add the following to your `pubspec.yaml`:

```dart
yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_store_kit: ^1.0.0
```

### 1. Initialize the Store
Initialize the store with your product IDs:

```dart
void main() {
  StoreKit.instance.initialize([
    'subscription_id1',
    'subscription_id2',
    'subscription_id3',
  ]);
}
```

### 2. Add Listeners
**Add Pro Status Changed Listener**
Add a listener for pro status changes:

```dart
void _onProStatusChanged() {
  // Update UI based on purchase status
}

StoreKit.instance.addProStatusChangedListener(_onProStatusChanged);
```

**Remove Pro Status Changed Listener**
Remove a listener for pro status changes:

```dart
StoreKit.instance.removeProStatusChangedListener(_onProStatusChanged);
```

**Add Error Listener**
Add a listener for errors:

```dart
void _onError(String error) {
  // Handle error
  print("Error: $error");
}

StoreKit.instance.addErrorListener(_onError);

```

**Remove Error Listener**
Remove a listener for errors:

```dart
StoreKit.instance.removeErrorListener(_onError);
```

### 3. Purchases

**Restore Past Purchases**
Restore past purchases for the user:

```dart
await StoreKit.instance.restorePastPurchases(context);
```

**Purchase a Subscription**
Purchase a subscription item:

```dart
await StoreKit.instance.purchaseSubscription(subscriptionItem);
```

**Open Subscription Management Page**
Open the subscription management page for the user:

```dart
await StoreKit.instance.openSubscriptionManagementPage();
```

**Check if Product is Purchased**
Check if a product has been purchased:

```dart
bool purchased = StoreKit.instance.isProductPurchased('product_id');
```

**Get Purchased Product IDs**
Get a list of purchased product IDs:

```dart
List<String> purchasedIds = StoreKit.instance.getPurchasedProductIds();
```

### 4. Disposal
Dispose of the store instance:

```dart
StoreKit.instance.dispose();
```