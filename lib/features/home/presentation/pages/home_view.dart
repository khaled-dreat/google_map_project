import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_with_google_maps/features/home/presentation/widgets/custom_text_field.dart';
import 'package:flutter_with_google_maps/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:flutter_with_google_maps/utils/google_maps_place_service/google_maps_place_service.dart';
import 'package:flutter_with_google_maps/utils/location_service/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late GoogleMapsPlaceService googleMapsPlaceService;
  late LocationService locationService;
  late CameraPosition initalCameraPosition;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  List<PlaceModel> places = [];
  bool isFirstCall = true;
  @override
  void initState() {
    googleMapsPlaceService = GoogleMapsPlaceService();
    initalCameraPosition = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    textEditingController = TextEditingController();
    fetchPredictions();
    updateCurrentLocation();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(
      () async {
        if (textEditingController.text.isNotEmpty) {
          List<PlaceModel> result = await googleMapsPlaceService.getPlacesData(
              input: textEditingController.text);
          places.clear();
          places.addAll(result);
          setState(() {});
        } else {
          setState(() {
            places.clear();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          Center(
            child: GoogleMap(
                mapType: MapType.hybrid,
                markers: markers,
                onMapCreated: (controller) {
                  googleMapController = controller;
                  updateCurrentLocation();
                },
                zoomControlsEnabled: false,
                initialCameraPosition: initalCameraPosition),
          ),
          Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: textEditingController,
                  ),
                  CustomListView(places: places)
                ],
              ))
        ]),
      ),
    );
  }

  void updateCurrentLocation() async {
    try {
      LocationData locationData = await locationService.getLocation();
      LatLng currentPoistion =
          LatLng(locationData.latitude!, locationData.longitude!);
      CameraPosition myCurrentCameraPosition =
          CameraPosition(target: currentPoistion, zoom: 16);
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      Marker currentLocationMarker =
          Marker(markerId: MarkerId("1"), position: currentPoistion);

      markers.add(currentLocationMarker);
      setState(() {});
    } on LocationServiceException catch (e) {
      // TODO
    } on LocationPermissionException catch (e) {
      // TODO
    } catch (e) {
      // TODO
    }
  }
}

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
  });

  final List<PlaceModel> places;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Text(places.elementAt(index).description!);
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: places.length);
  }
}

// ! update Location
//  void updateMyLocation() async {
//    await locationService.checkkAndRequestLocationService();
//    var hasPermission =
//        await locationService.checkkAndRequestLocationPermission();
//    if (hasPermission) {
//      locationService.getRealTimeLocationData(
//        (locationData) {
//          setMyLocationMarker(locationData);
//          updateMyCamera(locationData);
//        },
//      );
//    } else {}
//  }

// ! initialization  Markers
// void initMarkers() async {
//   var customMarkerIcon = BitmapDescriptor.fromBytes(
//       await getImageFromRawData("assets/images/icons8-marker-50.png", 100));
//
//   var myMarkers = places
//       .map(
//         (placeModel) => Marker(
//           icon: customMarkerIcon,
//           infoWindow: InfoWindow(title: placeModel.name),
//           position: placeModel.latLng,
//           markerId: MarkerId(
//             placeModel.id.toString(),
//           ),
//         ),
//       )
//       .toSet();
//   markers.addAll(myMarkers);
//   setState(() {});


// ! initialization  polylines
//Set<Polyline> polylines = {};
//void initPolyLines() {
//  Polyline polyline = const Polyline(polylineId: PolylineId("1"), points: [
//    LatLng(31.132964439427763, 30.036379470734442),
//    LatLng(31.132964439427763, 30.036379470734442),
//    LatLng(31.10937181445342, 30.07986148631722),
//    LatLng(31.16371342210075, 30.084556727436492),
//    LatLng(31.117586208659116, 29.98901877770532),
//  ]);
//  polylines.add(polyline);
//}

// ! initialization Map Style
// void initMapStyle() async {
//   var nighMapStyle = await DefaultAssetBundle.of(context)
//       .loadString("assets/map_syles/night_map_style.json");
//   googleMapController!.setMapStyle(nighMapStyle);
//   // initMarkers();
//   initPolyLines();
// }

// ! get Image From Raw Data
 // Future<Uint8List> getImageFromRawData(String image, double width) async {
 //   // * Convert Image to Row
 //   var imageData = await rootBundle.load(image);
 //   // * Change width of image
 //   var imageCodec = await ui.instantiateImageCodec(
 //       imageData.buffer.asUint8List(),
 //       targetWidth: width.round());
 //   var imageFrame = await imageCodec.getNextFrame();
 //   // * Change Image Format
 //   var imageByData =
 //       await imageFrame.image.toByteData(format: ui.ImageByteFormat.png);
 //   return imageByData!.buffer.asUint8List();
 // }

 // ! update My Camera
//  void updateMyCamera(LocationData locationData) {
//    if (isFirstCall) {
//      var camerPosition = CameraPosition(
//          target: LatLng(locationData.latitude!, locationData.longitude!),
//          zoom: 17);
//      googleMapController
//          ?.animateCamera(CameraUpdate.newCameraPosition(camerPosition));
//    } else {
//      googleMapController?.animateCamera(CameraUpdate.newLatLng(
//          LatLng(locationData.latitude!, locationData.longitude!)));
//    }
//  }

 // ! set My Location Marker
//  void setMyLocationMarker(LocationData locationData) {
//    var myLocationMarker = Marker(
//        markerId: const MarkerId("2"),
//        position: LatLng(locationData.latitude!, locationData.longitude!));
//    markers.add(myLocationMarker);
//    setState(() {});
//  }
// }