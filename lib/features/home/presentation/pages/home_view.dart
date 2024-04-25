import 'package:flutter/material.dart';
import 'package:google_map_project/features/home/data/models/m_palce.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

late GoogleMapController googleMapController;

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    // TODO: implement initState
    initMarkers();
    super.initState();
  }

  void initMapStyle() async {
    var nighMapStyle = await DefaultAssetBundle.of(context)
        .loadString("assets/json/google_map_style.json");
    googleMapController.setMapStyle(nighMapStyle);
    initMarkers();
  }

  Set<Marker> markers = {};
  void initMarkers() async {
    var customMarcker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/map-pointer-house-svgrepo-com.png");
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            icon: customMarcker,
            infoWindow: InfoWindow(title: placeModel.name),
            position: placeModel.latLng,
            markerId: MarkerId(
              placeModel.id.toString(),
            ),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: GoogleMap(
            markers: markers,
            onMapCreated: (controller) {
              googleMapController = controller;
              initMapStyle();
            },
            initialCameraPosition: CameraPosition(
                zoom: 12,
                target: LatLng(31.186070052677902, 29.93063447509182))),
      ),
    );
  }
}
