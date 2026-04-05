import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionsService {
  const SubscriptionsService._();

  static final SubscriptionsService _instance = SubscriptionsService._();

  static SubscriptionsService get instance => _instance;

  static List<Package>? packages;

  Future<void> initRevenueCat() async {
    await Purchases.configure(
        PurchasesConfiguration("test_JnBhCkFEDZytfAvIQRRjrRogXOZ"));
    await Purchases.logIn("SajibHasan");
  }

  Future<void> getOfferings() async {
    Offerings offerings = await Purchases.getOfferings();

    if (offerings.current != null) {
      packages = offerings.current!.availablePackages;
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

  Future<bool> checkingMembership() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.isNotEmpty;
  }


  Future<void> logout() async {
    await Purchases.logOut();
  }

  Future<void> restore() async {
    final customerInfo = await Purchases.restorePurchases();
    print("Restored: ${customerInfo.entitlements.active}");
  }

}