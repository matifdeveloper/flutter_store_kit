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
import 'dart:io';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'listener_manager.dart';

/// Handles purchases and updates purchased products state.
class PurchaseHandler {
  static final instance = PurchaseHandler._privateConstructor();

  PurchaseHandler._privateConstructor();

  // Map to store purchased products (key = productId)
  final Map<String, Purchase> _purchasedProducts = {};

  /// Handles purchase updates (cross-platform)
  Future<void> handlePurchaseUpdate(Purchase? purchase) async {
    if (purchase == null) return;

    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(purchase);
    } else if (Platform.isIOS) {
      await _handlePurchaseUpdateIOS(purchase);
    }
  }

  /// Handles purchase updates for iOS (new API)
  Future<void> _handlePurchaseUpdateIOS(Purchase purchase) async {
    try {
      switch (purchase.purchaseState) {
        case PurchaseState.Purchased:
        case PurchaseState.Restored:
          await _verifyAndFinishTransaction(purchase);
          break;
        case PurchaseState.Pending:
          log('Purchase pending on iOS...');
          break;
        case PurchaseState.Failed:
          ListenerManager.instance.notifyErrorListeners();
          break;
        default:
          break;
      }
    } catch (e) {
      ListenerManager.instance.notifyErrorListeners();
      log('Error handling iOS purchase: $e');
    }
  }

  /// Handles purchase updates for Android (new API)
  Future<void> _handlePurchaseUpdateAndroid(Purchase purchase) async {
    try {
      if (purchase.purchaseState == PurchaseState.Purchased ||
          purchase.purchaseState == PurchaseState.Restored) {
        await _verifyAndFinishTransaction(purchase);
      } else if (purchase.purchaseState == PurchaseState.Pending) {
        log('Purchase pending on Android...');
      } else {
        ListenerManager.instance.notifyErrorListeners();
      }
    } catch (e) {
      ListenerManager.instance.notifyErrorListeners();
      log('Error handling Android purchase: $e');
    }
  }

  /// Verifies and finishes a transaction (new unified API)
  Future<void> _verifyAndFinishTransaction(Purchase purchase) async {
    bool isValid = false;

    try {
      // 🔒 Step 1: Verify purchase on your server
      // Replace with your real verification logic
      isValid = true;

      // 🧾 Step 2: Deliver content if verified
      if (isValid) {
        await deliverContent(purchase.productId);
      }

      // ✅ Step 3: Finish transaction (consumable or non-consumable)
      await FlutterInappPurchase.instance.finishTransaction(
        purchase: purchase,
        isConsumable: false, // or true for consumables
      );

      // 🗂 Step 4: Update state and notify listeners
      addPurchasedProduct(purchase.productId, purchase);
      ListenerManager.instance.notifyProStatusChangedListeners(purchase);
    } catch (e) {
      ListenerManager.instance.notifyErrorListeners();
      log('Error verifying or finishing transaction: $e');
    }
  }

  /// Checks if a product is purchased
  bool isProductPurchased(String productId) =>
      _purchasedProducts.containsKey(productId);

  /// Returns a list of purchased product IDs
  List<String> get getPurchasedProductIds => _purchasedProducts.keys.toList();

  /// Adds a purchased product to the cache
  void addPurchasedProduct(String key, Purchase purchase) {
    _purchasedProducts[key] = purchase;
  }

  /// Example content delivery
  Future<void> deliverContent(String productId) async {
    if (productId == 'premium_upgrade') {
      log('Premium unlocked for $productId');
      // Update user flags, backend, or local storage here
    }
  }
}
