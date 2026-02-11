import 'package:flutter/material.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/homescreen/widgets/property.dart';

class FeaturedSitesSection extends StatelessWidget {
  const FeaturedSitesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Center(
            child: Text(
              'Top Picks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              PropertyCard(
                propertyId: 'prop_001',
                mediaItems: [
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-luxury-house-31415-480.mp4',
                  },
                ],
                title: 'Sky View Villas',
                location: 'Jubilee Hills, Hyderabad',
                description: 'Live Drone View Available',
                priceRange: '3.5 Cr – 5.2 Cr',
                tagText: 'Drone Tour',
                rating: 4.9,
                distance: '1.5 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_001'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Apartment complex aerial view
              PropertyCard(
                propertyId: 'prop_002',
                mediaItems: [
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-modern-city-1152-480.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=900&q=80',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Urban Sky Apartments',
                location: 'Financial District, Hyderabad',
                description: 'Aerial Drone Tour Included',
                priceRange: '2.8 Cr – 4.2 Cr',
                tagText: 'Premium\nDrone View',
                rating: 4.8,
                distance: '2.8 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_002'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Construction site progress
              PropertyCard(
                propertyId: 'prop_003',
                mediaItems: [
                  {
                    'video':
                        'https://cdn.pixabay.com/video/2023/04/12/161902-819765011_large.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Prestige High Fields',
                location: 'Gachibowli, Hyderabad',
                description: 'Construction Progress View',
                priceRange: '1.8 Cr – 2.5 Cr',
                tagText: 'Under Construction\nLive Progress',
                rating: 4.7,
                distance: '3.2 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_003'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Neighborhood aerial tour
              PropertyCard(
                propertyId: 'prop_004',
                mediaItems: [
                  {
                    'image':
                        'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?auto=format&fit=crop&w=900&q=80',
                  },
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-residential-neighborhood-1314-480.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Green Valley Community',
                location: 'Hitech City, Hyderabad',
                description: 'Neighborhood Drone Tour',
                priceRange: '2.2 Cr – 3.8 Cr',
                tagText: 'Area Tour\nAvailable',
                rating: 4.8,
                distance: '4.1 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_004'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Luxury penthouse tour
              PropertyCard(
                propertyId: 'prop_005',
                mediaItems: [
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-modern-building-31414-480.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Elite Penthouse Residences',
                location: 'Banjara Hills, Hyderabad',
                description: '360° Drone View',
                priceRange: '4.5 Cr – 6.8 Cr',
                tagText: 'Luxury\nPenthouse',
                rating: 5.0,
                distance: '2.5 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_005'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Mixed residential complex
              PropertyCard(
                propertyId: 'prop_006',
                mediaItems: [
                  {
                    'image':
                        'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?auto=format&fit=crop&w=900&q=80',
                  },
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-residential-area-31413-480.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1605146769289-440113cc3d00?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Royal Garden Estates',
                location: 'Kokapet, Hyderabad',
                description: 'Complete Property Tour',
                priceRange: '1.5 Cr – 2.2 Cr',
                tagText: 'Gated Community\nDrone View',
                rating: 4.6,
                distance: '5.3 km',
                isNew: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_006'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Commercial property
              PropertyCard(
                propertyId: 'prop_007',
                mediaItems: [
                  {
                    'video':
                        'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-a-commercial-building-31416-480.mp4',
                  },
                  {
                    'image':
                        'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=900&q=80',
                  },
                ],
                title: 'Tech Park Commercial',
                location: 'Raidurg, Hyderabad',
                description: 'Commercial Space Available',
                priceRange: '8.5 Cr – 12 Cr',
                tagText: 'Commercial\nDrone Tour',
                rating: 4.9,
                distance: '3.8 km',
                isNew: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(propertyId: 'prop_007'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
