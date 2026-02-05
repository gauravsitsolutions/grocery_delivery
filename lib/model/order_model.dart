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
    var rawData = json['data'];
    List<Order> orders = [];
    int? current;
    int? last;
    int? totalCount;

    // Check if 'data' is null but 'orders' exists at root level
    if (rawData == null && json['orders'] != null) {
      rawData = json['orders'];
    }

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
    String first = json['first_name'] ?? '';
    String last = json['last_name'] ?? '';

    // Fallback for simple 'name' field
    if (first.isEmpty && last.isEmpty && json['name'] != null) {
      final parts = (json['name'] as String).trim().split(' ');
      if (parts.isNotEmpty) {
        first = parts.first;
        if (parts.length > 1) {
          last = parts.sublist(1).join(' ');
        }
      }
    }

    return Customer(
      id: json['id'] ?? 0,
      firstName: first,
      lastName: last,
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
  final Vendor? vendor;
  final String? distance;

  final int? deliveryAgentId;
  final int? warehouseId;
  final int? createdBy;
  final String? channel;
  final String? paymentMethod;
  final String? customerRating;
  final String? customerRatingTags;
  final String? paymentStatus;
  final String? orderType;
  final String? pickupProof;
  final String? cancelReason;
  final String? cancelComment;
  final String? deliveryInstructions;
  final DateTime? cancelledAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.userId,
    this.deliveryAgentId,
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
    this.vendor,
    this.warehouseId,
    this.createdBy,
    this.channel,
    this.paymentMethod,
    this.customerRating,
    this.customerRatingTags,
    this.paymentStatus,
    this.orderType,
    this.pickupProof,
    this.cancelReason,
    this.cancelComment,
    this.cancelledAt,
    this.deliveredAt,
    this.distance,
    this.deliveryInstructions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? json['orderId'] ?? json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      deliveryAgentId: json['delivery_agent_id'],
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
          : json['deliveryAddress'] != null
              ? DeliveryAddress.fromJson(json['deliveryAddress'])
              : json['customer_address'] != null
                  ? DeliveryAddress.fromJson(json['customer_address'])
                  : null,
      user: json['user'] != null
          ? Customer.fromJson(json['user'])
          : json['customer'] != null
              ? Customer.fromJson(json['customer'])
              : null,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      warehouseId: json['warehouse_id'],
      createdBy: json['created_by'],
      channel: json['channel'],
      paymentMethod: json['payment_method'],
      customerRating: json['customer_rating']?.toString(),
      customerRatingTags: json['customer_rating_tags']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      orderType: json['order_type']?.toString() ?? 'delivery',
      pickupProof: json['pickup_proof'],
      cancelReason: json['cancel_reason'],
      cancelComment: json['cancel_comment'],
      deliveryInstructions:
          json['delivery_instructions'] ?? json['instructions'],
      cancelledAt: _parseDate(json['cancelled_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      distance: json['distance']?.toString(),
    );
  }

  Order copyWith({
    int? id,
    int? userId,
    int? deliveryAgentId,
    int? offerId,
    String? couponCode,
    String? orderNumber,
    String? subtotal,
    String? deliveryCharge,
    String? discount,
    String? couponDiscount,
    String? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? orderItems,
    DeliveryAddress? deliveryAddress,
    Customer? user,
    Vendor? vendor,
    int? warehouseId,
    int? createdBy,
    String? channel,
    String? paymentMethod,
    String? customerRating,
    String? customerRatingTags,
    String? paymentStatus,
    String? orderType,
    String? pickupProof,
    String? cancelReason,
    String? cancelComment,
    DateTime? cancelledAt,
    DateTime? deliveredAt,
    String? distance,
    String? deliveryInstructions,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deliveryAgentId: deliveryAgentId ?? this.deliveryAgentId,
      offerId: offerId ?? this.offerId,
      couponCode: couponCode ?? this.couponCode,
      orderNumber: orderNumber ?? this.orderNumber,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      discount: discount ?? this.discount,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderItems: orderItems ?? this.orderItems,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      user: user ?? this.user,
      vendor: vendor ?? this.vendor,
      warehouseId: warehouseId ?? this.warehouseId,
      createdBy: createdBy ?? this.createdBy,
      channel: channel ?? this.channel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerRating: customerRating ?? this.customerRating,
      customerRatingTags: customerRatingTags ?? this.customerRatingTags,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderType: orderType ?? this.orderType,
      pickupProof: pickupProof ?? this.pickupProof,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelComment: cancelComment ?? this.cancelComment,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      distance: distance ?? this.distance,
    );
  }
}

class DeliveryAddress {
  final int id;
  final String? name; // Added name
  final String? phone; // Added phone
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postcode;
  final String? latitude;
  final String? longitude;

  DeliveryAddress({
    required this.id,
    this.name,
    this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postcode,
    this.latitude,
    this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['address_line_1'] ?? json['address'] ?? '',
      addressLine2: json['address_line_2'] ?? json['area'] ?? json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postcode: json['postcode'] ?? json['pincode'] ?? '',
      latitude: json['latitude']?.toString() ?? json['lat']?.toString(),
      longitude: json['longitude']?.toString() ?? json['lng']?.toString(),
    );
  }
}

/// =======================
/// Vendor Model
/// =======================
class Vendor {
  final int id;
  final String storeName;
  final String? address;
  final String? mobile;

  Vendor({
    required this.id,
    required this.storeName,
    this.address,
    this.mobile,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      storeName: json['store_name'] ?? '',
      address: json['address'],
      mobile: json['mobile'],
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
  final int? productBatchId;
  final bool isPicked;
  final String? price;
  final String? taxPercent;
  final String? taxAmount;
  final String? lineTotal;
  final String total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.productBatchId,
    this.isPicked = false,
    this.price,
    this.taxPercent,
    this.taxAmount,
    this.lineTotal,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // If name/image are at root, create a fallback product
    Product? fallbackProduct;
    if (json['name'] != null) {
      fallbackProduct = Product(
        id: json['product_id'] ?? 0,
        name: json['name'],
        basePrice: '0.00',
        retailerPrice: '0.00',
        mrp: '0.00',
        gstPercentage: '0.00',
        stock: 0,
        productImages:
            json['image'] != null ? [json['image'].toString()] : const [],
        productImageUrls: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity:
          json['quantity'] != null && (json['quantity'] as num).toInt() > 0
              ? (json['quantity'] as num).toInt()
              : 1, // Default to 1 if null or 0
      productBatchId: json['product_batch_id'],
      isPicked: json['isPicked'] == true ||
          json['is_picked'] == true ||
          json['is_picked'] == 1,
      price: json['price']?.toString() ?? '0.00',
      taxPercent: json['tax_percent']?.toString(),
      taxAmount: json['tax_amount']?.toString(),
      lineTotal: json['line_total']?.toString(),
      total: json['total']?.toString() ?? '0.00',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      product: json['product'] is Map
          ? Product.fromJson(json['product'])
          : fallbackProduct,
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
  final int? unitId;
  final String? unitValue;
  final String? sku;
  final String? description;
  final String basePrice;
  final String retailerPrice;
  final String mrp;
  final String? discountType;
  final String? discountValue;
  final int? taxId;
  final String gstPercentage;
  final String? gstAmount;
  final String? finalPrice;
  final int stock;
  final List<String> productImages;
  final List<String> productImageUrls; // New field for full URLs
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    this.warehouseId,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    required this.name,
    this.unitId,
    this.unitValue,
    this.sku,
    this.description,
    required this.basePrice,
    required this.retailerPrice,
    required this.mrp,
    this.discountType,
    this.discountValue,
    this.taxId,
    required this.gstPercentage,
    this.gstAmount,
    this.finalPrice,
    required this.stock,
    required this.productImages,
    this.productImageUrls = const [], // Default empty
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    List<String> imageUrls = [];

    // Parse product_images (filenames)
    if (json['product_images'] is String) {
      try {
        log('Raw product_images string: ${json['product_images']}');
        final decoded = jsonDecode(json['product_images']);
        if (decoded is List) {
          images = List<String>.from(decoded);
        }
      } catch (e) {
        log('Error parsing product_images string: $e');
        images = [];
      }
    } else if (json['product_images'] is List) {
      try {
        images = List<String>.from(json['product_images']);
      } catch (e) {
        log('Error parsing product_images list: $e');
        images = [];
      }
    }

    // Parse product_image_urls (full URLs)
    if (json['product_image_urls'] is List) {
      try {
        imageUrls = List<String>.from(json['product_image_urls']);
        log('Parsed product_image_urls: $imageUrls');
      } catch (e) {
        log('Error parsing product_image_urls: $e');
      }
    }

    return Product(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      brandId: json['brand_id'],
      name: json['name'] ?? '',
      unitId: json['unit_id'],
      unitValue: json['unit_value']?.toString(),
      sku: json['sku'],
      description: json['description'],
      basePrice: json['base_price']?.toString() ?? '0.00',
      retailerPrice: json['retailer_price']?.toString() ?? '0.00',
      mrp: json['mrp']?.toString() ?? '0.00',
      discountType: json['discount_type'],
      discountValue: json['discount_value']?.toString(),
      taxId: json['tax_id'],
      gstPercentage: json['gst_percentage']?.toString() ?? '0.00',
      gstAmount: json['gst_amount']?.toString(),
      finalPrice: json['final_price']?.toString(),
      stock: json['stock'] ?? 0,
      productImages: images,
      productImageUrls: imageUrls,
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
