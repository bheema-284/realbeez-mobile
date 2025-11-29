// lib/models/property_model.dart

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final String status;
  final int price;
  final String currency;
  final int areaSqFt;
  final int bedrooms;
  final int bathrooms;
  final String furnishing;
  final List<String> amenities;
  final PropertyAddress address;
  final String region;
  final String reraNo;
  final String block;
  final int noOfUnits;
  final int noOfFloors;
  final int floorNo;
  final String flatNo;
  final List<PropertyImage> images;
  final List<PropertyVideo> videos;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.price,
    required this.currency,
    required this.areaSqFt,
    required this.bedrooms,
    required this.bathrooms,
    required this.furnishing,
    required this.amenities,
    required this.address,
    required this.region,
    required this.reraNo,
    required this.block,
    required this.noOfUnits,
    required this.noOfFloors,
    required this.floorNo,
    required this.flatNo,
    required this.images,
    required this.videos,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? '',
      areaSqFt: json['area_sq_ft'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      furnishing: json['furnishing'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      address: PropertyAddress.fromJson(json['address'] ?? {}),
      region: json['region'] ?? '',
      reraNo: json['rera_no'] ?? '',
      block: json['block'] ?? '',
      noOfUnits: json['no_of_units'] ?? 0,
      noOfFloors: json['no_of_floors'] ?? 0,
      floorNo: json['floor_no'] ?? 0,
      flatNo: json['flat_no'] ?? '',
      images: (json['images'] as List?)
              ?.map((e) => PropertyImage.fromJson(e))
              .toList() ??
          [],
      videos: (json['videos'] as List?)
              ?.map((e) => PropertyVideo.fromJson(e))
              .toList() ??
          [],
    );
  }
}

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
      locality: json['locality'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class PropertyImage {
  final String direction;
  final String url;
  final String aspectRatio;

  PropertyImage({
    required this.direction,
    required this.url,
    required this.aspectRatio,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      direction: json['direction'] ?? '',
      url: json['url'] ?? '',
      aspectRatio: json['aspect_ratio'] ?? '1:1',
    );
  }
}

class PropertyVideo {
  final String direction;
  final String url;
  final String publicId;

  PropertyVideo({
    required this.direction,
    required this.url,
    required this.publicId,
  });

  factory PropertyVideo.fromJson(Map<String, dynamic> json) {
    return PropertyVideo(
      direction: json['direction'] ?? '',
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }
}
