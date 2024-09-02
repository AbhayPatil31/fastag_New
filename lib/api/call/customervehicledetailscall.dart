// To parse this JSON data, do
//
//     final customervehicledetailscall = customervehicledetailscallFromJson(jsonString);

import 'dart:convert';

Customervehicledetailscall customervehicledetailscallFromJson(String str) =>
    Customervehicledetailscall.fromJson(json.decode(str));

String customervehicledetailscallToJson(Customervehicledetailscall data) =>
    json.encode(data.toJson());

class Customervehicledetailscall {
  String? vehicleNumber;

  Customervehicledetailscall({
    this.vehicleNumber,
  });

  factory Customervehicledetailscall.fromJson(Map<String, dynamic> json) =>
      Customervehicledetailscall(
        vehicleNumber: json["vehicle_number"],
      );

  Map<String, dynamic> toJson() => {
        "vehicle_number": vehicleNumber,
      };
}
