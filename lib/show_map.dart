import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_poi/const_config.dart';
import 'package:flutter_amap_poi/entity/sp_poi_entity.dart';
import 'package:permission_handler/permission_handler.dart';


class PoiSearchPage extends StatefulWidget {
  const PoiSearchPage({Key? key}) : super(key: key);

  @override
  _PoiSearchPageState createState() => _PoiSearchPageState();
}

class _PoiSearchPageState extends State<PoiSearchPage> {
  late Map<String, Object> _locationResult;
  List<SpPoiEntity>? poiList;
  StreamSubscription<Map<String, Object>>? _locationListener;

  AMapFlutterLocation _locationPlugin = new AMapFlutterLocation();
  String? cityName;
  final Map<String, Marker> _markers = <String, Marker>{};
  int selectedIndex = -1;
  @override
  void initState() {
    super.initState();
    initAmap();
  }

  void initAmap() {
    AMapFlutterLocation.setApiKey(
        "614764b021e02bdaecf41e647f770587", "614764b021e02bdaecf41e647f770587");
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 动态申请定位权限
    requestPermission();

    ///iOS 获取native精度类型
    if (Platform.isIOS) {
      requestAccuracyAuthorization();
    }

    ///注册定位结果监听
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      setState(() {
        _locationResult = result;
        print("定位结果回调");
        print("city:${result["city"]}, address:${result["address"]}");
        print("定位111");
        cityName = "${result["city"]}";
        double latitude = double.parse(result["latitude"] as String);
        double longitude = double.parse(result["longitude"] as String);
        LatLng latlng = LatLng(latitude, longitude);
        if (_mapController != null) {
          _mapController.moveCamera(CameraUpdate.newLatLng(latlng));
          _stopLocation();
        }
      });
    });
    _startLocation();
  }

  @override
  void dispose() {
    _inpuFocus.dispose();
    _inpuController.dispose();
    super.dispose();

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener?.cancel();
    }

    ///销毁定位
    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }
  }

  ///设置定位参数
  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = new AMapLocationOption();

      ///是否单次定位
      locationOption.onceLocation = false;

      ///是否需要返回逆地理信息
      locationOption.needAddress = true;

      ///逆地理信息的语言类型
      locationOption.geoLanguage = GeoLanguage.DEFAULT;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///设置Android端连续定位的定位间隔
      locationOption.locationInterval = 2000;

      ///设置Android端的定位模式<br>
      ///可选值：<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///设置iOS端的定位最小更新距离<br>
      locationOption.distanceFilter = -1;

      ///设置iOS端期望的定位精度
      /// 可选值：<br>
      /// <li>[DesiredAccuracy.Best] 最高精度</li>
      /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
      locationOption.desiredAccuracy = DesiredAccuracy.Best;

      ///设置iOS端是否允许系统暂停定位
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///将定位参数设置给定位插件
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  ///开始定位
  void _startLocation() {
    if (null != _locationPlugin) {
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  ///停止定位
  void _stopLocation() {
    if (null != _locationPlugin) {
      _locationPlugin.stopLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AMapWidget map = AMapWidget(
      privacyStatement: ConstConfig.amapPrivacyStatement,
      apiKey: ConstConfig.amapApiKeys,
      markers: Set<Marker>.of(_markers.values),
      onMapCreated: onMapCreated,
      onPoiSearchDone: onPoiSearchDone,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        title: Text("选取地址"),
      ),
      body: Column(
        children: <Widget>[
          _buildSearchField(),
          Expanded(
            flex: 1,
            child: map,
          ),
          poiList == null
              ? Container()
              : Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 3,
                  child:
//            _list.isEmpty ?
//              Container(
//                alignment: Alignment.center,
//                child: CircularProgressIndicator(),
//              ) :
                      Column(
                    children: [
                      Container(
                        child: Text("选择地址"),
                        alignment: AlignmentDirectional.center,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        color: Color(0xFFfefefe),
                        width: double.infinity,
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: poiList?.length ?? 0,
                          separatorBuilder: (_, index) => const Divider(),
                          itemBuilder: (_, index) {
                            SpPoiEntity? poi = poiList?[index];
                            return _AddressItem(
                              poi: poi,
                              isSelected: selectedIndex == index,
                              onTap: () {
                                selectedIndex = index;
                                if (poi != null) {
                                  _addMarker(poi);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

        ],
      ),
    );
  }

  final TextEditingController _inpuController = TextEditingController();
  final FocusNode _inpuFocus = FocusNode();
  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                focusNode: _inpuFocus,
                controller: _inpuController,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "输入关键字",
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Color(0xFFFAFAFA),
                )),
          ),
          SizedBox(height: 8,),
          SizedBox(
            width: 80,
            height: 35,
            child: TextButton(
              onPressed: (){
                String keyword=_inpuController.text;
                searchPoi(keyword);
              }, child: Text("搜索"),
            ),
          )

        ],
      ),
    );
  }

  late AMapController _mapController;
  void onMapCreated(AMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void onPoiSearchDone(dynamic result) {
    // List<SpPoi>? poiList  = jsonConvert.convertListNotNull<SpPoi>(result);
    Iterable l = json.decode(result);
    List<SpPoiEntity>? list = List<SpPoiEntity>.from(l.map((json) => SpPoiEntity.fromJson(json)));
    print(poiList);
    setState(() {
      poiList = list;
    });
  }

  void searchPoi(String keyword) {
    if (keyword.isEmpty) {
      return;
    }
    _mapController
        .searchPOI(keyword: keyword, city: cityName ?? "杭州")
        .then((value) {
      print("xxxxxxxxx=" + value);
    });
  }

  void _addMarker(SpPoiEntity poi) {
    SpLocation latlng = poi.location!;
    final _markerPosition = LatLng(latlng.latitude!, latlng.longitude!);
    final Marker marker = Marker(
      position: _markerPosition,
      infoWindow: InfoWindow(title: poi.name, snippet: poi.address),
      //使用默认hue的方式设置Marker的图标
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    //调用setState触发AMapWidget的更新，从而完成marker的添加
    setState(() {
      //将新的marker添加到map里
      _markers.clear();
      _markers[marker.id] = marker;
      // _mapController.moveCamera(CameraUpdate.newLatLng(_markerPosition));
      _mapController.moveCamera(CameraUpdate.newLatLngZoom(_markerPosition, 12));
    });
  }

  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.locationWhenInUse.status;
    print(status);
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.locationWhenInUse.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  ///获取iOS native的accuracyAuthorization类型
  void requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
        await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }
}

class _AddressItem extends StatelessWidget {
  _AddressItem({
    Key? key,
    // required this.date,
    this.isSelected = false,
    this.onTap,
    this.poi,
  }) : super(key: key);
  SpPoiEntity? poi;
  // final PoiSearch date;
  final bool isSelected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Color(0xffF7F9FF),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${poi?.name}",
              style: TextStyle(fontSize: 16, color: Color(0xff333333)),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "${poi?.address}",
                    style: TextStyle(fontSize: 14, color: Color(0xff666666)),
                  ),
                ),
                Visibility(
                  visible: isSelected,
                  child: const Icon(Icons.done, color: Colors.blue),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
