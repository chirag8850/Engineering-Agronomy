import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login/view/screens/sidebar.dart';

class HomeScreen extends StatefulWidget { 
  const HomeScreen();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {


  MapType _currentMapType = MapType.normal;

  late GoogleMapController googleMapController;

  Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGoogle = CameraPosition(
      target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 4, 185, 59), 
        centerTitle: true,
        title: const Text("Engineering Agronomy"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _kGoogle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
          ),
          Positioned(
            bottom: 110, // Set the position from the bottom of the screen
            right: 5, // Set the position from the right of the screen
            child: FloatingActionButton(
              onPressed: (){
                 setState(() {
                    _currentMapType = MapType.satellite;
                  });
              },
              backgroundColor: const Color.fromARGB(255, 4, 185, 59),
              child: const Icon(Icons.satellite),
              ),
          ),
          Positioned(
            bottom: 180, // Set the position from the bottom of the screen
            right: 5, // Set the position from the right of the screen
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
        ],
      ),
    );
  }
}
