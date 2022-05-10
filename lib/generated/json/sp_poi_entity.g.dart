import 'package:flutter_amap_poi/generated/json/base/json_convert_content.dart';
import 'package:flutter_amap_poi/entity/sp_poi_entity.dart';

SpPoiEntity $SpPoiEntityFromJson(Map<String, dynamic> json) {
	final SpPoiEntity spPoiEntity = SpPoiEntity();
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		spPoiEntity.city = city;
	}
	final String? province = jsonConvert.convert<String>(json['province']);
	if (province != null) {
		spPoiEntity.province = province;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		spPoiEntity.name = name;
	}
	final String? address = jsonConvert.convert<String>(json['address']);
	if (address != null) {
		spPoiEntity.address = address;
	}
	final String? district = jsonConvert.convert<String>(json['district']);
	if (district != null) {
		spPoiEntity.district = district;
	}
	final SpLocation? location = jsonConvert.convert<SpLocation>(json['location']);
	if (location != null) {
		spPoiEntity.location = location;
	}
	return spPoiEntity;
}

Map<String, dynamic> $SpPoiEntityToJson(SpPoiEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['city'] = entity.city;
	data['province'] = entity.province;
	data['name'] = entity.name;
	data['address'] = entity.address;
	data['district'] = entity.district;
	data['location'] = entity.location?.toJson();
	return data;
}

SpLocation $SpLocationFromJson(Map<String, dynamic> json) {
	final SpLocation spLocation = SpLocation();
	final double? longitude = jsonConvert.convert<double>(json['longitude']);
	if (longitude != null) {
		spLocation.longitude = longitude;
	}
	final double? latitude = jsonConvert.convert<double>(json['latitude']);
	if (latitude != null) {
		spLocation.latitude = latitude;
	}
	return spLocation;
}

Map<String, dynamic> $SpLocationToJson(SpLocation entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['longitude'] = entity.longitude;
	data['latitude'] = entity.latitude;
	return data;
}