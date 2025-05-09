import 'package:flutter/material.dart';
import 'package:myapp/core/notifier/nfc_notifier.dart';
import 'package:provider/provider.dart';

class ReadWriteNFCScreen extends StatelessWidget {
  const ReadWriteNFCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NFCNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tap-to-Pay'),
        ),
        body: Builder(
          builder: (context) {
            final provider = Provider.of<NFCNotifier>(context);

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter amount',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      provider.paymentAmount = double.tryParse(val) ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: provider.isProcessing
                        ? null
                        : () {
                            provider.startNFCOperation();
                          },
                    child: const Text('Tap Card to Pay'),
                  ),
                  const SizedBox(height: 20),
                  if (provider.isProcessing) const CircularProgressIndicator(),
                  if (provider.message.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      provider.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
