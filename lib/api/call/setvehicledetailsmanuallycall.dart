// To parse this JSON data, do
//
//     final setvehicledetailsmanuallycall = setvehicledetailsmanuallycallFromJson(jsonString);

import 'dart:convert';

Setvehicledetailsmanuallycall setvehicledetailsmanuallycallFromJson(
        String str) =>
    Setvehicledetailsmanuallycall.fromJson(json.decode(str));

String setvehicledetailsmanuallycallToJson(
        Setvehicledetailsmanuallycall data) =>
    json.encode(data.toJson());

class Setvehicledetailsmanuallycall {
  String? vehicleManuf;
  String? model;
  String? vehicleColour;
  String? npcIstatus;
  String? type;
  String? vehicleType;
  String? npciVehicleClassId;
  String? tagVehicleClassId;
  String? agentId;
  String? vehicleNumber;
  String? vehicleDescriptor;
  String? isNationalPermit;
  String? permitExpiryDate;
  String? stateOfRegistration;
  Setvehicledetailsmanuallycall({
    this.vehicleManuf,
    this.model,
    this.vehicleColour,
    this.npcIstatus,
    this.type,
    this.vehicleType,
    this.npciVehicleClassId,
    this.tagVehicleClassId,
    this.agentId,
    this.vehicleNumber,
    this.vehicleDescriptor,
    this.isNationalPermit,
    this.permitExpiryDate,
    this.stateOfRegistration,
  });

  factory Setvehicledetailsmanuallycall.fromJson(Map<String, dynamic> json) =>
      Setvehicledetailsmanuallycall(
        vehicleManuf: json["vehicleManuf"],
        model: json["model"],
        vehicleColour: json["vehicleColour"],
        npcIstatus: json["NPCIstatus"],
        type: json["type"],
        vehicleType: json["vehicleType"],
        npciVehicleClassId: json["npciVehicleClassID"],
        tagVehicleClassId: json["tagVehicleClassID"],
        agentId: json["agent_id"],
        vehicleNumber: json["vehicle_number"],
        vehicleDescriptor: json["vehicleDescriptor"],
        isNationalPermit: json["isNationalPermit"],
        permitExpiryDate: json["permitExpiryDate"],
        stateOfRegistration: json["stateOfRegistration"],
      );

  Map<String, dynamic> toJson() => {
        "vehicleManuf": vehicleManuf,
        "model": model,
        "vehicleColour": vehicleColour,
        "NPCIstatus": npcIstatus,
        "type": type,
        "vehicleType": vehicleType,
        "npciVehicleClassID": npciVehicleClassId,
        "tagVehicleClassID": tagVehicleClassId,
        "agent_id": agentId,
        "vehicle_number": vehicleNumber,
        "vehicleDescriptor": vehicleDescriptor,
        "isNationalPermit": isNationalPermit,
        "permitExpiryDate": permitExpiryDate,
        "stateOfRegistration": stateOfRegistration
      };
}
