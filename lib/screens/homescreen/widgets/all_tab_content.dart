import 'package:flutter/material.dart';
import 'package:real_beez/screens/cutsom_widgets/swipe_cards.dart' hide PropertyCard;

class AllTabContent extends StatelessWidget {
  const AllTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PropertyDeckSection();
  }
}