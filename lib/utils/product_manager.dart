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
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

// A class that manages products for in-app purchases.
class ProductManager {
  // Constructor to initialize the products manager with products IDs.
  ProductManager(List<String> productIds) {
    _productIds = productIds;
  }

  final iap = FlutterInappPurchase.instance;

  // A list to store the products items fetched from the store.
  List<ProductCommon> _productItems = [];

  List<ProductCommon> get productItems => _productItems;

  // Method to filter items by IDs
  List<ProductCommon> getItemsByIds(List<String> ids) {
    return _productItems.where((item) => ids.contains(item.id)).toList();
  }

  // A list of products IDs for different premium features.
  late List<String> _productIds;

  // A method to fetch products items from the store.
  Future<void> fetchProductItems() async {
    try {
      // Fetch the products items from the store using the products IDs.
      _productItems = await iap.fetchProducts(
        skus: _productIds,
        type: ProductQueryType.InApp,
      );

      // Sort the products items in the order of their IDs.
      _productItems.sort((a, b) =>
          _productIds.indexOf(a.id).compareTo(_productIds.indexOf(b.id)));

      if (kDebugMode) {
        print(_productItems);
      }
    } catch (e) {
      // Log an error if fetching products items fails.
      if (kDebugMode) {
        print("Failed to fetch products items: $e");
      }
    }
  }
}
