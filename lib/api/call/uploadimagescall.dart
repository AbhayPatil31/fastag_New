// To parse this JSON data, do
//
//     final uploadimagescall = uploadimagescallFromJson(jsonString);

import 'dart:convert';

Uploadimagescall uploadimagescallFromJson(String str) =>
    Uploadimagescall.fromJson(json.decode(str));

String uploadimagescallToJson(Uploadimagescall data) =>
    json.encode(data.toJson());

class Uploadimagescall {
  String? agentId;
  String? sessionId;
  String? imageType;
  String? image;

  Uploadimagescall({
    this.agentId,
    this.sessionId,
    this.imageType,
    this.image,
  });

  factory Uploadimagescall.fromJson(Map<String, dynamic> json) =>
      Uploadimagescall(
        agentId: json["agent_id"],
        sessionId: json["sessionId"],
        imageType: json["imageType"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId,
        "sessionId": sessionId,
        "imageType": imageType,
        "image": image,
      };
}
