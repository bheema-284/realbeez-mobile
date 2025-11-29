// main.dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Basic color palette extracted from the screenshot
  static const Color bgCream = Color(0xFFF5ECD9); // page background
  static const Color accentGold = Color(0xFFC7923A); // gold accents
  static const Color navDark = Color(0xFF2F2F2F); // bottom nav bg
  static const Color titleColor = Color(0xFF2B2B2B);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Services Mock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: bgCream,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: titleColor),
          bodyMedium: TextStyle(fontSize: 14.0, color: titleColor),
        ),
      ),
      home: PropertyServicesScreen(),
    );
  }
}

class PropertyServicesScreen extends StatelessWidget {
  const PropertyServicesScreen({super.key});

  static const double sideRailWidth = 84.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: _SearchBar()),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/logo/logo.png'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 100, // Give it a specific height
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        SizedBox(
                          width: sideRailWidth,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _railItem(
                                    icon: Icons.grid_view,
                                    label: 'All',
                                    iconBg: Colors.transparent,
                                    compactLabel: true,
                                  ),
                                  SizedBox(height: 12),
                                  _railItemWithTile('Rental &\nLease Solution'),
                                  SizedBox(height: 15),
                                  _railItemWithTile('Asset &\nWealth\nManagement'),
                                  SizedBox(height: 15),
                                  _railItemWithTile('Legal Due\nDiligence &\nValuation'),
                                  SizedBox(height: 15),
                                  _railItemWithTile('Consultancy &\nAdvisory\nServices'),
                                  SizedBox(height: 15),
                                  _railItemWithTile('Marketing Contracts\n& Deal\nStructuring'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    'Property Acquisitions & Sales',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  _VideoCard(),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(top: 6, left: 6),
                                    child: Text(
                                      'How its works?',
                                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  _FormSection(),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                      child: Center(
                        child: Container(
                          width: media.size.width * 0.56,
                          height: 52,
                          decoration: BoxDecoration(
                            color: MyApp.accentGold,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 6),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _railItem(
      {required IconData icon,
      required String label,
      Color iconBg = Colors.white,
      bool compactLabel = false}) {
    return Column(
      children: [
        Container(
          width: compactLabel ? 36 : 48,
          height: compactLabel ? 36 : 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(icon, size: compactLabel ? 18 : 22, color: Colors.black87),
        ),
        SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: compactLabel ? 12 : 11.5, color: Colors.black87),
        )
      ],
    );
  }

  Widget _railItemWithTile(String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Color(0xFFe5c78b), Color(0xFFcfa04a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(Icons.home, size: 26, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 68,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.0, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Search "Services"',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          Icon(Icons.mic_none, color: Colors.grey[700]),
        ],
      ),
    );
  }
}


class _VideoCard extends StatelessWidget {
  const _VideoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 120,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?w=1200&q=80&auto=format&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.play_arrow, size: 34, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  _FormSection();

  final List<String> labels = [
    'Rental Application Form',
    'Residential Lease Agreement Form',
    'Security Deposit Receipt / Acknowledgement',
    'Rent Payment Receipt',
    'Lease Renewal',
    'Landlord Notice Form',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: labels
          .map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15.0),
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Upload a Document',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                          child:
                              Icon(Icons.link, color: Colors.grey[700]),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// Removed internal bottom nav; parent app provides custom bottom bar.
