// property_list_screen.dart
import 'package:flutter/material.dart';
import 'package:real_beez/PropertyListScreen/PropertyCardwidget.dart';
import 'package:real_beez/PropertyListScreen/PropertyDetailScreen.dart'
    show PropertyDetailScreen;
import 'package:real_beez/property_cards.dart'
    show PropertyData, Property, Address, PropertyImage;

class PropertyListScreen extends StatefulWidget {
  final String category;
  final String propertyType;

  const PropertyListScreen({
    super.key,
    required this.category,
    required this.propertyType,
  });

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  List<Map<String, dynamic>> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    // Get properties based on category and type
    final categoryData = PropertyData.featuredSitesData[widget.propertyType];

    if (categoryData != null) {
      // Find the specific category (like 2 BHK, 3 BHK, etc.)
      final titles = categoryData['titles'] as List<String>;
      final data = categoryData['data'] as List;

      int categoryIndex = 0;
      if (widget.category.contains('2'))
        categoryIndex = 0;
      else if (widget.category.contains('3'))
        categoryIndex = 1;
      else if (widget.category.contains('4'))
        categoryIndex = 2;
      else if (widget.category.contains('Small'))
        categoryIndex = 0;
      else if (widget.category.contains('Medium'))
        categoryIndex = 1;
      else if (widget.category.contains('Large'))
        categoryIndex = 2;

      if (categoryIndex < data.length) {
        final items = data[categoryIndex]['items'] as List;
        _filteredProperties = List<Map<String, dynamic>>.from(items);
      }
    }

    // Also add properties from the main properties list if they match the type
    for (var prop in PropertyData.properties) {
      if (prop['type'] == widget.propertyType) {
        _filteredProperties.add({
          'subtitle': prop['title'],
          'location': prop['address']['area'],
          'price': 'Price Range start from',
          'priceRange': '${(prop['price'] / 100000).toStringAsFixed(1)} Lakhs',
          'image': prop['images'][0]['image'],
          'isNew': prop['status'] == 'pre_launch',
          'property': Property(
            id: prop['id'],
            title: prop['title'],
            description: prop['description'],
            price: prop['price'],
            currency: prop['currency'],
            status: prop['status'],
            address: Address(
              street: prop['address']['locality'] ?? '',
              area: prop['address']['area'],
              city: prop['address']['city'],
              state: prop['address']['state'],
              pincode: '500000',
            ),
            images: [
              PropertyImage(url: prop['images'][0]['image'], isPrimary: true),
            ],
            features: [],
            amenities:
                prop['amenities']?.map<String>((a) => a.toString()).toList() ??
                [],
          ),
          'images': prop['images'],
          'videos': prop['videos'],
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} - ${widget.propertyType.replaceAll('_', ' ').toTitleCase()}',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _filteredProperties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredProperties.length,
              itemBuilder: (context, index) {
                final property = _filteredProperties[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PropertyCard(
                    propertyData: property,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailScreen(
                            property: property['property'] as Property,
                            images: property['images'] as List<dynamic>,
                            videos: property['videos'] as List<dynamic>,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(
      ' ',
    ).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
