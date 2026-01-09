import 'dart:convert';

class OrderResponse {
  final bool status;
  final List<Order> data;

  OrderResponse({
    required this.status,
    required this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Order.fromJson(i)).toList()
          : [],
    );
  }
}

class Order {
  final int id;
  final int userId;
  final int? offerId;
  final String? couponCode;
  final String orderNumber;
  final String subtotal;
  final String deliveryCharge;
  final String discount;
  final String couponDiscount;
  final String totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.userId,
    this.offerId,
    this.couponCode,
    required this.orderNumber,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.couponDiscount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      offerId: json['offer_id'],
      couponCode: json['coupon_code'],
      orderNumber: json['order_number'] ?? '',
      subtotal: json['subtotal'] ?? '0.00',
      deliveryCharge: json['delivery_charge'] ?? '0.00',
      discount: json['discount'] ?? '0.00',
      couponDiscount: json['coupon_discount'] ?? '0.00',
      totalAmount: json['total_amount'] ?? '0.00',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      orderItems: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((i) => OrderItem.fromJson(i))
              .toList()
          : [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final String price;
  final String total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0.00',
      total: json['total'] ?? '0.00',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Product {
  final int id;
  final int? warehouseId;
  final int? categoryId;
  final int? subCategoryId;
  final int? brandId;
  final String name;
  final int? expiryDays;
  final String? sku;
  final String? description;
  final String basePrice;
  final String retailerPrice;
  final String mrp;
  final String? discountType;
  final String discountValue;
  final int? taxId;
  final String gstPercentage;
  final int stock;
  final List<String> productImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    this.warehouseId,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    required this.name,
    this.expiryDays,
    this.sku,
    this.description,
    required this.basePrice,
    required this.retailerPrice,
    required this.mrp,
    this.discountType,
    required this.discountValue,
    this.taxId,
    required this.gstPercentage,
    required this.stock,
    required this.productImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['product_images'] != null) {
      try {
        images = List<String>.from(jsonDecode(json['product_images']));
      } catch (e) {
        images = [];
      }
    }

    return Product(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      brandId: json['brand_id'],
      name: json['name'] ?? '',
      expiryDays: json['expiry_days'],
      sku: json['sku'],
      description: json['description'],
      basePrice: json['base_price'] ?? '0.00',
      retailerPrice: json['retailer_price'] ?? '0.00',
      mrp: json['mrp'] ?? '0.00',
      discountType: json['discount_type'],
      discountValue: json['discount_value'] ?? '0.00',
      taxId: json['tax_id'],
      gstPercentage: json['gst_percentage'] ?? '0.00',
      stock: json['stock'] ?? 0,
      productImages: images,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
