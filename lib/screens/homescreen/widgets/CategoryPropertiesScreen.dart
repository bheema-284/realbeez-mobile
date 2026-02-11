import 'package:flutter/material.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/homescreen/widgets/property.dart';

class CategoryPropertiesScreen extends StatelessWidget {
  final String categoryName;

  const CategoryPropertiesScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Property cards for the selected category
            _buildPropertyCardForCategory(context, categoryName),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCardForCategory(
    BuildContext context,
    String categoryName,
  ) {
    // Define properties for each category - USING SAME IDs AS PropertyDetailScreen
    final Map<String, List<Map<String, dynamic>>> categoryProperties = {
      'Top Trending Apartments': [
        {
          'propertyId': 'prop_001', // Changed from 'trend_001'
          'title': 'Sky View Villas',
          'location': 'Jubilee Hills, Hyderabad',
          'description': 'Live Drone View Available',
          'priceRange': '3.5 Cr – 5.2 Cr',
          'tagText': 'Drone Tour',
          'rating': 4.9,
          'distance': '1.5 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_002', // Changed from 'trend_002'
          'title': 'Urban Sky Apartments',
          'location': 'Financial District, Hyderabad',
          'description': 'Aerial Drone Tour Included',
          'priceRange': '2.8 Cr – 4.2 Cr',
          'tagText': 'Premium\nDrone View',
          'rating': 4.8,
          'distance': '2.8 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w-800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_003', // Changed from 'trend_003'
          'title': 'Prestige High Fields',
          'location': 'Gachibowli, Hyderabad',
          'description': 'Construction Progress View',
          'priceRange': '1.8 Cr – 2.5 Cr',
          'tagText': 'Under Construction\nLive Progress',
          'rating': 4.7,
          'distance': '3.2 km',
          'isNew': false,
          'imageUrl':
              'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&auto=format&fit=crop',
        },
      ],
      'Luxury Villas': [
        {
          'propertyId': 'prop_004', // Changed from 'villa_001'
          'title': 'Green Valley Community',
          'location': 'Hitech City, Hyderabad',
          'description': 'Neighborhood Drone Tour',
          'priceRange': '2.2 Cr – 3.8 Cr',
          'tagText': 'Area Tour\nAvailable',
          'rating': 4.8,
          'distance': '4.1 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_005', // Changed from 'villa_002'
          'title': 'Elite Penthouse Residences',
          'location': 'Banjara Hills, Hyderabad',
          'description': '360° Drone View',
          'priceRange': '4.5 Cr – 6.8 Cr',
          'tagText': 'Luxury\nPenthouse',
          'rating': 5.0,
          'distance': '2.5 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_006', // Changed from 'villa_003'
          'title': 'Royal Garden Estates',
          'location': 'Kokapet, Hyderabad',
          'description': 'Complete Property Tour',
          'priceRange': '1.5 Cr – 2.2 Cr',
          'tagText': 'Gated Community\nDrone View',
          'rating': 4.6,
          'distance': '5.3 km',
          'isNew': false,
          'imageUrl':
              'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&auto=format&fit=crop',
        },
      ],
      'Budget Apartments': [
        {
          'propertyId': 'prop_003', // Reusing prop_003
          'title': 'Prestige High Fields',
          'location': 'Gachibowli, Hyderabad',
          'description': 'Construction Progress View',
          'priceRange': '1.8 Cr – 2.5 Cr',
          'tagText': 'Budget\nAffordable',
          'rating': 4.7,
          'distance': '3.2 km',
          'isNew': false,
          'imageUrl':
              'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_007', // Using prop_007
          'title': 'Tech Park Commercial',
          'location': 'Raidurg, Hyderabad',
          'description': 'Commercial Space Available',
          'priceRange': '8.5 Cr – 12 Cr',
          'tagText': 'Commercial\nSpace',
          'rating': 4.9,
          'distance': '3.8 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&auto=format&fit=crop',
        },
      ],
      'Smart Homes': [
        {
          'propertyId': 'prop_001', // Reusing prop_001
          'title': 'Sky View Villas',
          'location': 'Jubilee Hills, Hyderabad',
          'description': 'Smart Home with Drone View',
          'priceRange': '3.5 Cr – 5.2 Cr',
          'tagText': 'Smart Home',
          'rating': 4.9,
          'distance': '1.5 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_002', // Reusing prop_002
          'title': 'Urban Sky Apartments',
          'location': 'Financial District, Hyderabad',
          'description': 'Modern apartments with smart home features',
          'priceRange': '2.8 Cr – 4.2 Cr',
          'tagText': 'Smart Home\nAutomated',
          'rating': 4.8,
          'distance': '2.8 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&auto=format&fit=crop',
        },
      ],
      'Eco Residences': [
        {
          'propertyId': 'prop_004', // Reusing prop_004
          'title': 'Green Valley Community',
          'location': 'Hitech City, Hyderabad',
          'description': 'Eco-friendly neighborhood',
          'priceRange': '2.2 Cr – 3.8 Cr',
          'tagText': 'Eco Friendly\nGreen',
          'rating': 4.8,
          'distance': '4.1 km',
          'isNew': true,
          'imageUrl':
              'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=800&auto=format&fit=crop',
        },
        {
          'propertyId': 'prop_006', // Reusing prop_006
          'title': 'Royal Garden Estates',
          'location': 'Kokapet, Hyderabad',
          'description': 'Environment-friendly sustainable homes',
          'priceRange': '1.5 Cr – 2.2 Cr',
          'tagText': 'Eco Friendly\nSustainable',
          'rating': 4.6,
          'distance': '5.3 km',
          'isNew': false,
          'imageUrl':
              'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&auto=format&fit=crop',
        },
      ],
    };

    final properties = categoryProperties[categoryName] ?? [];

    if (properties.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No properties available for this category',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Category description
        Container(
          child: Text(
            'Showing ${properties.length} properties in $categoryName',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),

        // Property cards
        ...properties.map((property) {
          return Column(
            children: [
              PropertyCard(
                propertyId: property['propertyId'] as String,
                mediaItems: [
                  {'image': property['imageUrl'] as String},
                ],
                title: property['title'] as String,
                location: property['location'] as String,
                description: property['description'] as String,
                priceRange: property['priceRange'] as String,
                tagText: property['tagText'] as String,
                rating: property['rating'] as double,
                distance: property['distance'] as String,
                isNew: property['isNew'] as bool,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailScreen(
                        propertyId: property['propertyId'] as String,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }
}
