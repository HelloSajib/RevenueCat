import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionsService {
  const SubscriptionsService._();

  Future<void> initRevenueCat() async {
    await Purchases.configure(
      PurchasesConfiguration("YOUR_PUBLIC_API_KEY"),
    );
  }

  Future<void> getOfferings() async {
    Offerings offerings = await Purchases.getOfferings();

    if (offerings.current != null) {
      final packages = offerings.current!.availablePackages;
      print(packages);
    }
  }

  Future<void> purchase(Package package) async {
    try {
      final purchase = await Purchases.purchase(PurchaseParams.package(package));
      if (purchase.customerInfo.entitlements.active.isNotEmpty) {
        print("Purchase successful!");
      }
    } catch (e) {
      print("Purchase failed: $e");
    }
  }

  Future<void> restore() async {
    CustomerInfo customerInfo = await Purchases.restorePurchases();
    print("Restored: ${customerInfo.entitlements.active}");
  }

}