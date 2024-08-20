import 'package:flutter/material.dart';
import 'package:flutter_store_kit/flutter_store_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPremiumUser = false;
  final List<IAPItem> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    StoreKit.instance.initialize([
      'subscription_id1',
      'subscription_id2',
      'subscription_id3',
    ]);

    StoreKit.instance.addProStatusChangedListener(_onProStatusChanged);
    StoreKit.instance.addErrorListener(_onError);
  }

  void _onProStatusChanged() {
    setState(() {
      _isPremiumUser = StoreKit.instance.isProductPurchased('subscription_id1');
    });
  }

  void _onError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  void _purchaseSubscription(IAPItem item) async {
    await StoreKit.instance.purchaseSubscription(item);
  }

  @override
  void dispose() {
    StoreKit.instance.removeProStatusChangedListener(_onProStatusChanged);
    StoreKit.instance.removeErrorListener(_onError);
    StoreKit.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Purchases'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isPremiumUser
                  ? 'You are a Premium User'
                  : 'You are not a Premium User',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            _availableProducts.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableProducts.length,
                    itemBuilder: (context, index) {
                      final product = _availableProducts[index];
                      return ListTile(
                        title: Text(product.title ?? 'No Title'),
                        subtitle: Text(product.description ?? 'No Description'),
                        trailing: _isPremiumUser
                            ? const Icon(Icons.check, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () => _purchaseSubscription(product),
                                child: const Text('Buy'),
                              ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
