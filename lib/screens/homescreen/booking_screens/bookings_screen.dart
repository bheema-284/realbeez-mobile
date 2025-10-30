import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedTab = "Completed";

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> completedList = List.generate(5, (index) {
      return {
        "title": "SMR Holdings",
        "subtitle": "3BHK",
        "bookingId": "asdfg123456",
        "distance": "350m away",
        "image": "assets/images/unlock1.png", // This is a local asset
      };
    });

    final List<Map<String, String>> cancelledList = [
      {
        "title": "SMR Holdings",
        "subtitle": "3BHK",
        "bookingId": "asdfg123456",
        "distance": "350m away",
        "cancelledBy": "Cancelled by Customer",
        "image": "assets/images/unlock1.png", // This is a local asset
      },
      {
        "title": "SMR Holdings",
        "subtitle": "2BHK",
        "bookingId": "qwert123456",
        "distance": "500m away",
        "cancelledBy": "Cancelled by Driver",
        "image": "assets/images/unlock2.png", // This is a local asset
      },
    ];

    final List<Map<String, String>> upcomingList = [
      {
        "title": "GreenVille Residency",
        "subtitle": "2BHK",
        "bookingId": "zxcvb123456",
        "distance": "200m away",
        "image": "assets/images/unlock1.png", // This is a local asset
      },
      {
        "title": "Lakeview Apartments",
        "subtitle": "3BHK",
        "bookingId": "poiuy987654",
        "distance": "1km away",
        "image": "assets/images/unlock2.png", // This is a local asset
      },
    ];

    List<Map<String, String>> currentList;
    if (selectedTab == "Completed") {
      currentList = completedList;
    } else if (selectedTab == "Cancelled") {
      currentList = cancelledList;
    } else {
      currentList = upcomingList;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EAD9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTabButton("Completed"),
                    _buildTabButton("Cancelled"),
                    _buildTabButton("Upcoming"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Showing ${currentList.length} Results",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final data = currentList[index];
                    return BookingCard(
                      title: data["title"]!,
                      subtitle: data["subtitle"]!,
                      bookingId: data["bookingId"]!,
                      distance: data["distance"]!,
                      imageUrl: data["image"]!,
                      cancelledBy: selectedTab == "Cancelled"
                          ? data["cancelledBy"]
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final bool isSelected = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE9B654) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8E8E8E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String bookingId;
  final String distance;
  final String imageUrl;
  final String? cancelledBy;

  const BookingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bookingId,
    required this.distance,
    required this.imageUrl,
    this.cancelledBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED: Use Image.asset for local assets instead of Image.network
          ClipOval(
            child: Image.asset(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (cancelledBy != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8BBD0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cancelledBy!,
                          style: const TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Booking ID: $bookingId",
                  style: const TextStyle(
                    color: Color(0xFF948A77),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.navigation,
                      size: 14,
                      color: Color(0xFFE9B654),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance, // Use the dynamic distance value
                      style: const TextStyle(
                        color: Color(0xFFE9B654),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9B654),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
