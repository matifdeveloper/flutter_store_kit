import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

// A class that manages products for in-app purchases.
class ProductManager {
  // Constructor to initialize the products manager with products IDs.
  ProductManager(List<String> productIds) {
    _productIds = productIds;
  }

  // A list to store the products items fetched from the store.
  List<IAPItem> _productItems = [];
  List<IAPItem> get productItems => _productItems;

  // Method to filter items by IDs
  List<IAPItem> getItemsByIds(List<String> ids) {
    return _productItems.where((item) => ids.contains(item.productId)).toList();
  }

  // A list of products IDs for different premium features.
  late List<String> _productIds;

  // A method to fetch products items from the store.
  Future<void> fetchProductItems() async {
    try {
      // Fetch the products items from the store using the products IDs.
      _productItems =
          await FlutterInappPurchase.instance.getProducts(_productIds);

      // Sort the products items in the order of their IDs.
      _productItems.sort((a, b) => _productIds
          .indexOf(a.productId!)
          .compareTo(_productIds.indexOf(b.productId!)));

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
