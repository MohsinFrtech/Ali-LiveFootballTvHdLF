import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../datamodels/leagues.dart';
import '../viewmodels/footcontroller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FavouriteLeagueScreen extends StatefulWidget {
  const FavouriteLeagueScreen({super.key});

  @override
  State<FavouriteLeagueScreen> createState() => _FavouriteLeagueScreenState();
}

class _FavouriteLeagueScreenState extends State<FavouriteLeagueScreen> {
  final FootballController controller = Get.put<FootballController>(FootballController());

  RxList<LeagueFootball> favouriteLeagues = <LeagueFootball>[].obs;

  @override
  void initState() {
    super.initState();
    favouriteLeagues.length;
    print("Favourite Leagues Length: ${favouriteLeagues.length}");
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xff0b3bbf),

      appBar: AppBar(
        backgroundColor: const Color(0xff00327a),
        iconTheme: const IconThemeData(
          color: Colors.white, // back button color
        ),
        title: Text(
          "Favourite Leagues",
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.favouriteLeagues.isEmpty) {
          return const Center(
            child: Text(
              "No Favourite League Found",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        }

      //  print("Favourite Leagues: ${controller.favouirteLeagues.length}");
        return ListView.builder(
          itemCount: controller.favouriteLeagues.length,
          itemBuilder: (context, index) {
            final league = controller.favouriteLeagues[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: ListTile(
                leading: Image.network(
                  league.logo ?? "",
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      "images/placeholder.png",
                      width: 40,
                      height: 40,
                    );
                  },
                ),
                title: Text(
                  league.name ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  league.country ?? "",
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    controller.toggleFavouriteLeague(league);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}