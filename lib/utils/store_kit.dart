/*
********************************************************************************

    _____/\\\\\\\\\_____/\\\\\\\\\\\\\\\__/\\\\\\\\\\\__/\\\\\\\\\\\\\\\_
    ___/\\\\\\\\\\\\\__\///////\\\/////__\/////\\\///__\/\\\///////////__
    __/\\\/////////\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\___________\/\\\_____\/\\\\\\\\\\\_____
    _\/\\\\\\\\\\\\\\\_______\/\\\___________\/\\\_____\/\\\///////______
    _\/\\\/////////\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\________/\\\\\\\\\\\_\/\\\_____________
    _\///________\///________\///________\///////////__\///______________

    Created by Muhammad Atif on 5/29/2024.
    Portfolio https://atifnoori.web.app.

 *********************************************************************************/

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store_kit/utils/product_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'listener_manager.dart';
import 'purchase_handler.dart';
import 'subscription_manager.dart';
import 'package:flutter_inapp_purchase/helpers.dart' show ConnectionResult;
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart'
    hide ConnectionResult;

// A singleton class that provides a service for managing in-app purchases.
class StoreKit {
  // Private constructor to ensure singleton instance.
  StoreKit._private();

  // The singleton instance of the StoreService.
  static final StoreKit instance = StoreKit._private();

  // Late-initialized variables for stream subscriptions.
  late final StreamSubscription<ConnectionResult> _connectionSubscription;
  late final StreamSubscription<Purchase?> _purchaseUpdatedSubscription;
  late final StreamSubscription<PurchaseError?> _purchaseErrorSubscription;

  // Instances of PurchaseHandler, SubscriptionManager, and ListenerManager.
  final PurchaseHandler _purchaseHandler = PurchaseHandler.instance;
  late final SubscriptionManager _subscriptionManager;
  late final ProductManager _productManager;
  final ListenerManager _listenerManager = ListenerManager.instance;

  final iap = FlutterInappPurchase.instance;

  // Initializes the connection to the in-app purchase service.
  Future<void> initialize({
    List<String>? subscriptionIds,
    List<String>? productsIds,
  }) async {
    // Initialize the SubscriptionManager with subscription IDs & product ids.
    _subscriptionManager = SubscriptionManager(subscriptionIds ?? []);
    _productManager = ProductManager(productsIds ?? []);

    try {
      // Initialize the FlutterInappPurchase instance.
      final initResult = await iap.initConnection();
      // Log the initialization result.
      if (kDebugMode) {
        print(initResult);
      }
    } catch (e) {
      // Log any errors that occur during initialization.
      if (kDebugMode) {
        print(e.toString());
      }
    }

    // Listen for connection updates.
    _connectionSubscription = iap.connectionUpdated.listen((_) {});
    // Listen for purchase updates and handle them using the PurchaseHandler.
    _purchaseUpdatedSubscription = iap.purchaseUpdatedListener
        .listen(_purchaseHandler.handlePurchaseUpdate);
    // Listen for purchase errors and notify error listeners.
    _purchaseErrorSubscription = iap.purchaseErrorListener.listen((error) {
      // Notify error listeners with the error message.
      _listenerManager.notifyErrorListeners(
        purchaseError: error,
      );
    });

    // Fetch subscription & products items.
    await Future.wait([
      _subscriptionManager.fetchSubscriptionItems(),
      _productManager.fetchProductItems(),
    ]);
  }

  // Disposes of the stream subscriptions and finalizes the FlutterInappPurchase instance.
  void dispose() {
    _connectionSubscription.cancel();
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
  }

  // Adds a listener for pro status changes.
  void addProStatusChangedListener(ValueChanged<Purchase> callback) =>
      _listenerManager.addProStatusChangedListener(callback);

  // Removes a listener for pro status changes.
  void removeProStatusChangedListener(ValueChanged<Purchase> callback) =>
      _listenerManager.removeProStatusChangedListener(callback);

  // Adds a listener for errors.
  void addErrorListener(ValueChanged<PurchaseError?> callback) =>
      _listenerManager.addErrorListener(callback);

  // Removes a listener for errors.
  void removeErrorListener(ValueChanged<PurchaseError?> callback) =>
      _listenerManager.removeErrorListener(callback);

  // get subscription items list
  List<ProductCommon> get subscriptionItems =>
      _subscriptionManager.subscriptionItems;

  // get products items list
  List<ProductCommon> get productItems => _productManager.productItems;

  // Restores past purchases for the user.
  Future<bool> restorePastPurchases(BuildContext context) async {
    // Restore past purchases using the SubscriptionManager.
    final result = await _subscriptionManager.restorePastPurchases(
      context,
      _listenerManager,
    );
    return result;
  }

  // Purchases a subscription item.
  // Purchases a product or subscription item.
  // Purchases either an in-app product or subscription.
  Future<void> purchase(ProductCommon product) async {
    try {
      final iap = FlutterInappPurchase.instance;

      // 🎯 1. Handle In-App (one-time) products
      if (product.type == ProductType.InApp) {
        final requestProps = RequestPurchaseProps.inApp((
          ios: RequestPurchaseIosProps(sku: product.id),
          android: RequestPurchaseAndroidProps(
            skus: [product.id],
            obfuscatedAccountIdAndroid: "user_id", // optional
            obfuscatedProfileIdAndroid: "profile_id", // optional
          ),
          useAlternativeBilling: null,
        ));

        await iap.requestPurchase(requestProps);
        return;
      }

      // 💳 2. Handle Subscriptions
      if (product.type == ProductType.Subs) {
        if (Platform.isAndroid) {
          final offers = _getAndroidOffers(product);
          final requestProps = RequestPurchaseProps.subs((
            ios: null,
            android: RequestSubscriptionAndroidProps(
              skus: [product.id],
              subscriptionOffers: offers.isNotEmpty ? offers : null,
            ),
            useAlternativeBilling: null,
          ));

          await iap.requestPurchase(requestProps);
        } else if (Platform.isIOS) {
          final requestProps = RequestPurchaseProps.subs((
            ios: RequestSubscriptionIosProps(
              sku: product.id,
            ),
            android: null,
            useAlternativeBilling: null,
          ));

          await iap.requestPurchase(requestProps);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to purchase: $e");
      }
    }
  }

  List<AndroidSubscriptionOfferInput> _getAndroidOffers(ProductCommon product) {
    if (product is ProductAndroid) {
      final details = product.subscriptionOfferDetailsAndroid;
      if (details != null && details.isNotEmpty) {
        return [
          for (final offer in details)
            AndroidSubscriptionOfferInput(
              offerToken: offer.offerToken,
              sku: product.id, // must use product.id (not basePlanId)
            ),
        ];
      }
    }
    return [];
  }

  // Opens the subscription management page for the user.
  Future<void> manageSubscription() async {
    // Construct the URLs for Android and iOS.
    final androidUrl =
        Uri.parse('https://play.google.com/store/account/subscriptions');
    final iosUrl = Uri.parse('https://apps.apple.com/account/subscriptions');

    // Check the platform and choose the appropriate URL.
    final url = Platform.isAndroid ? androidUrl : iosUrl;

    // Check if the URL can be launched.
    if (await canLaunchUrl(url)) {
      // Launch the URL.
      await launchUrl(url);
    } else {
      // Log an error if the URL cannot be launched.
      if (kDebugMode) {
        print("Unable to launch subscription management page.");
      }
    }
  }

  // Checks if a product has been purchased.
  bool isProductPurchased(String productId) =>
      _purchaseHandler.isProductPurchased(productId);

  // Gets a list of purchased product IDs.
  List<String> get getPurchasedProductIds =>
      _purchaseHandler.getPurchasedProductIds;

  // Gets a list of subscription product IDs.
  List<ProductCommon> getSubscriptionItemsByIds(List<String> ids) =>
      _subscriptionManager.getItemsByIds(ids);

  // Gets a list of product item IDs.
  List<ProductCommon> getProductsItemsByIds(List<String> ids) =>
      _productManager.getItemsByIds(ids);
}
