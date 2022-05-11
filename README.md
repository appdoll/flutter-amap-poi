# flutter-amap-poi
在高德官方flutter插件基础上扩展,实现根据关键字搜索poi并显示在地图上功能

## 效果展示
<img src=https://user-images.githubusercontent.com/7219191/167600361-fb90f178-188c-4382-8c92-380e6f2f1ae7.jpg width=40% />

## 实现功能包括
* 支持iOS
* 处理地图所需权限申请
* 定位并自动移动地图至当前位置
* 关键字搜索POI
* 获取POI数据并返回


1,初始化地图
```dart
    final AMapWidget map = AMapWidget(
      onMapCreated: (controller){
      },
      onPoiSearchDone: onPoiSearchDone,
    );
```
 2, 搜索关键字

 ```dart
 _mapController.searchPOI(keyword: keyword, city: cityName)
 ```
 3,搜索结果回调

 ```dart

    void onPoiSearchDone(dynamic result) {
    // List<SpPoi>? poiList  = jsonConvert.convertListNotNull<SpPoi>(result);
    Iterable l = json.decode(result);
    List<SpPoiEntity>? list = List<SpPoiEntity>.from(l.map((json) => SpPoiEntity.fromJson(json)));
    print(poiList);
    setState(() {
      poiList = list;
    });
  }
 ```
## 注意事项
  目前仅支持iOS版本,后续会增加Android版本的支持

