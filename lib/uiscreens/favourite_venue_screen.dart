import 'package:flutter/material.dart';

class FavouriteVenuesScreen extends StatelessWidget {
  FavouriteVenuesScreen({super.key});

  // final SportsController controller =
  // Get.find<SportsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Venues"),
        backgroundColor: const Color(0xff046008),
      ),
      // body: Obx(() {
      //   final venues = controller.favouriteVenues;
      //
      //   if (venues.isEmpty) {
      //     return const Center(
      //       child: Text(
      //         "No favourite venues found",
      //         style: TextStyle(
      //           fontSize: 18,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //     );
      //   }
      //
      //   return ListView.builder(
      //     itemCount: venues.length,
      //     itemBuilder: (context, index) {
      //       final venue = venues[index];
      //
      //       return Card(
      //         margin: const EdgeInsets.symmetric(
      //           horizontal: 12,
      //           vertical: 6,
      //         ),
      //         child: ListTile(
      //           leading: const Icon(
      //             Icons.stadium,
      //             color: Color(0xff046008),
      //           ),
      //           title: Text(venue.name ?? ""),
      //           subtitle: Text(venue.city ?? ""),
      //           trailing: IconButton(
      //             icon: const Icon(
      //               Icons.favorite,
      //               color: Colors.red,
      //             ),
      //             onPressed: () {
      //               controller.toggleFavouriteVenue(
      //                 venue.id ?? 0,
      //               );
      //             },
      //           ),
      //           onTap: () {
      //             SportsAppConstants.venue_id =
      //                 venue.id;
      //
      //             Get.toNamed(
      //               AllRoutes.venuMatches,
      //             );
      //           },
      //         ),
      //       );
      //     },
      //   );
      // }),
    );
  }
}