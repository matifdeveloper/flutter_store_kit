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
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_store_kit/utils/purchase_handler.dart';
import 'listener_manager.dart';

// A class that manages subscriptions for in-app purchases.
class SubscriptionManager {
  // Constructor to initialize the subscription manager with subscription IDs.
  SubscriptionManager(List<String> subscriptionIds) {
    _subscriptionIds = subscriptionIds;
  }

  final iap = FlutterInappPurchase.instance;

  // A list to store the subscription items fetched from the store.
  List<ProductCommon> _subscriptionItems = [];

  List<ProductCommon> get subscriptionItems => _subscriptionItems;

  // Method to filter items by IDs
  List<ProductCommon> getItemsByIds(List<String> ids) {
    return _subscriptionItems.where((item) => ids.contains(item.id)).toList();
  }

  // A list of subscription IDs for different premium features.
  late List<String> _subscriptionIds;

  // A method to fetch subscription items from the store.
  Future<void> fetchSubscriptionItems() async {
    try {
      // Fetch the subscription items from the store using the subscription IDs.
      _subscriptionItems = await iap.fetchProducts(
        skus: _subscriptionIds,
        type: ProductQueryType.Subs,
      );

      // Sort the subscription items in the order of their IDs.
      _subscriptionItems.sort((a, b) => _subscriptionIds
          .indexOf(a.id)
          .compareTo(_subscriptionIds.indexOf(b.id)));

      if (kDebugMode) {
        print(_subscriptionItems);
      }
    } catch (e) {
      // Log an error if fetching subscription items fails.
      if (kDebugMode) {
        print("Failed to fetch subscription items: $e");
      }
    }
  }

  // A method to restore past purchases and update the pro status.
  Future<bool> restorePastPurchases(
    BuildContext context,
    ListenerManager listenerManager,
  ) async {
    try {
      final iap = FlutterInappPurchase.instance;

      // 🔄 Trigger platform restore flow (iOS-compliant)
      await iap.restorePurchases();

      // 🧾 Get all available (non-consumable + subscription) purchases
      final purchases = await iap.getAvailablePurchases();

      log('Available purchases -------------> ${purchases.length}');

      for (final purchase in purchases) {
        // ✅ Notify listeners for each valid purchase
        listenerManager.notifyProStatusChangedListeners(purchase);

        // ✅ Add purchase item to your PurchaseHandler
        PurchaseHandler.instance.addPurchasedProduct(
          purchase.productId,
          purchase,
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to restore past purchases: $e");
      }
      return false;
    }
  }
}
