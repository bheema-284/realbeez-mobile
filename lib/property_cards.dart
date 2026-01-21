// property_data.dart
class Property {
  final String id;
  final String title;
  final String description;
  final int price;
  final String currency;
  final String status;
  final Address address;
  final List<PropertyImage> images;
  final List<String> features;
  final List<String> amenities;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.status,
    required this.address,
    required this.images,
    required this.features,
    required this.amenities,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Address {
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;

  Address({
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });
}

class PropertyImage {
  final String url;
  final bool isPrimary;

  PropertyImage({required this.url, required this.isPrimary});
}

class PropertyData {
  // Online video URLs (YouTube links for demo)
  static final List<String> propertyVideoUrls = [
    // Property tours
    "https://www.youtube.com/watch?v=oQXyQ6JgMhE", // Modern apartment tour
    "https://www.youtube.com/watch?v=QoUj_XNlX_4", // Luxury villa tour
    "https://www.youtube.com/watch?v=9sJUDx7iEJw", // Aerial drone view
    "https://www.youtube.com/watch?v=IA8GkZyoT_E", // Property walkthrough
    "https://www.youtube.com/watch?v=tAGnKpE4NCI", // Residential property
    "https://www.youtube.com/watch?v=7Bv7BZbYbXk", // Apartment interior
    "https://www.youtube.com/watch?v=jNQXAC9IVRw", // Villa exterior
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ", // Complete property tour
    // Location and neighborhood
    "https://www.youtube.com/watch?v=9bZkp7q19f0", // Neighborhood tour
    "https://www.youtube.com/watch?v=JGwWNGJdvx8", // Location highlights
    // Amenities
    "https://www.youtube.com/watch?v=CduA0TULnow", // Amenities showcase
    "https://www.youtube.com/watch?v=OPf0YbXqDm0", // Clubhouse tour
    // Virtual tours
    "https://www.youtube.com/watch?v=UxxajLWwzqY", // 360° virtual tour
    "https://www.youtube.com/watch?v=zL19uMsnpSU", // Interactive tour
  ];

  // Alternative direct video links (if needed)
  static final List<String> directVideoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ];

  // Helper function to get video URL
  static String getVideoUrl(int index, {bool useYouTube = true}) {
    if (useYouTube) {
      return propertyVideoUrls[index % propertyVideoUrls.length];
    } else {
      return directVideoUrls[index % directVideoUrls.length];
    }
  }

  static List<Map<String, dynamic>> properties = [
    {
      "id": "201",
      "title": "2 BHK Apartment in Sky Towers",
      "description":
          "Modern 2-bedroom apartment with smart design and eco-friendly features.",
      "type": "apartment",
      "status": "under_construction",
      "price": 5200000,
      "currency": "INR",
      "area_sq_ft": 980,
      "bedrooms": 2,
      "bathrooms": 2,
      "furnishing": "unfurnished",
      "amenities": ["parking", "gym", "clubhouse", "24x7_security"],
      "rera_no": "RERA-TG-2025-56789",
      "block": "A",
      "no_of_units": 200,
      "no_of_floors": 20,
      "floor_no": 12,
      "flat_no": "12A-1205",
      "address": {
        "locality": "Sky Towers, Financial District",
        "area": "Gachibowli",
        "city": "Hyderabad",
        "state": "TG",
        "country": "India",
        "latitude": 17.4435,
        "longitude": 78.3772,
      },
      "images": [
        {"orientation": "north", "image": "assets/images/farmland1.png"},
        {"orientation": "south", "image": "assets/images/swipe.png"},
        {"orientation": "east", "image": "assets/images/farmland1.png"},
        {"orientation": "west", "image": "assets/images/swipe.png"},
      ],
      "videos": [
        {"orientation": "north", "video": getVideoUrl(0)},
        {"orientation": "south", "video": getVideoUrl(1)},
      ],
      "created_at": "2025-09-29T10:30:00Z",
      "updated_at": "2025-09-29T10:30:00Z",
    },
    {
      "id": 20897,
      "title": "tretc  in Sunrise Residency",
      "description":
          "Fully furnished 3BHK with modular kitchen and excellent connectivity.",
      "type": "apartment",
      "status": "ready_to_move",
      "price": 8500000,
      "currency": "INR",
      "area_sq_ft": 1600,
      "bedrooms": 3,
      "bathrooms": 3,
      "furnishing": "furnished",
      "amenities": ["parking", "gym", "swimming_pool", "kids_play_area"],
      "rera_no": "RERA-TG-2025-99999",
      "block": "D",
      "no_of_units": 150,
      "no_of_floors": 12,
      "floor_no": 5,
      "flat_no": "5D-502",
      "address": {
        "locality": "Sunrise Residency",
        "area": "Madhapur",
        "city": "Hyderabad",
        "state": "TG",
        "country": "India",
        "latitude": 17.4412,
        "longitude": 78.3915,
      },
      "images": [
        {"orientation": "north", "image": "assets/images/farmland1.png"},
        {"orientation": "south", "image": "assets/images/swipe.png"},
        {"orientation": "east", "image": "assets/images/farmland1.png"},
      ],
      "videos": [
        {
          "orientation": "north_east",
          "video": "https://example.com/videos/property203/northeast.mp4",
        },
        {
          "orientation": "south_west",
          "video": "https://example.com/videos/property203/southwest.mp4",
        },
      ],
      "created_at": "2025-09-29T10:30:00Z",
      "updated_at": "2025-09-29T10:30:00Z",
    },
  ];

  // Special offers data
  static List<Map<String, String>> specialOffers = [
    {'title': 'My Home Avatar', 'image': 'assets/images/unlock1.png'},
    {'title': 'Ankura Villas', 'image': 'assets/images/unlock2.png'},
    {'title': 'Prestige City', 'image': 'assets/images/unlock1.png'},
    {'title': 'Jumbooo City', 'image': 'assets/images/unlock2.png'},
  ];

  // Builder images data
  static List<String> builderImages = [
    'assets/images/provincia.png',
    'assets/images/sattva.png',
    'assets/images/prestige.png',
    'assets/images/lodha.png',
    'assets/images/aparna.png',
    'assets/images/my_home.png',
    'assets/images/home.png',
    'assets/images/smr.png',
    'assets/images/provincia.png',
    'assets/images/sattva.png',
    'assets/images/prestige.png',
    'assets/images/lodha.png',
    'assets/images/home.png',
    'assets/images/smr.png',
    'assets/images/provincia.png',
    'assets/images/sattva.png',
    'assets/images/prestige.png',
    'assets/images/lodha.png',
  ];

  // Enhanced media data for featured sites - using online video URLs
  static Map<String, Map<String, dynamic>> enhancedMediaData = {
    '4': {
      // Ankura Apartments
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/apartment1.png'},
        {'orientation': 'living_room', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'bedroom', 'image': 'assets/images/swipe.png'},
        {'orientation': 'kitchen', 'image': 'assets/images/apartment2.png'},
      ],
      'videos': [
        {'orientation': 'virtual_tour', 'video': getVideoUrl(0)},
        {'orientation': 'amenities', 'video': getVideoUrl(10)},
      ],
    },
    '201': {
      // Sky Towers
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'living_area', 'image': 'assets/images/swipe.png'},
        {
          'orientation': 'master_bedroom',
          'image': 'assets/images/apartment1.png',
        },
        {'orientation': 'bathroom', 'image': 'assets/images/apartment2.png'},
      ],
      'videos': [
        {'orientation': 'walkthrough', 'video': getVideoUrl(3)},
        {'orientation': 'location', 'video': getVideoUrl(9)},
      ],
    },
    '7': {
      // Prestige Apartments
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/apartment2.png'},
        {'orientation': 'living_room', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'balcony', 'image': 'assets/images/swipe.png'},
        {'orientation': 'view', 'image': 'assets/images/apartment1.png'},
      ],
      'videos': [
        {'orientation': 'tour', 'video': getVideoUrl(0)},
        {'orientation': 'amenities', 'video': getVideoUrl(10)},
      ],
    },
    '203': {
      // Sunrise Residency
      'images': [
        {'orientation': 'building', 'image': 'assets/images/swipe.png'},
        {'orientation': 'interior', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'kitchen', 'image': 'assets/images/apartment2.png'},
        {'orientation': 'bathroom', 'image': 'assets/images/apartment1.png'},
      ],
      'videos': [
        {'orientation': 'virtual_tour', 'video': getVideoUrl(11)},
        {'orientation': 'neighborhood', 'video': getVideoUrl(8)},
      ],
    },
    '9': {
      // Luxury Towers
      'images': [
        {'orientation': 'tower', 'image': 'assets/images/apartment1.png'},
        {'orientation': 'penthouse', 'image': 'assets/images/apartment2.png'},
        {'orientation': 'pool', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'gym', 'image': 'assets/images/swipe.png'},
      ],
      'videos': [
        {'orientation': 'luxury_tour', 'video': getVideoUrl(6)},
        {'orientation': 'amenities', 'video': getVideoUrl(10)},
      ],
    },
    '10': {
      // Elite Residences
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/apartment2.png'},
        {
          'orientation': 'living_space',
          'image': 'assets/images/apartment1.png',
        },
        {'orientation': 'bedroom', 'image': 'assets/images/swipe.png'},
        {'orientation': 'view', 'image': 'assets/images/farmland1.png'},
      ],
      'videos': [
        {'orientation': 'walkthrough', 'video': getVideoUrl(4)},
        {'orientation': 'location', 'video': getVideoUrl(9)},
      ],
    },
    '11': {
      // Green Villa
      'images': [
        {'orientation': 'villa_exterior', 'image': 'assets/images/villa1.png'},
        {'orientation': 'garden', 'image': 'assets/images/villa2.png'},
        {'orientation': 'living_room', 'image': 'assets/images/villa3.png'},
        {'orientation': 'pool', 'image': 'assets/images/villa1.png'},
      ],
      'videos': [
        {'orientation': 'virtual_tour', 'video': getVideoUrl(0)},
        {'orientation': 'garden_tour', 'video': getVideoUrl(2)},
      ],
    },
    '12': {
      // Palm Villas
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/villa1.png'},
        {'orientation': 'interior', 'image': 'assets/images/villa2.png'},
        {'orientation': 'bedroom', 'image': 'assets/images/villa3.png'},
        {'orientation': 'kitchen', 'image': 'assets/images/villa1.png'},
      ],
      'videos': [
        {'orientation': 'tour', 'video': getVideoUrl(4)},
        {'orientation': 'amenities', 'video': getVideoUrl(10)},
      ],
    },
    '13': {
      // Lake View Villas
      'images': [
        {'orientation': 'lake_view', 'image': 'assets/images/villa2.png'},
        {'orientation': 'exterior', 'image': 'assets/images/villa3.png'},
        {'orientation': 'living_area', 'image': 'assets/images/villa1.png'},
        {'orientation': 'master_suite', 'image': 'assets/images/villa2.png'},
      ],
      'videos': [
        {'orientation': 'virtual_tour', 'video': getVideoUrl(11)},
        {'orientation': 'lake_view', 'video': getVideoUrl(2)},
      ],
    },
    '14': {
      // Royal Greens
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/villa2.png'},
        {'orientation': 'garden', 'image': 'assets/images/villa3.png'},
        {'orientation': 'interior', 'image': 'assets/images/villa1.png'},
        {'orientation': 'pool_area', 'image': 'assets/images/villa2.png'},
      ],
      'videos': [
        {'orientation': 'tour', 'video': getVideoUrl(3)},
        {'orientation': 'amenities', 'video': getVideoUrl(10)},
      ],
    },
    '15': {
      // Heritage Villa
      'images': [
        {
          'orientation': 'heritage_exterior',
          'image': 'assets/images/villa3.png',
        },
        {
          'orientation': 'classic_interior',
          'image': 'assets/images/villa1.png',
        },
        {'orientation': 'garden', 'image': 'assets/images/villa2.png'},
        {'orientation': 'pool', 'image': 'assets/images/villa3.png'},
      ],
      'videos': [
        {'orientation': 'heritage_tour', 'video': getVideoUrl(0)},
        {'orientation': 'garden_tour', 'video': getVideoUrl(2)},
      ],
    },
    '202': {
      // Palm Meadows
      'images': [
        {'orientation': 'exterior', 'image': 'assets/images/villa3.png'},
        {'orientation': 'luxury_interior', 'image': 'assets/images/villa2.png'},
        {'orientation': 'master_bedroom', 'image': 'assets/images/villa1.png'},
        {'orientation': 'private_garden', 'image': 'assets/images/villa3.png'},
      ],
      'videos': [
        {'orientation': 'luxury_tour', 'video': getVideoUrl(6)},
        {'orientation': 'garden_tour', 'video': getVideoUrl(2)},
      ],
    },
    '16': {
      // Sunrise Farms
      'images': [
        {'orientation': 'overview', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'field1', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'field2', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'irrigation', 'image': 'assets/images/farmland2.png'},
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'walkthrough', 'video': getVideoUrl(4)},
      ],
    },
    '17': {
      // Green Acres
      'images': [
        {'orientation': 'overview', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'crops', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'soil', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'boundary', 'image': 'assets/images/farmland2.png'},
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'tour', 'video': getVideoUrl(0)},
      ],
    },
    '18': {
      // Harvest Fields
      'images': [
        {'orientation': 'overview', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'field1', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'field2', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'water_source', 'image': 'assets/images/farmland1.png'},
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'walkthrough', 'video': getVideoUrl(4)},
      ],
    },
    '19': {
      // Golden Fields
      'images': [
        {'orientation': 'overview', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'irrigation', 'image': 'assets/images/farmland1.png'},
        {'orientation': 'soil_quality', 'image': 'assets/images/farmland2.png'},
        {'orientation': 'access_road', 'image': 'assets/images/farmland1.png'},
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'irrigation_system', 'video': getVideoUrl(1)},
      ],
    },
    '20': {
      // Valley Farms
      'images': [
        {'orientation': 'valley_view', 'image': 'assets/images/farmland1.png'},
        {
          'orientation': 'expansive_field',
          'image': 'assets/images/farmland2.png',
        },
        {'orientation': 'water_body', 'image': 'assets/images/farmland1.png'},
        {
          'orientation': 'access_points',
          'image': 'assets/images/farmland2.png',
        },
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'valley_tour', 'video': getVideoUrl(5)},
      ],
    },
    '21': {
      // Mega Farms
      'images': [
        {'orientation': 'overview', 'image': 'assets/images/farmland1.png'},
        {
          'orientation': 'field_section1',
          'image': 'assets/images/farmland2.png',
        },
        {
          'orientation': 'field_section2',
          'image': 'assets/images/farmland1.png',
        },
        {
          'orientation': 'infrastructure',
          'image': 'assets/images/farmland2.png',
        },
      ],
      'videos': [
        {'orientation': 'drone_view', 'video': getVideoUrl(2)},
        {'orientation': 'complete_tour', 'video': getVideoUrl(5)},
      ],
    },
    '22': {
      // Emerald Plots
      'images': [
        {'orientation': 'plot1', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'plot3', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'location', 'image': 'assets/images/openplot2.png'},
      ],
      'videos': [
        {'orientation': 'site_tour', 'video': getVideoUrl(0)},
        {'orientation': 'neighborhood', 'video': getVideoUrl(8)},
      ],
    },
    '23': {
      // City Edge Plots
      'images': [
        {'orientation': 'plot1', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'plot3', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'view', 'image': 'assets/images/openplot2.png'},
      ],
      'videos': [
        {'orientation': 'site_tour', 'video': getVideoUrl(0)},
        {'orientation': 'location_view', 'video': getVideoUrl(8)},
      ],
    },
    '24': {
      // Sunset Plots
      'images': [
        {'orientation': 'lake_view', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'plot1', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'sunset_view', 'image': 'assets/images/openplot1.png'},
      ],
      'videos': [
        {'orientation': 'lake_tour', 'video': getVideoUrl(2)},
        {'orientation': 'plot_walkthrough', 'video': getVideoUrl(4)},
      ],
    },
    '25': {
      // Green Valley Plots
      'images': [
        {
          'orientation': 'hillside_view',
          'image': 'assets/images/openplot2.png',
        },
        {'orientation': 'plot1', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'valley_view', 'image': 'assets/images/openplot1.png'},
      ],
      'videos': [
        {'orientation': 'hillside_tour', 'video': getVideoUrl(2)},
        {'orientation': 'valley_view', 'video': getVideoUrl(0)},
      ],
    },
    '26': {
      // Hilltop Plots
      'images': [
        {'orientation': 'hilltop_view', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot1', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot1.png'},
        {
          'orientation': 'panoramic_view',
          'image': 'assets/images/openplot2.png',
        },
      ],
      'videos': [
        {'orientation': 'hilltop_tour', 'video': getVideoUrl(0)},
        {'orientation': 'view_tour', 'video': getVideoUrl(1)},
      ],
    },
    '27': {
      // Royal Plots
      'images': [
        {'orientation': 'premium_view', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'plot1', 'image': 'assets/images/openplot2.png'},
        {'orientation': 'plot2', 'image': 'assets/images/openplot1.png'},
        {'orientation': 'location', 'image': 'assets/images/openplot2.png'},
      ],
      'videos': [
        {'orientation': 'premium_tour', 'video': getVideoUrl(6)},
        {'orientation': 'location_view', 'video': getVideoUrl(9)},
      ],
    },
  };

  // Category data for featured sites - COMPLETE DATA FOR ALL CATEGORIES
  static Map<String, Map<String, dynamic>> featuredSitesData = {
    'apartment': {
      'titles': ['2 BHK Apartments', '3 BHK Apartments', '4 BHK Apartments'],
      'data': [
        {
          'items': [
            {
              'subtitle': 'Ankura Apartments',
              'location': 'Gachibowli',
              'price': 'Price Range start from',
              'priceRange': '80 Lakhs - 1 Cr',
              'image': 'assets/images/apartment1.png',
              'isNew': true,
              'property': Property(
                id: '4',
                title: 'Ankura Apartments',
                description: '2BHK Apartments in Gachibowli',
                price: 8000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Gachibowli',
                  area: 'Gachibowli',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500032',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['4']!['images'],
              'videos': enhancedMediaData['4']!['videos'],
            },
            {
              'subtitle': 'Sky Towers',
              'location': 'Financial District',
              'price': 'Price Range start from',
              'priceRange': '52 Lakhs - 65 Lakhs',
              'image': 'assets/images/farmland1.png',
              'isNew': false,
              'property': Property(
                id: '201',
                title: 'Sky Towers Apartments',
                description: 'Modern 2BHK in Financial District',
                price: 5200000,
                currency: 'INR',
                status: 'under_construction',
                address: Address(
                  street: 'Financial District',
                  area: 'Gachibowli',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500032',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['201']!['images'],
              'videos': enhancedMediaData['201']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Prestige Apartments',
              'location': 'Hitech City',
              'price': 'Price Range start from',
              'priceRange': '1.2Cr - 1.5Cr',
              'image': 'assets/images/apartment2.png',
              'isNew': false,
              'property': Property(
                id: '7',
                title: 'Prestige Apartments',
                description: '3BHK Apartments in Hitech City',
                price: 12000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hitech City',
                  area: 'Hitech City',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['7']!['images'],
              'videos': enhancedMediaData['7']!['videos'],
            },
            {
              'subtitle': 'Sunrise Residency',
              'location': 'Madhapur',
              'price': 'Price Range start from',
              'priceRange': '85 Lakhs - 1 Cr',
              'image': 'assets/images/swipe.png',
              'isNew': true,
              'property': Property(
                id: '203',
                title: 'Sunrise Residency',
                description: '3BHK Ready-to-Move Apartments',
                price: 8500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Madhapur',
                  area: 'Madhapur',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/swipe.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['203']!['images'],
              'videos': enhancedMediaData['203']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Luxury Towers',
              'location': 'Jubilee Hills',
              'price': 'Price Range start from',
              'priceRange': '2.5Cr - 3Cr',
              'image': 'assets/images/apartment1.png',
              'isNew': true,
              'property': Property(
                id: '9',
                title: 'Luxury Towers',
                description: '4BHK Apartments in Jubilee Hills',
                price: 25000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Jubilee Hills',
                  area: 'Jubilee Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500033',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['9']!['images'],
              'videos': enhancedMediaData['9']!['videos'],
            },
            {
              'subtitle': 'Elite Residences',
              'location': 'Banjara Hills',
              'price': 'Price Range start from',
              'priceRange': '3Cr - 3.8Cr',
              'image': 'assets/images/apartment2.png',
              'isNew': false,
              'property': Property(
                id: '10',
                title: 'Elite Residences',
                description: '4BHK Luxury Apartments',
                price: 30000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Banjara Hills',
                  area: 'Banjara Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500034',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/apartment2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['10']!['images'],
              'videos': enhancedMediaData['10']!['videos'],
            },
          ],
        },
      ],
    },
    'villa': {
      'titles': ['2 BHK Villas', '3 BHK Villas', '4 BHK Villas'],
      'data': [
        {
          'items': [
            {
              'subtitle': 'Green Villa',
              'location': 'Shamirpet',
              'price': 'Price Range start from',
              'priceRange': '1.8Cr - 2Cr',
              'image': 'assets/images/villa1.png',
              'isNew': true,
              'property': Property(
                id: '11',
                title: 'Green Villa',
                description: '2BHK Villas in Shamirpet',
                price: 18000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Shamirpet',
                  area: 'Shamirpet',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500078',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['11']!['images'],
              'videos': enhancedMediaData['11']!['videos'],
            },
            {
              'subtitle': 'Palm Villas',
              'location': 'Nagole',
              'price': 'Price Range start from',
              'priceRange': '1.5Cr - 1.8Cr',
              'image': 'assets/images/villa1.png',
              'isNew': false,
              'property': Property(
                id: '12',
                title: 'Palm Villas',
                description: '2BHK Villas in Nagole',
                price: 15000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Nagole',
                  area: 'Nagole',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500068',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['12']!['images'],
              'videos': enhancedMediaData['12']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Lake View Villas',
              'location': 'Gachibowli',
              'price': 'Price Range start from',
              'priceRange': '2.5Cr - 3Cr',
              'image': 'assets/images/villa2.png',
              'isNew': false,
              'property': Property(
                id: '13',
                title: 'Lake View Villas',
                description: '3BHK Villas in Gachibowli',
                price: 25000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Gachibowli',
                  area: 'Gachibowli',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500032',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['13']!['images'],
              'videos': enhancedMediaData['13']!['videos'],
            },
            {
              'subtitle': 'Royal Greens',
              'location': 'Kukatpally',
              'price': 'Price Range start from',
              'priceRange': '2.2Cr - 2.6Cr',
              'image': 'assets/images/villa2.png',
              'isNew': true,
              'property': Property(
                id: '14',
                title: 'Royal Greens',
                description: '3BHK Villas in Kukatpally',
                price: 22000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Kukatpally',
                  area: 'Kukatpally',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500072',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['14']!['images'],
              'videos': enhancedMediaData['14']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Heritage Villa',
              'location': 'Jubilee Hills',
              'price': 'Price Range start from',
              'priceRange': '4Cr - 5Cr',
              'image': 'assets/images/villa3.png',
              'isNew': true,
              'property': Property(
                id: '15',
                title: 'Heritage Villa',
                description: '4BHK Villas in Jubilee Hills',
                price: 40000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Jubilee Hills',
                  area: 'Jubilee Hills',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500033',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['15']!['images'],
              'videos': enhancedMediaData['15']!['videos'],
            },
            {
              'subtitle': 'Palm Meadows',
              'location': 'Kompally',
              'price': 'Price Range start from',
              'priceRange': '3.5Cr - 4.2Cr',
              'image': 'assets/images/villa3.png',
              'isNew': false,
              'property': Property(
                id: '202',
                title: 'Palm Meadows Villas',
                description: '4BHK Luxury Villas',
                price: 35000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Kompally',
                  area: 'Kompally',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500014',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/villa3.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['202']!['images'],
              'videos': enhancedMediaData['202']!['videos'],
            },
          ],
        },
      ],
    },
    'farmland': {
      'titles': ['Small Farmlands', 'Medium Farmlands', 'Large Farmlands'],
      'data': [
        {
          'items': [
            {
              'subtitle': 'Sunrise Farms',
              'location': 'Outskirts',
              'price': 'Price Range start from',
              'priceRange': '30 Lakhs - 50 Lakhs',
              'image': 'assets/images/farmland1.png',
              'isNew': false,
              'property': Property(
                id: '16',
                title: 'Sunrise Farms',
                description: 'Small Farmland in Outskirts',
                price: 3000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Outskirts',
                  area: 'Outskirts',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500075',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['16']!['images'],
              'videos': enhancedMediaData['16']!['videos'],
            },
            {
              'subtitle': 'Green Acres',
              'location': 'Countryside',
              'price': 'Price Range start from',
              'priceRange': '35 Lakhs - 55 Lakhs',
              'image': 'assets/images/farmland1.png',
              'isNew': true,
              'property': Property(
                id: '17',
                title: 'Green Acres',
                description: 'Small Farmland in Countryside',
                price: 3500000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Countryside',
                  area: 'Countryside',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500076',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['17']!['images'],
              'videos': enhancedMediaData['17']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Harvest Fields',
              'location': 'Periphery',
              'price': 'Price Range start from',
              'priceRange': '60 Lakhs - 90 Lakhs',
              'image': 'assets/images/farmland2.png',
              'isNew': false,
              'property': Property(
                id: '18',
                title: 'Harvest Fields',
                description: 'Medium Farmland in Periphery',
                price: 6000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Periphery',
                  area: 'Periphery',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500077',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['18']!['images'],
              'videos': enhancedMediaData['18']!['videos'],
            },
            {
              'subtitle': 'Golden Fields',
              'location': 'Rural Area',
              'price': 'Price Range start from',
              'priceRange': '75 Lakhs - 1 Cr',
              'image': 'assets/images/farmland2.png',
              'isNew': true,
              'property': Property(
                id: '19',
                title: 'Golden Fields',
                description: 'Medium Farmland with Irrigation',
                price: 7500000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Rural Area',
                  area: 'Rural Area',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500078',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['19']!['images'],
              'videos': enhancedMediaData['19']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Valley Farms',
              'location': 'Outer Ring',
              'price': 'Price Range start from',
              'priceRange': '1Cr - 1.5Cr',
              'image': 'assets/images/farmland1.png',
              'isNew': true,
              'property': Property(
                id: '20',
                title: 'Valley Farms',
                description: 'Large Farmland in Outer Ring',
                price: 10000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Outer Ring',
                  area: 'Outer Ring',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500079',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['20']!['images'],
              'videos': enhancedMediaData['20']!['videos'],
            },
            {
              'subtitle': 'Mega Farms',
              'location': 'District Border',
              'price': 'Price Range start from',
              'priceRange': '1.2Cr - 1.8Cr',
              'image': 'assets/images/farmland1.png',
              'isNew': false,
              'property': Property(
                id: '21',
                title: 'Mega Farms',
                description: 'Large Agricultural Land',
                price: 12000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'District Border',
                  area: 'District Border',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500080',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/farmland1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['21']!['images'],
              'videos': enhancedMediaData['21']!['videos'],
            },
          ],
        },
      ],
    },
    'open_plot': {
      'titles': ['Small Plots', 'Medium Plots', 'Large Plots'],
      'data': [
        {
          'items': [
            {
              'subtitle': 'Emerald Plots',
              'location': 'Town Edge',
              'price': 'Price Range start from',
              'priceRange': '25 Lakhs - 35 Lakhs',
              'image': 'assets/images/openplot1.png',
              'isNew': false,
              'property': Property(
                id: '22',
                title: 'Emerald Plots',
                description: 'Small Plots in Town Edge',
                price: 2500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Town Edge',
                  area: 'Town Edge',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500080',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['22']!['images'],
              'videos': enhancedMediaData['22']!['videos'],
            },
            {
              'subtitle': 'City Edge Plots',
              'location': 'Suburban Area',
              'price': 'Price Range start from',
              'priceRange': '20 Lakhs - 30 Lakhs',
              'image': 'assets/images/openplot1.png',
              'isNew': true,
              'property': Property(
                id: '23',
                title: 'City Edge Plots',
                description: 'Small Residential Plots',
                price: 2000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Suburban Area',
                  area: 'Suburban Area',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500081',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['23']!['images'],
              'videos': enhancedMediaData['23']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Sunset Plots',
              'location': 'Near Lake',
              'price': 'Price Range start from',
              'priceRange': '45 Lakhs - 60 Lakhs',
              'image': 'assets/images/openplot2.png',
              'isNew': true,
              'property': Property(
                id: '24',
                title: 'Sunset Plots',
                description: 'Medium Plots Near Lake',
                price: 4500000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Near Lake',
                  area: 'Near Lake',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500082',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['24']!['images'],
              'videos': enhancedMediaData['24']!['videos'],
            },
            {
              'subtitle': 'Green Valley Plots',
              'location': 'Hillside',
              'price': 'Price Range start from',
              'priceRange': '50 Lakhs - 65 Lakhs',
              'image': 'assets/images/openplot2.png',
              'isNew': false,
              'property': Property(
                id: '25',
                title: 'Green Valley Plots',
                description: 'Medium Plots with View',
                price: 5000000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hillside',
                  area: 'Hillside',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500083',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot2.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['25']!['images'],
              'videos': enhancedMediaData['25']!['videos'],
            },
          ],
        },
        {
          'items': [
            {
              'subtitle': 'Hilltop Plots',
              'location': 'Hill Area',
              'price': 'Price Range start from',
              'priceRange': '75 Lakhs - 95 Lakhs',
              'image': 'assets/images/openplot1.png',
              'isNew': false,
              'property': Property(
                id: '26',
                title: 'Hilltop Plots',
                description: 'Large Plots in Hill Area',
                price: 7500000,
                currency: 'INR',
                status: 'ready_to_move',
                address: Address(
                  street: 'Hill Area',
                  area: 'Hill Area',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500083',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['26']!['images'],
              'videos': enhancedMediaData['26']!['videos'],
            },
            {
              'subtitle': 'Royal Plots',
              'location': 'Premium Location',
              'price': 'Price Range start from',
              'priceRange': '90 Lakhs - 1.2Cr',
              'image': 'assets/images/openplot1.png',
              'isNew': true,
              'property': Property(
                id: '27',
                title: 'Royal Plots',
                description: 'Large Premium Plots',
                price: 9000000,
                currency: 'INR',
                status: 'pre_launch',
                address: Address(
                  street: 'Premium Location',
                  area: 'Premium Location',
                  city: 'Hyderabad',
                  state: 'Telangana',
                  pincode: '500084',
                ),
                images: [
                  PropertyImage(
                    url: 'assets/images/openplot1.png',
                    isPrimary: true,
                  ),
                ],
                features: [],
                amenities: [],
              ),
              'images': enhancedMediaData['27']!['images'],
              'videos': enhancedMediaData['27']!['videos'],
            },
          ],
        },
      ],
    },
  };
}
