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
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'listener_manager.dart';

// A class that handles purchases and updates the state of purchased products.
class PurchaseHandler {
  // A map to store purchased products, where the key is the product ID and the value is the PurchasedItem object.
  final Map<String, PurchasedItem> _purchasedProducts = {};

  // Handles purchase updates for both Android and iOS platforms.
  Future<void> handlePurchaseUpdate(PurchasedItem? productItem) async {
    // If the product item is not null, handle the purchase update based on the platform.
    if (productItem != null) {
      if (Platform.isAndroid) {
        // Handle purchase update for Android.
        await _handlePurchaseUpdateAndroid(productItem);
      } else {
        // Handle purchase update for iOS.
        await _handlePurchaseUpdateIOS(productItem);
      }
    }
  }

  // Handles purchase updates specifically for iOS.
  Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
    // Switch based on the transaction state of the purchased item.
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.deferred:
        // Handle deferred transaction state.
        break;
      case TransactionState.failed:
        // Notify error listeners if the transaction failed.
        ListenerManager.instance.notifyErrorListeners("Transaction Failed");
        break;
      case TransactionState.purchased:
        // Verify and finish the transaction if it's purchased.
        await _verifyAndFinishTransaction(purchasedItem);
        break;
      case TransactionState.purchasing:
        // Handle purchasing transaction state.
        break;
      case TransactionState.restored:
        // Finish the transaction if it's restored.
        await FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        await FlutterInappPurchase.instance
            .finishTransactionIOS(purchasedItem.transactionId!);
        break;
      default:
        // Handle default transaction state.
        break;
    }
  }

  // Handles purchase updates specifically for Android.
  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
    // Check if the purchase state is purchased and not acknowledged.
    if (purchasedItem.purchaseStateAndroid == PurchaseState.purchased &&
        !purchasedItem.isAcknowledgedAndroid!) {
      // Verify and finish the transaction.
      await _verifyAndFinishTransaction(purchasedItem);
    } else {
      // Notify error listeners if something went wrong.
      ListenerManager.instance.notifyErrorListeners("Something went wrong");
    }
  }

  // Verifies the purchase and finishes the transaction.
  Future<void> _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    bool isValid = false;
    try {
      // Acknowledge the purchase on Android.
      if (Platform.isAndroid) {
        await FlutterInappPurchase.instance
            .acknowledgePurchaseAndroid(purchasedItem.purchaseToken!);
      }
      // Call API to verify purchase here
      isValid = true; // Assume the verification is successful for this example
    } catch (e) {
      // Notify error listeners if something went wrong.
      ListenerManager.instance.notifyErrorListeners("Something went wrong");
      return;
    }

    // If the verification is successful, finish the transaction and update the purchased products.
    if (isValid) {
      await FlutterInappPurchase.instance.finishTransaction(purchasedItem);
      if (Platform.isIOS) {
        await FlutterInappPurchase.instance
            .finishTransactionIOS(purchasedItem.transactionId!);
      }
      _purchasedProducts[purchasedItem.productId!] = purchasedItem;
      ListenerManager.instance.notifyProStatusChangedListeners();
    } /*else {
      // Notify error listeners if the verification failed.
      //ListenerManager.instance.notifyErrorListeners("Verification failed");
    }*/
  }

  // Checks if a product is purchased based on its ID.
  bool isProductPurchased(String productId) =>
      _purchasedProducts.containsKey(productId);

  // Returns a list of purchased product IDs.
  List<String> getPurchasedProductIds() => _purchasedProducts.keys.toList();
}
