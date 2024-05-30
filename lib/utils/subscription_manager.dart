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
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'listener_manager.dart';

// A class that manages subscriptions for in-app purchases.
class SubscriptionManager {
  // A list to store the subscription items fetched from the store.
  List<IAPItem> _subscriptionItems = [];
  // A list of subscription IDs for different premium features.
  late List<String> _subscriptionIds;

  // Constructor to initialize the subscription manager with subscription IDs.
  SubscriptionManager(List<String> subscriptionIds) {
    _subscriptionIds = subscriptionIds;
  }

  // A method to fetch subscription items from the store.
  Future<void> fetchSubscriptionItems() async {
    try {
      // Fetch the subscription items from the store using the subscription IDs.
      _subscriptionItems = await FlutterInappPurchase.instance
          .getSubscriptions(_subscriptionIds);

      // Sort the subscription items in the order of their IDs.
      _subscriptionItems.sort((a, b) => _subscriptionIds
          .indexOf(a.productId!)
          .compareTo(_subscriptionIds.indexOf(b.productId!)));

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
  Future<void> restorePastPurchases(
      BuildContext context, ListenerManager listenerManager) async {
    try {
      // Get a list of available purchases from the store.
      List<PurchasedItem>? purchasedItems =
          await FlutterInappPurchase.instance.getAvailablePurchases();

      if (purchasedItems != null) {
        // Iterate over each purchased item.
        for (var purchasedItem in purchasedItems) {
          if (Platform.isAndroid) {
            // On Android, decode the transaction receipt and check if it's acknowledged.
            var receiptData = json.decode(purchasedItem.transactionReceipt!);
            if (!receiptData['acknowledged']) {
              // Assume verification is successful for now.
              bool isValid = true;
              if (isValid) {
                // Finish the transaction and notify pro status changed listeners.
                await FlutterInappPurchase.instance
                    .finishTransaction(purchasedItem);
                listenerManager.notifyProStatusChangedListeners();
              }
            } else {
              // If the receipt is acknowledged, notify pro status changed listeners.
              listenerManager.notifyProStatusChangedListeners();
            }
          } else if (Platform.isIOS) {
            // On iOS, finish the transaction and notify pro status changed listeners.
            await FlutterInappPurchase.instance
                .finishTransaction(purchasedItem);
            await FlutterInappPurchase.instance
                .finishTransactionIOS(purchasedItem.transactionId!);
            listenerManager.notifyProStatusChangedListeners();
          }
        }
      }
    } catch (e) {
      // Log an error if restoring past purchases fails.
      if (kDebugMode) {
        print("Failed to restore past purchases: $e");
      }
    }
  }
}
