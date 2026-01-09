import 'dart:convert';
import 'dart:developer';

/// =======================
/// Order Response Model
/// =======================
class OrderResponse {
  final bool status;
  final List<Order> data;
  final int? currentPage;
  final int? lastPage;
  final int? total;

  OrderResponse({
    required this.status,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<Order> orders = [];
    int? current;
    int? last;
    int? totalCount;

    if (rawData is List) {
      orders = rawData.map((e) => Order.fromJson(e)).toList();
    } else if (rawData is Map) {
      // Handle pagination object
      if (rawData['data'] is List) {
        orders =
            (rawData['data'] as List).map((e) => Order.fromJson(e)).toList();
      } else if (rawData['orders'] is List) {
        orders =
            (rawData['orders'] as List).map((e) => Order.fromJson(e)).toList();
      }

      // Parse pagination meta if available
      current = rawData['current_page'];
      last = rawData['last_page'];
      totalCount = rawData['total'];
    }

    return OrderResponse(
      status: json['status'] == true || json['status'] == 'success',
      data: orders,
      currentPage: current,
      lastPage: last,
      total: totalCount,
    );
  }
}

/// =======================
/// Customer Model
/// =======================
class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? profilePhoto;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.profilePhoto,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      profilePhoto: json['profile_photo'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

/// =======================
/// Order Model
/// =======================
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
  final DeliveryAddress? deliveryAddress;
  final Customer? user;

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
    this.deliveryAddress,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      offerId: json['offer_id'],
      couponCode: json['coupon_code'],
      orderNumber: json['order_number'] ?? '',
      subtotal: json['subtotal']?.toString() ?? '0.00',
      deliveryCharge: json['delivery_charge']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      couponDiscount: json['coupon_discount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      orderItems: json['order_items'] is List
          ? (json['order_items'] as List)
              .map((e) => OrderItem.fromJson(e))
              .toList()
          : [],
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(json['delivery_address'])
          : null,
      user: json['user'] != null ? Customer.fromJson(json['user']) : null,
    );
  }
}

class DeliveryAddress {
  final int id;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postcode;

  DeliveryAddress({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postcode,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] ?? 0,
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postcode: json['postcode'] ?? '',
    );
  }
}

/// =======================
/// Order Item Model
/// =======================
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
      price: json['price']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      product:
          json['product'] is Map ? Product.fromJson(json['product']) : null,
    );
  }
}

/// =======================
/// Product Model
/// =======================
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

    if (json['product_images'] is String) {
      try {
        log('Raw product_images string: ${json['product_images']}'); // Debug log
        final decoded = jsonDecode(json['product_images']);
        log('Decoded product_images: $decoded (${decoded.runtimeType})'); // Debug log
        if (decoded is List) {
          images = List<String>.from(decoded);
        }
      } catch (e) {
        log('Error parsing product_images string: $e');
        images = [];
      }
    } else if (json['product_images'] is List) {
      log('Raw product_images list: ${json['product_images']}'); // Debug log
      try {
        images = List<String>.from(json['product_images']);
      } catch (e) {
        log('Error parsing product_images list: $e');
        images = [];
      }
    } else {
      log('product_images is ${json['product_images']?.runtimeType}');
    }

    log('Final parsed images: $images'); // Debug log

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
      basePrice: json['base_price']?.toString() ?? '0.00',
      retailerPrice: json['retailer_price']?.toString() ?? '0.00',
      mrp: json['mrp']?.toString() ?? '0.00',
      discountType: json['discount_type'],
      discountValue: json['discount_value']?.toString() ?? '0.00',
      taxId: json['tax_id'],
      gstPercentage: json['gst_percentage']?.toString() ?? '0.00',
      stock: json['stock'] ?? 0,
      productImages: images,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

/// =======================
/// Date Parser (Shared)
/// =======================
DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}
