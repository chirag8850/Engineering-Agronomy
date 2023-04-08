import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding_platform_interface/src/models/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login/view/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



class PolygonScreen extends StatefulWidget {
  final Location? location;
  const PolygonScreen({Key? key, this.location}):super(key: key);


  @override
  _PolygonScreenState createState() => _PolygonScreenState();
}


class _PolygonScreenState extends State<PolygonScreen> {
  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Circle> _circles = HashSet<Circle>();
  final List<LatLng> _points = [];

  late GoogleMapController googleMapController;

  Completer<GoogleMapController> _controller = Completer();

  MapType _currentMapType = MapType.normal;
  bool _isNormalSelected = false;
  bool _isSatelliteSelected = false;
  bool _isTerrainSelected = false;
  late Color _iconColor;



  // Set<Marker> markers = {};
  Marker? _cameraMarker;
  
  double _area = 0.0;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
  }
  
  void _onTap(LatLng position) {
    
    setState(() {
      _points.add(position);
      _polygons.clear();
      _polygons.add(Polygon(
        polygonId: PolygonId('1'),
        points: _points,
        fillColor: Colors.red.withOpacity(0.5), 
        geodesic: true,
        strokeWidth: 4,
        strokeColor: Colors.deepOrange,
        zIndex: 0,
      ));

       _circles.add(Circle(
        circleId: CircleId(position.toString()),
        center: position,
        radius: 5,
        fillColor: Colors.green.withOpacity(1),
        strokeWidth: 0,
        zIndex: 1,
      ));

      _area = _calculateArea(_points);


    });
  }
  
  void _clear() {
    setState(() {
      _points.clear();
      _polygons.clear();
      _circles.clear();
      _area = 0.0;
    });
  }

  double _calculateArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    const double radius = 6371000;
    double area = 0.0;
    int j = points.length - 1;
    for (int i = 0; i < points.length; i++) {
      double xi = points[i].longitude * pi / 180;
      double yi = points[i].latitude * pi / 180;
      double xj = points[j].longitude * pi / 180;
      double yj = points[j].latitude * pi / 180;
      area += (xj + xi) * (yj - yi); 
      j = i;
    }
    return 0.5 * area * radius * radius;
  }
  
  void _removeLastPolygonPoint() {
    setState(() {
      if (_points.isNotEmpty) {
        final lastPoint = _points.removeLast();
        _circles.removeWhere((circle) => circle.circleId.value == lastPoint.toString());
      }
      _area = _calculateArea(_points);
    });
  }

  @override
  void initState() {
    super.initState();
    // Load the saved map type on app startup
    _loadMapType();
    _isNormalSelected = _currentMapType == MapType.normal;
    _isSatelliteSelected = _currentMapType == MapType.hybrid;
  }

  // Loads the saved map type from shared preferences
  void _loadMapType() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int mapTypeIndex = prefs.getInt('map_type') ?? 0;
  MapType mapType = MapType.values[mapTypeIndex];
  setState(() {
    _currentMapType = mapType;
    switch (mapType) {
      case MapType.normal:
        _isNormalSelected = true;
        _isSatelliteSelected = false;
        _isTerrainSelected = false;
        break;
      case MapType.hybrid:
        _isSatelliteSelected = true;
        _isNormalSelected = false;
        _isTerrainSelected = false;
        break;
      case MapType.terrain:
        _isTerrainSelected = true;
        _isSatelliteSelected = false;
        _isNormalSelected = false;
        break;
      case MapType.none:
        // TODO: Handle this case.
        break;
      case MapType.satellite:
        // TODO: Handle this case.
        break;
    }
    int iconColorValue = prefs.getInt('icon_color') ?? Colors.grey.value;
    _iconColor = Color(iconColorValue);
  });
}


  // Saves the selected map type to shared preferences
  void _saveMapType(MapType mapType, Color iconColor) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('map_type', mapType.index);
  await prefs.setInt('icon_color', iconColor.value);
}


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 4, 185, 59),
        title: const Text('Land Measurement', textAlign: TextAlign.left),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: (){
                  // Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
              ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child : PopupMenuButton(
              itemBuilder: (context)=>[
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        Icons.map,
                        color: _currentMapType == MapType.normal && _isNormalSelected ? _iconColor : Colors.grey
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Normal",
                          style: TextStyle(fontSize: 18), 
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.normal;
                      _isNormalSelected = true;
                      _isSatelliteSelected = false;
                      _isTerrainSelected = false;
                      _iconColor = Colors.green;
                    });
                     _saveMapType(MapType.normal, _iconColor);
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children:  [
                      Icon(
                        Icons.satellite,
                        color: _currentMapType == MapType.hybrid && _isSatelliteSelected ? _iconColor : Colors.grey
                        // color: _isSatelliteSelected ? Colors.green : Colors.grey,
                      ),
                      Padding(  
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Satellite",
                          style: TextStyle(fontSize: 18), 
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.hybrid;
                      _isSatelliteSelected = true;
                      _isNormalSelected = false;
                      _isTerrainSelected = false;
                      _iconColor = Colors.green; 
                    });
                     _saveMapType(MapType.hybrid, _iconColor);
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        color: _currentMapType == MapType.terrain && _isTerrainSelected ? _iconColor : Colors.grey
                        // color: _isTerrainSelected ? Colors.green : Colors.grey,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Terrain",
                          style: TextStyle(fontSize: 18), 
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.terrain;
                      _isTerrainSelected = true;
                      _isSatelliteSelected = false;
                      _isNormalSelected = false;
                      _iconColor = Colors.green; 
                    });
                    _saveMapType(MapType.terrain, _iconColor);
                  },
                )
              ],
              offset: const Offset(0, 0),
              child: const Icon(
                Icons.layers,
              ),
            )
          ),
        ]
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            onTap: _onTap,
            polygons: _polygons,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: widget.location !=null ? LatLng(widget.location!.latitude, widget.location!.longitude) : LatLng(37.4219999, -122.0840575),
              zoom: 17,
            ),
          markers: widget.location != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: LatLng(widget.location!.latitude, widget.location!.longitude),
                ),
              }
            : {},
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Padding(
          //     padding: EdgeInsets.only(bottom: 16.0),
          //     child: Text(
          //       '${_area.toStringAsFixed(2)} sq.m',
          //       style: TextStyle(
          //         color: _currentMapType == MapType.normal ? Colors.black : Colors.white,
          //         fontSize: 28,
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 140, // Set the position from the bottom of the screen
            right: 5, // Set the position from the right of the screen
            child: FloatingActionButton(
              onPressed: _clear,
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Image(image: AssetImage('assets/images/icon-eraser.png')),
              ),
          ),
          Positioned(
            bottom: 220, // Set the position from the bottom of the screen
            right: 5, // Set the position from the right of the screen
            child: FloatingActionButton(
              onPressed: _removeLastPolygonPoint,
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Icon(Icons.undo),
              ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Container(
          height: 50,
          child: Center(
            child: Text(
              'Area: ${_area.toStringAsFixed(2)} sq.m',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        // SizedBox(width: 16),
        // Container(
        //   height: 50,
        //   child: Center(
        //     child: Text(
        //       'Points: ${_points.length} (${_points.join(', ')})', // Display the points
        //       style: TextStyle(fontSize: 20),
        //     ),
        //   ),
        // ),
      ],
    ); 
  }
}

