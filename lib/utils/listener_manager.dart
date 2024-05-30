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

// A singleton class that manages listeners for pro status changed and error events.
class ListenerManager {
  // Private constructor to ensure singleton instance.
  ListenerManager._private();

  // The singleton instance of the ListenerManager.
  static final ListenerManager instance = ListenerManager._private();

  // A list of listeners that will be notified when the pro status changes.
  final ObserverList<VoidCallback> _proStatusChangedListeners = ObserverList<VoidCallback>();

  // A list of listeners that will be notified when an error occurs.
  final ObserverList<ValueChanged<String>> _errorListeners = ObserverList<ValueChanged<String>>();

  // Adds a listener to the list of pro status changed listeners.
  void addProStatusChangedListener(VoidCallback callback) => _proStatusChangedListeners.add(callback);

  // Removes a listener from the list of pro status changed listeners.
  void removeProStatusChangedListener(VoidCallback callback) => _proStatusChangedListeners.remove(callback);

  // Adds a listener to the list of error listeners.
  void addErrorListener(ValueChanged<String> callback) => _errorListeners.add(callback);

  // Removes a listener from the list of error listeners.
  void removeErrorListener(ValueChanged<String> callback) => _errorListeners.remove(callback);

  // Notifies all pro status changed listeners.
  void notifyProStatusChangedListeners() {
    // Iterate over the list of pro status changed listeners and call each callback.
    for (var callback in _proStatusChangedListeners) {
      callback();
    }
  }

  // Notifies all error listeners with the given error message.
  void notifyErrorListeners(String error) {
    // Iterate over the list of error listeners and call each callback with the error message.
    for (var callback in _errorListeners) {
      callback(error);
    }
  }
}