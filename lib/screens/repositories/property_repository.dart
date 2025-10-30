import 'package:flutter/services.dart' show rootBundle;
import 'package:real_beez/screens/models/property.dart';

class PropertyRepository {
  const PropertyRepository();

  Future<List<Property>> loadProperties() async {
    final jsonString = await rootBundle.loadString('static_data.json');
    return Property.listFromJsonString(jsonString);
  }
}















