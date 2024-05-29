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

import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'dart:async';

class SubscriptionManager {
  final List<String> subscriptionIds;
  List<IAPItem> _subscriptionItems = [];

  SubscriptionManager(this.subscriptionIds);

  List<IAPItem> get subscriptionItems => _subscriptionItems;

  Future<void> fetchSubscriptionItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(subscriptionIds);
    _subscriptionItems = items;
  }
}
