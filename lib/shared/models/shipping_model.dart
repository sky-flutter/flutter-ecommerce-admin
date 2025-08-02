import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingZone {
  final String id;
  final String name;
  final List<String> countries;
  final List<String> states;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingZone({
    required this.id,
    required this.name,
    required this.countries,
    required this.states,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingZone.fromMap(Map<String, dynamic> map, String id) {
    return ShippingZone(
      id: id,
      name: map['name'] ?? '',
      countries: List<String>.from(map['countries'] ?? []),
      states: List<String>.from(map['states'] ?? []),
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'countries': countries,
      'states': states,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ShippingMethod {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isActive;
  final String? zoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isActive,
    this.zoneId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingMethod.fromMap(Map<String, dynamic> map, String id) {
    return ShippingMethod(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      isActive: map['isActive'] ?? false,
      zoneId: map['zoneId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'isActive': isActive,
      'zoneId': zoneId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class DeliverySettings {
  final bool enableFreeShipping;
  final double freeShippingThreshold;
  final bool enableLocalPickup;
  final bool enableSameDayDelivery;
  final double sameDayDeliveryFee;
  final String sameDayCutoffTime;
  final DateTime updatedAt;

  DeliverySettings({
    required this.enableFreeShipping,
    required this.freeShippingThreshold,
    required this.enableLocalPickup,
    required this.enableSameDayDelivery,
    required this.sameDayDeliveryFee,
    required this.sameDayCutoffTime,
    required this.updatedAt,
  });

  factory DeliverySettings.fromMap(Map<String, dynamic> map) {
    return DeliverySettings(
      enableFreeShipping: map['enableFreeShipping'] ?? false,
      freeShippingThreshold: (map['freeShippingThreshold'] as num).toDouble(),
      enableLocalPickup: map['enableLocalPickup'] ?? false,
      enableSameDayDelivery: map['enableSameDayDelivery'] ?? false,
      sameDayDeliveryFee: (map['sameDayDeliveryFee'] as num).toDouble(),
      sameDayCutoffTime: map['sameDayCutoffTime'] ?? '14:00',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableFreeShipping': enableFreeShipping,
      'freeShippingThreshold': freeShippingThreshold,
      'enableLocalPickup': enableLocalPickup,
      'enableSameDayDelivery': enableSameDayDelivery,
      'sameDayDeliveryFee': sameDayDeliveryFee,
      'sameDayCutoffTime': sameDayCutoffTime,
      'updatedAt': updatedAt,
    };
  }
}

class PackageSettings {
  final double defaultPackageWeight;
  final String defaultPackageUnit;
  final double maxPackageWeight;
  final String maxPackageUnit;
  final double defaultPackageLength;
  final double defaultPackageWidth;
  final double defaultPackageHeight;
  final String defaultPackageDimensionUnit;
  final DateTime updatedAt;

  PackageSettings({
    required this.defaultPackageWeight,
    required this.defaultPackageUnit,
    required this.maxPackageWeight,
    required this.maxPackageUnit,
    required this.defaultPackageLength,
    required this.defaultPackageWidth,
    required this.defaultPackageHeight,
    required this.defaultPackageDimensionUnit,
    required this.updatedAt,
  });

  factory PackageSettings.fromMap(Map<String, dynamic> map) {
    return PackageSettings(
      defaultPackageWeight: (map['defaultPackageWeight'] as num).toDouble(),
      defaultPackageUnit: map['defaultPackageUnit'] ?? 'lbs',
      maxPackageWeight: (map['maxPackageWeight'] as num).toDouble(),
      maxPackageUnit: map['maxPackageUnit'] ?? 'lbs',
      defaultPackageLength: (map['defaultPackageLength'] as num).toDouble(),
      defaultPackageWidth: (map['defaultPackageWidth'] as num).toDouble(),
      defaultPackageHeight: (map['defaultPackageHeight'] as num).toDouble(),
      defaultPackageDimensionUnit: map['defaultPackageDimensionUnit'] ?? 'in',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultPackageWeight': defaultPackageWeight,
      'defaultPackageUnit': defaultPackageUnit,
      'maxPackageWeight': maxPackageWeight,
      'maxPackageUnit': maxPackageUnit,
      'defaultPackageLength': defaultPackageLength,
      'defaultPackageWidth': defaultPackageWidth,
      'defaultPackageHeight': defaultPackageHeight,
      'defaultPackageDimensionUnit': defaultPackageDimensionUnit,
      'updatedAt': updatedAt,
    };
  }
}

class DeliveryTime {
  final String id;
  final String methodName;
  final String estimatedTime;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryTime({
    required this.id,
    required this.methodName,
    required this.estimatedTime,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryTime.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryTime(
      id: id,
      methodName: map['methodName'] ?? '',
      estimatedTime: map['estimatedTime'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'methodName': methodName,
      'estimatedTime': estimatedTime,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ShippingSettings {
  final DeliverySettings deliverySettings;
  final PackageSettings packageSettings;
  final List<ShippingZone> zones;
  final List<ShippingMethod> methods;
  final List<DeliveryTime> deliveryTimes;
  final DateTime updatedAt;

  ShippingSettings({
    required this.deliverySettings,
    required this.packageSettings,
    required this.zones,
    required this.methods,
    required this.deliveryTimes,
    required this.updatedAt,
  });

  factory ShippingSettings.fromMap(Map<String, dynamic> map) {
    return ShippingSettings(
      deliverySettings: DeliverySettings.fromMap(map['deliverySettings'] ?? {}),
      packageSettings: PackageSettings.fromMap(map['packageSettings'] ?? {}),
      zones: (map['zones'] as List<dynamic>? ?? [])
          .map((zone) => ShippingZone.fromMap(zone, zone['id'] ?? ''))
          .toList(),
      methods: (map['methods'] as List<dynamic>? ?? [])
          .map((method) => ShippingMethod.fromMap(method, method['id'] ?? ''))
          .toList(),
      deliveryTimes: (map['deliveryTimes'] as List<dynamic>? ?? [])
          .map((time) => DeliveryTime.fromMap(time, time['id'] ?? ''))
          .toList(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deliverySettings': deliverySettings.toMap(),
      'packageSettings': packageSettings.toMap(),
      'zones': zones.map((zone) => zone.toMap()).toList(),
      'methods': methods.map((method) => method.toMap()).toList(),
      'deliveryTimes': deliveryTimes.map((time) => time.toMap()).toList(),
      'updatedAt': updatedAt,
    };
  }
}
