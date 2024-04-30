import 'dart:convert';

import 'package:flutter_with_google_maps/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPlaceService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyCRKcVVWtCfa1TCSfMtfNJ599N_jrNUux4';

  Future<List<PlaceModel>> getPredictions({required String input}) async {
    var response = await http
        .get(Uri.parse('$baseUrl/autocomplete/json?key=$apiKey&input=$input'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceModel> places = [];
      for (var element in data) {
        places.add(PlaceModel.fromJson(element));
      }
      return places;
    } else {
      throw Exception();
    }
  }
}
