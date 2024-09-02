// To parse this JSON data, do
//
//     final gettagforunallocatecall = gettagforunallocatecallFromJson(jsonString);

import 'dart:convert';

Gettagforunallocatecall gettagforunallocatecallFromJson(String str) =>
    Gettagforunallocatecall.fromJson(json.decode(str));

String gettagforunallocatecallToJson(Gettagforunallocatecall data) =>
    json.encode(data.toJson());

class Gettagforunallocatecall {
  String? agentId;

  Gettagforunallocatecall({
    this.agentId,
  });

  factory Gettagforunallocatecall.fromJson(Map<String, dynamic> json) =>
      Gettagforunallocatecall(
        agentId: json["agent_id"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
      };
}
