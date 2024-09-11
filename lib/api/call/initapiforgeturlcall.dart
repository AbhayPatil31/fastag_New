// To parse this JSON data, do
//
//     final completefasttagrequestcall = completefasttagrequestcallFromJson(jsonString);

import 'dart:convert';

initapiforgeturlcall initapiforgeturlcallFromJson(String str) =>
    initapiforgeturlcall.fromJson(json.decode(str));

String completefasttagrequestcallToJson(initapiforgeturlcall data) =>
    json.encode(data.toJson());

class initapiforgeturlcall {
  String? agentId;
  String? amount;

  initapiforgeturlcall({
    this.agentId,
    this.amount,
  });

  factory initapiforgeturlcall.fromJson(Map<String, dynamic> json) =>
      initapiforgeturlcall(
        agentId: json["agent_id"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
        "amount": amount,
      };
}
