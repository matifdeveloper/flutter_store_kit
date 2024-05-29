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
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'listener_manager.dart';
import 'subscription_manager.dart';
import 'purchase_handler.dart';

class StoreKit {
  StoreKit._private();
  static final StoreKit instance = StoreKit._private();

  late StreamSubscription<ConnectionResult> _connectionSubscription;
  late StreamSubscription<PurchasedItem?> _purchaseUpdatedSubscription;
  late StreamSubscription<PurchaseResult?> _purchaseErrorSubscription;

  late ListenerManager proStatusChangedListener;
  late ListenerManager<String> errorListener;
  late ListenerManager productsFetchedListener;
  late SubscriptionManager subscriptionManager;
  late PurchaseHandler purchaseHandler;

  void initialize(List<String> subscriptionIds) {
    proStatusChangedListener = ListenerManager();
    errorListener = ListenerManager<String>();
    productsFetchedListener = ListenerManager();
    subscriptionManager = SubscriptionManager(subscriptionIds);
    purchaseHandler = PurchaseHandler(proStatusChangedListener, errorListener);

    initConnection();
  }

  Future<void> initConnection() async {
    try {
      final initResult = await FlutterInappPurchase.instance.initialize();
      if (kDebugMode) {
        print(initResult ?? 'unknown');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {});
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(purchaseHandler.handlePurchaseUpdate);
    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen(purchaseHandler.handlePurchaseError);

    await subscriptionManager.fetchSubscriptionItems();
    productsFetchedListener.notifyListeners(null);
  }

  void dispose() {
    _connectionSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    _purchaseUpdatedSubscription.cancel();
    FlutterInappPurchase.instance.finalize();
  }

  Future<void> purchaseSubscription(IAPItem item) async {
    try {
      await FlutterInappPurchase.instance.requestSubscription(item.productId!);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  bool isProductPurchased(String productId) {
    return purchaseHandler.isProductPurchased(productId);
  }

  List<String> getPurchasedProductIds() {
    return purchaseHandler.getPurchasedProductIds();
  }
}
