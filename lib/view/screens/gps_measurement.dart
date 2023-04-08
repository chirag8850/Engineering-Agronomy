import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GpsMeasure extends StatefulWidget {
  const GpsMeasure({super.key});

  @override
  State<GpsMeasure> createState() => _GpsMeasureState();
}

class _GpsMeasureState extends State<GpsMeasure> {

  MapType _currentMapType = MapType.normal;

  late GoogleMapController googleMapController;

  Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGoogle = CameraPosition(
      target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  List<LatLng> _points = [];
  bool _isMeasuring = false;
  double _area = 0;
  Set<Polygon> _polygons = {};

  
  
  void _addPoint() async {
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng latLng = LatLng(position.latitude, position.longitude);

    // Add the location to the list of points
    setState(() {
      _points.add(latLng);
    });
  }

  void _startMeasuring() {
    setState(() {
      _isMeasuring = true;
      _polygons.clear();
    });
  }

  void _stopMeasuring() {
    // Add the polygon formed by the user's path to the set of polygons
    _polygons.add(Polygon(
      polygonId: PolygonId(_polygons.length.toString()),
      points: _points,
      fillColor: Colors.blue.withOpacity(0.5),
      strokeColor: Colors.blue,
      strokeWidth: 3,
    ));

    // Calculate the area of the polygon
    _area = _calculateArea(_points);

    setState(() {
      _isMeasuring = false;
    });
  }

  // double _calculateArea(List<LatLng> points) {
  // if (points.length < 3) return 0.0;
  // double area = 0.0;
  // int j = points.length - 1;
  // for (int i = 0; i < points.length; i++) {
  //   double xi = points[i].longitude;
  //   double yi = points[i].latitude;
  //   double xj = points[j].longitude;
  //   double yj = points[j].latitude;
  //   area += (xj + xi) * (yj - yi);
  //   j = i;
  // }
  // return (area.abs() / 2.0);
  // }

  double _calculateArea(List<LatLng> points) {
  if (points.length < 3) return 0.0;
  
  double area = 0.0;
  int j = points.length - 1;
  
  for (int i = 0; i < points.length; i++) {
    double lat1 = points[j].latitude;
    double lng1 = points[j].longitude;
    double lat2 = points[i].latitude;
    double lng2 = points[i].longitude;

    area += (lng2 - lng1) * sin(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0);
    j = i;
  }
  
  return area * 6378137.0 * 6378137.0 / 2.0;
}

// double _calculateArea(List<LatLng> points) {
//   if (points.length < 3) return 0.0;
  
//   double sum1 = 0.0;
//   double sum2 = 0.0;
  
//   for (int i = 0; i < points.length; i++) {
//     final point1 = points[i];
//     final point2 = points[(i + 1) % points.length];
    
//     sum1 += point1.latitude * point2.longitude;
//     sum2 += point1.longitude * point2.latitude;
//   }
  
//   return 0.5 * (sum1 - sum2).abs();
// }

  void _clear() {
    setState(() {
      _points.clear();
      _polygons.clear();
      // _circles.clear();
      _area = 0.0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 4, 185, 59), 
        centerTitle: true,
        title: const Text("GPS Measurement"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _kGoogle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            polygons: _polygons,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
            onTap: (LatLng latLng) {
              if (_isMeasuring) {
                setState(() {
                  _points.add(latLng);
                });
              }
            },
          ),
          Positioned(
            bottom: 110, 
            right: 5, 
            child: FloatingActionButton(
              onPressed: (){
                 setState(() {
                    _currentMapType = MapType.hybrid;
                  });
              },
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Icon(Icons.satellite),
              ),
          ),
          Positioned(
            bottom: 180, 
            right: 5, 
            child: FloatingActionButton(
              onPressed: (){
                setState(() {
                    _currentMapType = MapType.normal;
                  });
              },
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Icon(Icons.map_rounded),
              ),
          ),
          Positioned(
            bottom: 250, 
            right: 5, 
            child: FloatingActionButton(
              onPressed: _clear,
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Image(image: AssetImage('assets/images/icon-eraser.png')),
              ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _addPoint,
            child: Icon(Icons.add),
            backgroundColor: const Color.fromARGB(255, 4, 185, 59),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _isMeasuring ? _stopMeasuring : _startMeasuring,
            child: Icon(_isMeasuring ? Icons.stop : Icons.play_arrow),
            backgroundColor: const Color.fromARGB(255, 4, 185, 59),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        SizedBox(width: 16),
        Container(
          height: 50,
          child: Center(
            child: Text(
              'Points: ${_points.length}',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}