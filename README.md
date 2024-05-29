# Flutter In-App Purchase Library

A Flutter library to manage in-app purchases easily with a streamlined API. This library provides classes to handle subscriptions, manage listeners, and process purchases with a single instance.

## Installation

Add the following to your `pubspec.yaml`:

```
yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_inapp_purchase: ^5.0.0
```

### 1. Initialize the Store
Initialize the store with your product IDs:
```
void main() {
  StoreService.instance.initialize([
    'weekly',
    'monthly',
    'yearly',
  ]);
}
```

### 2. Listen for Changes
Add listeners for pro status changes, errors, and product fetching:
```
void _onProStatusChanged() {
  // Handle pro status change
}

void _onError(String error) {
  // Handle error
}

void _onProductsFetched() {
  // Handle products fetched
}

StoreService.instance.proStatusChangedListener.addListener(_onProStatusChanged);
StoreService.instance.errorListener.addListener(_onError);
StoreService.instance.productsFetchedListener.addListener(_onProductsFetched);
```

### 3. Fetch Available Products
Fetch available subscription products:
```
void _fetchProducts() async {
  await StoreService.instance.subscriptionManager.fetchSubscriptionItems();
  List<IAPItem> products = StoreService.instance.subscriptionManager.subscriptionItems;
  // Use the fetched products
}
```

### 4. Purchase a Subscription
Initiate a purchase for a subscription:
```
void _purchaseSubscription(IAPItem item) async {
  await StoreService.instance.purchaseSubscription(item);
}
```

### 5. Check Purchased Status
Check if a specific product is purchased:

```bool isPurchased = StoreService.instance.isProductPurchased('weekly');```

### 6. Get All Purchased Product IDs
Get a list of all purchased product IDs:

```List<String> purchasedProductIds = StoreService.instance.getPurchasedProductIds();```


This `README.md` provides clear instructions on how to initialize and use the library, explaining the key methods with examples. Adjust any parts of the code or examples as needed to fit your specific implementation and requirements.
