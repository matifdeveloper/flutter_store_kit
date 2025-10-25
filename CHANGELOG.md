## 3.0.1

* iOS purchase product fix

## 3.0.0

* Migrated to the new unified OpenIAP architecture.
* Deprecated `IAPItem` replaced with `ProductCommon` for both in-app and subscription products.
* Replaced `requestSubscription()` and legacy purchase methods with `RequestPurchaseProps`-based flow.
* Added support for Android `subscriptionOffers` and iOS unified `sku` requests.
* Improved purchase validation, error handling, and transaction finishing APIs.
* Updated internal plugin bridge for Android Billing v7 and iOS StoreKit 2 compatibility.
* Major API redesign for simpler, safer purchase logic.

## 2.0.4

* iOS 18.x purchase product fix

## 2.0.3

* Available purchases bug fix.

## 2.0.2

* Minor issue fixes.

## 2.0.1

* Solved the available purchases issue.

## 2.0.0

* Solved the products fetching issue.

## 1.0.5

* Added platform-specific support to open subscription management pages for Android (Google Play) and iOS (App Store).
