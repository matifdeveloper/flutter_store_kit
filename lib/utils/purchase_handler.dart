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

import 'dart:io';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'listener_manager.dart';

class PurchaseHandler {
  final ListenerManager<void> proStatusChangedListener;
  final ListenerManager<String> errorListener;
  final List<PurchasedItem> _pastPurchases = [];

  PurchaseHandler(this.proStatusChangedListener, this.errorListener);

  void handlePurchaseError(PurchaseResult? purchaseError) {
    errorListener.notifyListeners(purchaseError!.message!);
  }

  void handlePurchaseUpdate(PurchasedItem? productItem) async {
    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(productItem!);
    } else {
      await _handlePurchaseUpdateIOS(productItem!);
    }
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.deferred:
        break;
      case TransactionState.failed:
        errorListener.notifyListeners("Transaction Failed");
        break;
      case TransactionState.purchased:
        await _verifyAndFinishTransaction(purchasedItem);
        break;
      case TransactionState.purchasing:
        break;
      case TransactionState.restored:
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        FlutterInappPurchase.instance.finishTransactionIOS(purchasedItem.transactionId!);
        break;
      default:
    }
  }

  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
    switch (purchasedItem.purchaseStateAndroid) {
      case PurchaseState.purchased:
        if (!purchasedItem.isAcknowledgedAndroid!) {
          await _verifyAndFinishTransaction(purchasedItem);
        }
        break;
      default:
        errorListener.notifyListeners("Something went wrong");
    }
  }

  Future<void> _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    bool isValid = false;
    try {
      if (Platform.isAndroid) {
        await FlutterInappPurchase.instance.acknowledgePurchaseAndroid(purchasedItem.purchaseToken!);
      }
      isValid = true; // Replace with actual verification logic
    } on Exception {
      errorListener.notifyListeners("Something went wrong");
      return;
    }

    if (isValid) {
      if (Platform.isAndroid) {
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
      } else {
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        FlutterInappPurchase.instance.finishTransactionIOS(purchasedItem.transactionId!);
      }

      proStatusChangedListener.notifyListeners(null);
    }
  }

  bool isProductPurchased(String productId) {
    return _pastPurchases.any((purchase) => purchase.productId == productId);
  }

  List<String> getPurchasedProductIds() {
    return _pastPurchases.map((purchase) => purchase.productId!).toList();
  }
}
