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
    IsloAI

 *********************************************************************************/

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'listener_manager.dart';
import 'purchase_handler.dart';
import 'subscription_manager.dart';

// A singleton class that provides a service for managing in-app purchases.
class StoreKit {
  // Private constructor to ensure singleton instance.
  StoreKit._private();

  // The singleton instance of the StoreService.
  static final StoreKit instance = StoreKit._private();

  // Late-initialized variables for stream subscriptions.
  late final StreamSubscription<ConnectionResult> _connectionSubscription;
  late final StreamSubscription<PurchasedItem?> _purchaseUpdatedSubscription;
  late final StreamSubscription<PurchaseResult?> _purchaseErrorSubscription;

  // Instances of PurchaseHandler, SubscriptionManager, and ListenerManager.
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  late final SubscriptionManager _subscriptionManager;
  final ListenerManager _listenerManager = ListenerManager.instance;

  // Initializes the connection to the in-app purchase service.
  Future<void> initialize(List<String> subscriptionIds) async {
    // Initialize the SubscriptionManager with subscription IDs.
    _subscriptionManager = SubscriptionManager(subscriptionIds);

    try {
      // Initialize the FlutterInappPurchase instance.
      final initResult = await FlutterInappPurchase.instance.initialize();
      // Log the initialization result.
      if (kDebugMode) {
        print(initResult ?? 'unknown');
      }
    } catch (e) {
      // Log any errors that occur during initialization.
      if (kDebugMode) {
        print(e.toString());
      }
    }

    // Listen for connection updates.
    _connectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((_) {});
    // Listen for purchase updates and handle them using the PurchaseHandler.
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated
        .listen(_purchaseHandler.handlePurchaseUpdate);
    // Listen for purchase errors and notify error listeners.
    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((error) {
      if (error != null) {
        // Notify error listeners with the error message.
        _listenerManager.notifyErrorListeners(
          purchaseError: error,
        );
      }
    });

    // Fetch subscription items.
    await _subscriptionManager.fetchSubscriptionItems();
  }

  // Disposes of the stream subscriptions and finalizes the FlutterInappPurchase instance.
  void dispose() {
    _connectionSubscription.cancel();
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    FlutterInappPurchase.instance.finalize();
  }

  // Adds a listener for pro status changes.
  void addProStatusChangedListener(ValueChanged<PurchasedItem> callback) =>
      _listenerManager.addProStatusChangedListener(callback);

  // Removes a listener for pro status changes.
  void removeProStatusChangedListener(ValueChanged<PurchasedItem> callback) =>
      _listenerManager.removeProStatusChangedListener(callback);

  // Adds a listener for errors.
  void addErrorListener(ValueChanged<PurchaseResult?> callback) =>
      _listenerManager.addErrorListener(callback);

  // Removes a listener for errors.
  void removeErrorListener(ValueChanged<PurchaseResult?> callback) =>
      _listenerManager.removeErrorListener(callback);

  // get subscription items list
  List<IAPItem> get subscriptionItems => _subscriptionManager.subscriptionItems;

  // Restores past purchases for the user.
  Future<void> restorePastPurchases(BuildContext context) async {
    // Restore past purchases using the SubscriptionManager.
    await _subscriptionManager.restorePastPurchases(context, _listenerManager);
  }

  // Purchases a subscription item.
  Future<void> purchaseSubscription(IAPItem item) async {
    try {
      // Request a subscription purchase using the FlutterInappPurchase instance.
      await FlutterInappPurchase.instance.requestSubscription(item.productId!);
    } catch (e) {
      // Log any errors that occur during the purchase.
      if (kDebugMode) {
        print("Failed to purchase subscription: $e");
      }
    }
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
  List<String> getPurchasedProductIds() =>
      _purchaseHandler.getPurchasedProductIds();

  // Gets a list of subscription product IDs.
  List<IAPItem> getItemsByIds(List<String> ids) =>
      _subscriptionManager.getItemsByIds(ids);
}
