import 'dart:math';

import 'package:flutter/material.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/models/property.dart';
import 'package:real_beez/screens/repositories/property_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

void main() {
  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate Search - Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFF061021),
        fontFamily: 'Roboto',
      ),
      home: const RealEstateHome(),
    );
  }
}

class RealEstateHome extends StatefulWidget {
  const RealEstateHome({super.key});

  @override
  State<RealEstateHome> createState() => _RealEstateHomeState();
}

class _RealEstateHomeState extends State<RealEstateHome> {
  // For carousel
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _activePage = 0;

  // For search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<MapSearchResult> _searchResults = [];
  String _currentAddress = 'Madhapur, Hyderabad, TG';
  LatLng? _currentLocation;

  // For loading state
  bool _isLoadingLocation = false;

  // Map controller and state
  MapController _mapController = MapController();
  double _currentZoom = 13.5;

  // Track selected pin location
  LatLng? _selectedPinLocation;
  String? _selectedPinTitle;

  // Property repository for loading data
  final PropertyRepository _propertyRepository = PropertyRepository();
  List<Property> _properties = [];
  bool _isLoading = true;

  // Convert properties to _Listing format
  List<_Listing> get _listings {
    return _properties.map((property) {
      final address = property.address;

      return _Listing(
        id: property.id.toString(),
        title: property.title,
        subtitle: '${address.area}, ${address.city}',
        position: LatLng(address.latitude, address.longitude),
        isNew:
            property.status == 'pre_launch' ||
            property.status == 'under_construction',
        property: property,
        price: property.price.toDouble(),
        type: property.type,
      );
    }).toList();
  }

  // Calculate distance between two coordinates in km
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // km

    double lat1 = pos1.latitude * (3.141592653589793 / 180);
    double lon1 = pos1.longitude * (3.141592653589793 / 180);
    double lat2 = pos2.latitude * (3.141592653589793 / 180);
    double lon2 = pos2.longitude * (3.141592653589793 / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Get listings filtered by proximity to selected pin
  List<_Listing> get _filteredListings {
    // If a pin is selected, filter by proximity only
    if (_selectedPinLocation != null) {
      return _listings.where((listing) {
        double distance = _calculateDistance(
          _selectedPinLocation!,
          listing.position,
        );
        return distance <= 2.0; // 2km radius
      }).toList();
    }

    // If no pin selected, show all
    return _listings;
  }

  void _navigateToHomeScreen(_Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PropertyDetailScreen(propertyId: listing.id.toString()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_activePage != next) {
        setState(() => _activePage = next);
      }
    });
    _loadProperties();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await _propertyRepository.loadProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading properties: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      _currentLocation = LatLng(17.4474, 78.3919);
      final address = await _reverseGeocode(_currentLocation!);

      setState(() {
        _currentAddress = address;
      });

      _mapController.move(
        latlong.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        12,
      );
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<String> _reverseGeocode(LatLng latLng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};

        final String? city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['suburb'] ??
            'Unknown Location';

        final String? state = address['state'] ?? '';

        return '$city${(state?.isNotEmpty ?? false) ? ', $state' : ''}';
      }
    } catch (e) {
      print('Reverse geocode error: $e');
    }

    return 'Unknown Location';
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeQueryComponent(query)}&limit=10&countrycodes=in',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) {
            return MapSearchResult(
              displayName: item['display_name'],
              lat: double.parse(item['lat']),
              lon: double.parse(item['lon']),
              type: item['type'] ?? 'unknown',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLocationSelected(MapSearchResult result) {
    setState(() {
      _currentAddress = _truncateDisplayName(result.displayName);
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
      _selectedPinLocation = null;
    });

    final selectedLatLng = latlong.LatLng(result.lat, result.lon);
    _mapController.move(selectedLatLng, 12);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location updated to: ${result.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPinSelected(_Listing listing) {
    setState(() {
      _selectedPinLocation = listing.position;
      _selectedPinTitle = listing.title;
    });

    final latLng = latlong.LatLng(
      listing.position.latitude,
      listing.position.longitude,
    );

    _mapController.move(latLng, 15);

    if (_filteredListings.isNotEmpty) {
      _pageController.jumpToPage(0);
      setState(() {
        _activePage = 0;
      });
    }

    final nearbyCount = _filteredListings.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $nearbyCount properties near ${listing.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearPinSelection() {
    setState(() {
      _selectedPinLocation = null;
      _selectedPinTitle = null;
    });

    if (_currentLocation != null) {
      _mapController.move(
        latlong.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        12,
      );
    }
  }

  String _getDistanceText(_Listing listing) {
    if (_selectedPinLocation != null) {
      double distance = _calculateDistance(
        _selectedPinLocation!,
        listing.position,
      );
      return '${distance.toStringAsFixed(1)} km away';
    }
    return 'View on map';
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: Colors.black54, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for location or property...',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: _searchLocation,
                    onTap: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ),
                if (!_isSearching)
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD98B),
                        shape: BoxShape.circle,
                      ),
                      child: _isLoadingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Colors.black,
                              size: 22,
                            ),
                    ),
                  ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!_isSearching)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedPinTitle != null
                            ? 'Near $_selectedPinTitle'
                            : _currentAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_selectedPinLocation != null)
                  GestureDetector(
                    onTap: _clearPinSelection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching || _searchController.text.isEmpty) {
      return const SizedBox();
    }

    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2530),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search results for "${_searchController.text}"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_searchResults.length} found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading && _searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, color: Colors.white54, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'No locations found',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD98B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getLocationIcon(result.type),
                          color: const Color(0xFFFFD98B),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        _truncateDisplayName(result.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${result.type} • ${result.lat.toStringAsFixed(4)}, ${result.lon.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                      onTap: () => _onLocationSelected(result),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _truncateDisplayName(String fullName) {
    List<String> parts = fullName.split(',');
    if (parts.length > 3) {
      return '${parts[0]}, ${parts[1]}, ${parts[2]}';
    }
    return fullName;
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'city':
      case 'town':
        return Icons.location_city;
      case 'village':
        return Icons.house;
      case 'suburb':
        return Icons.domain;
      case 'road':
      case 'street':
        return Icons.aod;
      case 'commercial':
      case 'industrial':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildMapBackground() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentLocation != null
            ? latlong.LatLng(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
              )
            : latlong.LatLng(17.4474, 78.3919),
        zoom: _currentZoom,
        maxZoom: 18,
        minZoom: 10,
        interactiveFlags:
            InteractiveFlag.pinchZoom |
            InteractiveFlag.drag |
            InteractiveFlag.doubleTapZoom,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            setState(() {
              _currentZoom = position.zoom!;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.example.real_beez',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: _buildMapMarkers()),
      ],
    );
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    for (final listing in _listings) {
      bool isSelected =
          _selectedPinLocation != null &&
          listing.position.latitude == _selectedPinLocation!.latitude &&
          listing.position.longitude == _selectedPinLocation!.longitude;

      Color markerColor;
      if (listing.property?.type == 'villa') {
        markerColor = isSelected ? Colors.yellow : Colors.green;
      } else if (listing.property?.type == 'apartment') {
        markerColor = isSelected ? Colors.yellow : Colors.blue;
      } else {
        markerColor = isSelected ? Colors.yellow : Colors.orange;
      }

      markers.add(
        Marker(
          point: latlong.LatLng(
            listing.position.latitude,
            listing.position.longitude,
          ),
          width: isSelected ? 50 : 35,
          height: isSelected ? 50 : 35,
          child: GestureDetector(
            onTap: () => _onPinSelected(listing),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow.withOpacity(0.2),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(isSelected ? 6 : 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.location_on : Icons.location_pin,
                    color: markerColor,
                    size: isSelected ? 22 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildListingCard(int index, bool active) {
    final listing = _filteredListings[index];

    // Format price
    final priceInLakhs = (listing.price / 100000).toStringAsFixed(1);
    final priceInCrores = listing.price >= 10000000
        ? (listing.price / 10000000).toStringAsFixed(1)
        : '0.8'; // Default value

    return GestureDetector(
      onTap: () => _navigateToHomeScreen(listing),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: active ? 5 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: active
              ? Border.all(color: const Color(0xFFFFD98B), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - Fixed height
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: _getPropertyImage(listing),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Discount badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '10% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Property type badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        listing.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details section - Fixed height with padding
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 10,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDistanceText(listing),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Address
                  Text(
                    listing.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Range',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹$priceInLakhs L - ₹$priceInCrores Cr',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD98B), Color(0xFFFFB74D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD98B).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getPropertyImage(_Listing listing) {
    // Try to get the first image from property
    if (listing.property?.images != null &&
        listing.property!.images.isNotEmpty) {
      final firstImageUrl = listing.property!.images.first.url;
      // Check if it's a network URL or local asset
      if (firstImageUrl.startsWith('http')) {
        return NetworkImage(firstImageUrl);
      } else if (firstImageUrl.startsWith('assets/')) {
        return AssetImage(firstImageUrl);
      } else {
        // Try to load as asset with proper path
        return AssetImage('assets/$firstImageUrl');
      }
    }

    // Return a placeholder
    return AssetImage('assets/images/property_placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    final statusBarPadding = MediaQuery.of(context).padding.top;
    final bottomCardHeight = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF061021),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD98B),
                  ),
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(child: _buildMapBackground()),
                  Column(
                    children: [
                      SizedBox(height: statusBarPadding),
                      _buildTopBar(),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Stack(
                          children: [
                            // Status info
                            if (_selectedPinLocation != null)
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.yellow,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_filteredListings.length} properties nearby',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Tap instruction
                            if (_selectedPinLocation == null &&
                                _listings.isNotEmpty)
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          color: Colors.yellow,
                                          size: 12,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Tap pin to see nearby',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!_isSearching && _filteredListings.isNotEmpty)
                        SizedBox(
                          height: bottomCardHeight,
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _selectedPinLocation != null
                                    ? 'Properties near this location'
                                    : 'All Properties',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _filteredListings.length,
                                  physics: const BouncingScrollPhysics(),
                                  onPageChanged: (index) {
                                    setState(() {
                                      _activePage = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final active = index == _activePage;
                                    return _buildListingCard(index, active);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  _buildSearchResults(),
                ],
              ),
      ),
    );
  }
}

class _Listing {
  final String id;
  final String title;
  final String subtitle;
  final LatLng position;
  final bool isNew;
  final Property? property;
  final double price;
  final String type;

  const _Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    this.isNew = false,
    this.property,
    required this.price,
    required this.type,
  });
}

class MapSearchResult {
  final String displayName;
  final double lat;
  final double lon;
  final String type;

  MapSearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
