import 'package:geojson/geojson.dart' as geojson;
import 'package:turf/turf.dart';

void main(List<String> arguments) async {
  final position = Position(6.4590, 3.6015);

  bool isPresent = await geojson.locationBoundary(position, county: "Eti-Osa");

  print("The value is $isPresent");
}
