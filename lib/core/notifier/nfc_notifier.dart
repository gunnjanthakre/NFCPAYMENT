import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCNotifier extends ChangeNotifier {
  bool _isProcessing = false;
  String _message = "";

  bool get isProcessing => _isProcessing;
  String get messgage => _message;

  final Map<String, double> userBalances = {
    '7D2AF116': 2000.0, // Your card UID in uppercase and without colons
  };

  double paymentAmount = 50.0; // Can be changed from UI

  Future<void> startNFCOperation() async {
    try {
      _isProcessing = true;
      _message = "Tap your NFC card...";
      notifyListeners();

      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _isProcessing = false;
        _message = "Please enable NFC in settings.";
        notifyListeners();
        return;
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          await _handlePayment(tag);
          _isProcessing = false;
          notifyListeners();
          await NfcManager.instance.stopSession();
        },
        onError: (e) async {
          _isProcessing = false;
          _message = "NFC Error: $e";
          notifyListeners();
        },
      );
    } catch (e) {
      _isProcessing = false;
      _message = "Error: $e";
      notifyListeners();
    }
  }

  Future<void> _handlePayment(NfcTag tag) async {
    try {
      final uidBytes = tag.data["nfca"]?["identifier"];
      if (uidBytes == null) {
        _message = "Card UID not found!";
        return;
      }

      final uid = _convertToHex(uidBytes);
      if (!userBalances.containsKey(uid)) {
        _message = "Unrecognized card!";
        return;
      }

      double balance = userBalances[uid]!;
      if (balance >= paymentAmount) {
        userBalances[uid] = balance - paymentAmount;
        _message = "₹$paymentAmount paid!\nNew Balance: ₹${userBalances[uid]!.toStringAsFixed(2)}";
      } else {
        _message = "Insufficient funds!\nBalance: ₹${balance.toStringAsFixed(2)}";
      }
    } catch (e) {
      _message = "Transaction failed: $e";
    }
  }

  String _convertToHex(List<dynamic> bytes) {
    return bytes.map((e) {
      int val = (e is int) ? e : int.parse(e.toString());
      return val.toRadixString(16).padLeft(2, '0').toUpperCase();
    }).join();
  }
}