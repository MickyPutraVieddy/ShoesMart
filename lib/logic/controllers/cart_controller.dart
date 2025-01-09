import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_models.dart';
import '../../routes/routes.dart';
import '../../utils/theme.dart';

class CartController extends GetxController {
  var productMap = {}.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchCartFromFirestore();
  }

  // Fetch cart from Firestore
  Future<void> fetchCartFromFirestore() async {
    if (currentUser == null) return;

    try {
      var cartSnapshot =
          await firestore.collection('carts').doc(currentUser!.uid).get();
      if (cartSnapshot.exists) {
        var data = cartSnapshot.data()!;
        var entries = (data['products'] as List).map((item) {
          var product = ProductModels.fromMap(item);
          return MapEntry(product, item['qty']);
        });
        productMap.value = Map.fromEntries(entries);
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  // Add product to cart
  void addProductToCart(ProductModels productModels) {
    if (productMap.containsKey(productModels)) {
      productMap[productModels] += 1;
    } else {
      productMap[productModels] = 1;
    }
    updateCartInFirestore();
  }

  // Remove product from cart
  void removeProductsFromCart(ProductModels productModels) {
    if (productMap.containsKey(productModels) &&
        productMap[productModels] == 1) {
      productMap.removeWhere((key, value) => key == productModels);
    } else {
      productMap[productModels] -= 1;
    }
    updateCartInFirestore();
  }

  // Remove one product from cart
  void removeOneProduct(ProductModels productModels) {
    productMap.removeWhere((key, value) => key == productModels);
    updateCartInFirestore();
  }

  // Clear all products from cart
  void clearAllProducts() {
    Get.defaultDialog(
      title: 'Clean Products',
      titleStyle: const TextStyle(
        fontSize: 18.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      middleText: 'Are you sure you need clear products',
      middleTextStyle: const TextStyle(
        fontSize: 18.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.grey,
      radius: 10.0,
      textCancel: 'No',
      cancelTextColor: Colors.white,
      textConfirm: 'Yes',
      confirmTextColor: Colors.white,
      onCancel: () {
        Get.toNamed(Routes.cartScreen);
      },
      onConfirm: () async {
        productMap.clear();
        await firestore.collection('carts').doc(currentUser?.uid).delete();
        Get.back();
      },
      buttonColor: Get.isDarkMode ? pinkClr : mainColor,
    );
  }

  // Update cart in Firestore
  Future<void> updateCartInFirestore() async {
    if (currentUser == null) return;

    try {
      await firestore.collection('carts').doc(currentUser!.uid).set({
        'products': productMap.entries.map((entry) {
          return {
            'id': entry.key.id,
            'title': entry.key.title,
            'price': entry.key.price,
            'description': entry.key.description,
            'category': entry.key.category.toString().split('.').last,
            'image': entry.key.image,
            'rating': {
              'rate': entry.key.rating.rate,
              'count': entry.key.rating.count,
            },
            'qty': entry.value,
            'total': (entry.key.price * entry.value).toStringAsFixed(2),
          };
        }).toList(),
      });
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  // Get product subtotal
  get productSubTotal =>
      productMap.entries.map((e) => e.key.price * e.value).toList();

  // Get total
  get total => productMap.entries
      .map((e) => e.key.price * e.value)
      .toList()
      .reduce((value, element) => value + element)
      .toStringAsFixed(2);

  // Get quantity
  int quantity() {
    if (productMap.isEmpty) {
      return 0;
    } else {
      return productMap.entries
          .map((e) => e.value)
          .toList()
          .reduce((value, element) => value + element);
    }
  }
}
