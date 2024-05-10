import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_with_google_maps/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:flutter_with_google_maps/models/place_details_model/place_details_model.dart';
import 'package:flutter_with_google_maps/utils/Map_services.dart';
import 'package:flutter_with_google_maps/utils/google_maps_place_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.mapServices,
    required this.onPlaceSelect,
    required this.goToNewLocation,
  });
  final List<PlaceModel> places;
  final void Function(PlaceDetailsModel) onPlaceSelect;
  final void Function(PlaceDetailsModel) goToNewLocation;
  final MapServices mapServices;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index].description!),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.mapPin),
              onPressed: () async {
                var placeDetails = await mapServices.getPlaceDetails(
                    placeId: places[index].placeId!);
                goToNewLocation(placeDetails);
              },
            ),
            trailing: IconButton(
              onPressed: () async {
                var placeDetails = await mapServices.getPlaceDetails(
                    placeId: places[index].placeId!);
                onPlaceSelect(placeDetails);
              },
              icon: const Icon(Icons.arrow_circle_right_outlined),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: places.length,
      ),
    );
  }
}
