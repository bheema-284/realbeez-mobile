import 'dart:convert';

class PropertyAddress {
  final String locality;
  final String area;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  PropertyAddress({
    required this.locality,
    required this.area,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      locality: json['locality'] as String,
      area: json['area'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'locality': locality,
        'area': area,
        'city': city,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class OrientationMedia {
  final String orientation;
  final String url;
  final bool isVideo;

  OrientationMedia({
    required this.orientation,
    required this.url,
    required this.isVideo,
  });

  factory OrientationMedia.fromJson(Map<String, dynamic> json, {required bool video}) {
    return OrientationMedia(
      orientation: json['orientation'] as String,
      url: (video ? json['video'] : json['image']) as String,
      isVideo: video,
    );
  }
}

class Property {
  final int id;
  final String title;
  final String description;
  final String type;
  final String status;
  final int price;
  final String currency;
  final int areaSqFt;
  final int bedrooms;
  final int bathrooms;
  final String furnishing;
  final List<String> amenities;
  final String reraNo;
  final String block;
  final int noOfUnits;
  final int noOfFloors;
  final int floorNo;
  final String flatNo;
  final PropertyAddress address;
  final List<OrientationMedia> images;
  final List<OrientationMedia> videos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.currency,
    required this.areaSqFt,
    required this.bedrooms,
    required this.bathrooms,
    required this.furnishing,
    required this.amenities,
    required this.reraNo,
    required this.block,
    required this.noOfUnits,
    required this.noOfFloors,
    required this.floorNo,
    required this.flatNo,
    required this.address,
    required this.images,
    required this.videos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      price: json['price'] as int,
      currency: json['currency'] as String,
      areaSqFt: json['area_sq_ft'] as int,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      furnishing: json['furnishing'] as String,
      amenities: (json['amenities'] as List<dynamic>).cast<String>(),
      reraNo: json['rera_no'] as String,
      block: json['block'] as String,
      noOfUnits: json['no_of_units'] as int,
      noOfFloors: json['no_of_floors'] as int,
      floorNo: json['floor_no'] as int,
      flatNo: json['flat_no'] as String,
      address: PropertyAddress.fromJson(json['address'] as Map<String, dynamic>),
      images: ((json['images'] as List<dynamic>?) ?? [])
          .map((e) => OrientationMedia.fromJson(e as Map<String, dynamic>, video: false))
          .toList(),
      videos: ((json['videos'] as List<dynamic>?) ?? [])
          .map((e) => OrientationMedia.fromJson(e as Map<String, dynamic>, video: true))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static List<Property> listFromJsonString(String jsonString) {
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }
}















