import 'dart:convert';

class DeviceInfo {
  final int? deviceId;
  final String version;
  final String deviceName;
  final String manufacturerName;
  final String productName;
  final int? productId;
  final int? vendorId;
  final String serialNumber;

  DeviceInfo({
    this.deviceId = 0,
    this.version = '',
    this.deviceName = '',
    this.manufacturerName = '',
    this.productName = '',
    this.productId = 0,
    this.vendorId = 0,
    this.serialNumber = '',
  });

  DeviceInfo copyWith({
    int? deviceId,
    String? version,
    String? deviceName,
    String? manufacturerName,
    String? productName,
    int? productId,
    int? vendorId,
    String? serialNumber,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      deviceName: deviceName ?? this.deviceName,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      productName: productName ?? this.productName,
      productId: productId ?? this.productId,
      vendorId: vendorId ?? this.vendorId,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'version': version,
      'deviceName': deviceName,
      'manufacturerName': manufacturerName,
      'productName': productName,
      'productId': productId,
      'vendorId': vendorId,
      'serialNumber': serialNumber,
    };
  }

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceId: map['deviceId'] != 'null' ? int.parse(map['deviceId']) : null,
      version: map['version'] != 'null' ? map['version'] ?? '' : '',
      deviceName: map['deviceName'] != 'null' ? map['deviceName'] ?? '' : '',
      manufacturerName: map['manufacturerName'] != 'null'
          ? map['manufacturerName'] ?? ''
          : '',
      productName: map['productName'] != 'null' ? map['productName'] ?? '' : '',
      productId:
          map['productId'] != 'null' ? int.parse(map['productId']) : null,
      vendorId: map['vendorId'] != 'null' ? int.parse(map['vendorId']) : null,
      serialNumber:
          map['serialNumber'] != 'null' ? map['serialNumber'] ?? '' : '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceInfo.fromJson(String source) =>
      DeviceInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, version: $version, deviceName: $deviceName, manufacturerName: $manufacturerName, productName: $productName, productId: $productId, vendorId: $vendorId, serialNumber: $serialNumber)';
  }
}
