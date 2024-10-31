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

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

// A singleton class that manages listeners for pro status changed and error events.
class ListenerManager {
  // Private constructor to ensure singleton instance.
  ListenerManager._private();

  // The singleton instance of the ListenerManager.
  static final ListenerManager instance = ListenerManager._private();

  // A list of listeners that will be notified when the pro status changes.
  final ObserverList<ValueChanged<PurchasedItem>> _proStatusChangedListeners =
      ObserverList<ValueChanged<PurchasedItem>>();

  // A list of listeners that will be notified when an error occurs.
  final ObserverList<ValueChanged<PurchaseResult?>> _errorListeners =
      ObserverList<ValueChanged<PurchaseResult?>>();

  // Adds a listener to the list of pro status changed listeners.
  void addProStatusChangedListener(ValueChanged<PurchasedItem> callback) =>
      _proStatusChangedListeners.add(callback);

  // Removes a listener from the list of pro status changed listeners.
  void removeProStatusChangedListener(ValueChanged<PurchasedItem> callback) =>
      _proStatusChangedListeners.remove(callback);

  // Adds a listener to the list of error listeners.
  void addErrorListener(ValueChanged<PurchaseResult?> callback) =>
      _errorListeners.add(callback);

  // Removes a listener from the list of error listeners.
  void removeErrorListener(ValueChanged<PurchaseResult?> callback) =>
      _errorListeners.remove(callback);

  // Notifies all pro status changed listeners.
  void notifyProStatusChangedListeners(PurchasedItem purchasedItem) {
    // Iterate over the list of pro status changed listeners and call each callback.
    for (var callback in _proStatusChangedListeners) {
      callback(purchasedItem);
    }
  }

  // Notifies all error listeners with the given error message.
  void notifyErrorListeners({PurchaseResult? purchaseError}) {
    // Iterate over the list of error listeners and call each callback with the error message.
    for (var callback in _errorListeners) {
      callback(purchaseError);
    }
  }
}
