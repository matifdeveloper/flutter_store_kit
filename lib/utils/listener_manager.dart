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

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

// A singleton class that manages listeners for pro status changed and error events.
class ListenerManager {
  // Private constructor to ensure singleton instance.
  ListenerManager._private();

  // The singleton instance of the ListenerManager.
  static final ListenerManager instance = ListenerManager._private();

  // A list of listeners that will be notified when the pro status changes.
  final ObserverList<ValueChanged<Purchase>> _proStatusChangedListeners =
      ObserverList<ValueChanged<Purchase>>();

  // A list of listeners that will be notified when an error occurs.
  final ObserverList<ValueChanged<PurchaseError?>> _errorListeners =
      ObserverList<ValueChanged<PurchaseError?>>();

  // Adds a listener to the list of pro status changed listeners.
  void addProStatusChangedListener(ValueChanged<Purchase> callback) =>
      _proStatusChangedListeners.add(callback);

  // Removes a listener from the list of pro status changed listeners.
  void removeProStatusChangedListener(ValueChanged<Purchase> callback) =>
      _proStatusChangedListeners.remove(callback);

  // Adds a listener to the list of error listeners.
  void addErrorListener(ValueChanged<PurchaseError?> callback) =>
      _errorListeners.add(callback);

  // Removes a listener from the list of error listeners.
  void removeErrorListener(ValueChanged<PurchaseError?> callback) =>
      _errorListeners.remove(callback);

  // Notifies all pro status changed listeners.
  void notifyProStatusChangedListeners(Purchase purchasedItem) {
    // Iterate over the list of pro status changed listeners and call each callback.
    for (var callback in _proStatusChangedListeners) {
      callback(purchasedItem);
    }
  }

  // Notifies all error listeners with the given error message.
  void notifyErrorListeners({PurchaseError? purchaseError}) {
    // Iterate over the list of error listeners and call each callback with the error message.
    for (var callback in _errorListeners) {
      callback(purchaseError);
    }
  }
}
