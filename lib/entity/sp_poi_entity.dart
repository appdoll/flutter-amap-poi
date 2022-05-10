import 'dart:convert';
import 'package:flutter_amap_poi/generated/json/base/json_field.dart';
import 'package:flutter_amap_poi/generated/json/sp_poi_entity.g.dart';

@JsonSerializable()
class SpPoiEntity {

  String? city;
  String? province;
  String? name;
  String? address;
  String? district;
  SpLocation? location;

  
  SpPoiEntity();

  factory SpPoiEntity.fromJson(Map<String, dynamic> json) => $SpPoiEntityFromJson(json);

  Map<String, dynamic> toJson() => $SpPoiEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SpLocation{
  double? longitude;
  double? latitude;
  SpLocation();
  factory SpLocation.fromJson(Map<String, dynamic> json) => $SpLocationFromJson(json);

  Map<String, dynamic> toJson() => $SpLocationToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}