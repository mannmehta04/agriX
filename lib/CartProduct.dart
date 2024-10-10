import 'package:cloud_firestore/cloud_firestore.dart';

class CartProduct {
  final String productId;
  final String name;
  final String desc;
  final double price;
  final String? img1Url;
  final String? img2Url;
  final String? img3Url;
  final int quantity;

  CartProduct({
    required this.productId,
    required this.name,
    required this.desc,
    required this.price,
    required this.quantity,
    this.img1Url,
    this.img2Url,
    this.img3Url,
  });

  double get totalPrice => price * quantity;

  factory CartProduct.fromDocument(DocumentSnapshot doc, int quantity) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartProduct(
      productId: doc.id,
      name: data['name'],
      desc: data['desc'],
      price: double.parse(data['price']),
      img1Url: data['img1Url'],
      img2Url: data['img2Url'],
      img3Url: data['img3Url'],
      quantity: quantity,
    );
  }
}