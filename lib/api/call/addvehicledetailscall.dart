// To parse this JSON data, do
//
//     final addvehicledetailscall = addvehicledetailscallFromJson(jsonString);

import 'dart:convert';

Addvehicledetailscall addvehicledetailscallFromJson(String str) =>
    Addvehicledetailscall.fromJson(json.decode(str));

String addvehicledetailscallToJson(Addvehicledetailscall data) =>
    json.encode(data.toJson());

class Addvehicledetailscall {
  String? sessionId;
  String? vehicleNumber;

  String? chassisNo;
  String? serialNo;
 
  String? agentId;

  Addvehicledetailscall({
    this.sessionId,
    this.vehicleNumber,
    this.chassisNo,
    this.serialNo,
  
    this.agentId,
  });

  factory Addvehicledetailscall.fromJson(Map<String, dynamic> json) =>
      Addvehicledetailscall(
        sessionId: json["sessionId"],
        vehicleNumber: json["vehicle_number"],
        // vehicleCategory: json["vehicleCategory"],
        chassisNo: json["chassisNo"],
        serialNo: json["serialNo"],
      
        agentId: json["agent_id"],
      );

  Map<String, dynamic> toJson() => {
        "sessionId": sessionId,
        "vehicle_number": vehicleNumber,
        // "vehicleCategory": vehicleCategory,
        "chassisNo": chassisNo,
        "serialNo": serialNo,
      
        "agent_id": agentId,
      };
}
