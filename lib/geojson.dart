import 'dart:convert';
import 'dart:io';
import 'package:turf/turf.dart';

Future<bool> locationBoundary(Position coordinate,
    {String county = "Eti-Osa"}) async {
  /// Loads the GeoJSON data, checks if a coordinate is within the geoboundary of a given county.
  ///
  /// Args:
  ///   coordinate (Position): The location to check.
  ///   county (String): The name of the county. Defaults to "Eti-Osa".
  ///
  /// Returns:
  ///   bool: True if the coordinate is within the county boundary, False otherwise.

  // Load the GeoJSON data
  final geoJsonData = File("nigeria_lga_boundaries.geojson").readAsStringSync();
  final lgaGeoJson = jsonDecode(geoJsonData);

  // Reverse coordinates (lat, lon to lon, lat)
  final geoJsonCoordinate = [coordinate.lat, coordinate.lng];

  // Create a Point from the reversed coordinate
  final point =
      Point(coordinates: Position(geoJsonCoordinate[0], geoJsonCoordinate[1]));

  // Normalize and process county name
  county = county.trim().replaceAll(" ", "-");

  dynamic featureDetails;

  // Check if the point is within the specified county
  for (var feature in lgaGeoJson["features"]) {
    if (feature["properties"]["admin2Name"] == county) {
      featureDetails = feature;
      break;
    }
  }

  if (featureDetails == null) {
    print("Feature for lga $county not found");
    return false;
  }

  /// Now check if the user is within
  final geometryJson = featureDetails["geometry"];
  final geometryType = geometryJson["type"].toString();

  if (geometryType.toLowerCase() == "polygon") {
    final polygon = Polygon.fromJson(geometryJson);

    if (booleanIntersects(point, polygon)) {
      return true;
    }
  } else if (geometryType.toLowerCase() == "multipolygon") {
    final multiPolygon = MultiPolygon.fromJson(geometryJson);

    if (booleanIntersects(point, multiPolygon)) {
      return true;
    }
  }

  return false;
}
