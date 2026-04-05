import 'package:flutter/material.dart';
import 'package:revenue_cats/subscriptions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SubscriptionsService.instance.initRevenueCat();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String? memberType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _fetchPackages(),
      _checkMembership(),
    ]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkMembership() async {
    final isPremium = await SubscriptionsService.instance.checkingMembership();
    if (mounted) {
      setState(() {
        memberType = isPremium ? "Premium User" : "Free User";
      });
    }
  }

  Future<void> _fetchPackages() async {
    await SubscriptionsService.instance.getOfferings();
  }

  @override
  Widget build(BuildContext context) {
    final packages = SubscriptionsService.packages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: true,
        actions: [
          if (memberType != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  memberType!,
                  style: TextStyle(
                    color: memberType == "Premium User" ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: memberType == "Premium User" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  child: Text(
                    "Status: ${memberType ?? 'Checking...'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: memberType == "Premium User" ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                Expanded(
                  child: packages == null || packages.isEmpty
                      ? const Center(child: Text('No packages available'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: packages.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final package = packages[index];
                            final product = package.storeProduct;

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product.priceString,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await SubscriptionsService.instance.purchase(package);
                                            _checkMembership(); // Refresh status after purchase
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Subscribe'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),


                ElevatedButton(
                    onPressed: ()=> SubscriptionsService.instance.logout(),
                    child: Text(
                        "Log Out"
                    )
                ),
                SizedBox(height: 16),

                ElevatedButton(
                    onPressed: ()=> SubscriptionsService.instance.restore(),
                    child: Text(
                      "Restore"
                    )
                ),
                SizedBox(height: 16),

              ],
            ),
    );
  }
}
