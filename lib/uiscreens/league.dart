import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admanager/addata.dart';
import '../codeutils/appconstants.dart';
import '../database/databasehelper.dart';
import '../datamodels/favourite_league_class.dart';
import '../datamodels/leagues.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';
import '../viewmodels/streamcontroller.dart';

class AllLeagueList extends StatefulWidget {
  const AllLeagueList({super.key});

  @override
  State<AllLeagueList> createState() => _AllLeagueListState();
}

class _AllLeagueListState extends State<AllLeagueList> {
  FootballController? footballController;
  String beforeProvider = "none";
  final StreamingApiController apiController = Get.find();
  final AdManager _adManager = AdManager();
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    if (apiController.initialized) {
      beforeProvider = apiController.loadAdAtLocation(AppConstants.locationBefore);
    }
    footballController?.fetchLeaguesFromRemote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Color(0xff0b3bbf),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                clipBehavior: Clip.none, // allow shadow to draw outside
                margin: const EdgeInsets.only(bottom: 0.3),
                decoration: const BoxDecoration(
                  color: Color(0xff00327a),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        "Leagues",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white, // Input text color
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      fontSize: isTablet ? 20 : 15,
                      color: Colors.white,
                    ),
                    hintText: "Enter text...",
                    // The border shown when the field is NOT selected
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    // The border shown when the field IS selected
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    // Background color (optional)
                    filled: true,
                    fillColor: Color(0xff00327a),
                  ),
                  onChanged: (value) {
                    searchLeagues(value);
                  },
                ),
              ),
              Expanded(
                child: Obx(
                  () => Visibility(
                    visible: footballController!.showLeagues.value,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        LeagueFootball league =
                            footballController!.footballLeaguesList[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                            bottom: 10.0,
                          ),
                          child: GestureDetector(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color:Colors.white,
                              child: Row(
                                children: [
                                  Image.network(
                                    league.logo?.toString() ??
                                        "",
                                    height: isTablet ? 55 : 45,
                                    width: isTablet ? 55 : 45,
                                    loadingBuilder:
                                        (
                                        BuildContext context,
                                        Widget child,
                                        ImageChunkEvent?
                                        loadingProgress,
                                        ) {
                                      if (loadingProgress == null) {
                                        return child; // Return the child widget if loading is complete
                                      }
                                      return Image(
                                        height: isTablet ? 55 : 45,
                                        width: isTablet ? 55 : 45,
                                        image: const AssetImage(
                                          "images/placeholder.png",
                                        ),
                                      ); // Return a loading indicator while the image is being loaded
                                    },
                                    errorBuilder:
                                        (
                                        _,
                                        Object exception,
                                        StackTrace? stackTrace,
                                        ) {
                                      return Image.asset(
                                        height: isTablet ? 55 : 45,
                                        width: isTablet ? 55 : 45,
                                        "images/placeholder.png",
                                        fit: BoxFit.fill,
                                      );
                                    },
                                  ),
                                  Expanded(child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          league.name ?? "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: isTablet ? 19 : 13,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(league.country ?? "",
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                  // Obx(() => IconButton(
                                  //   onPressed: () {
                                  //     footballController!.footballLeaguesList[index].isFavourite?.toggle();
                                  //     if(footballController!.footballLeaguesList[index].isFavourite==true) {
                                  //       saveFavoriteLeague(
                                  //           league.id,league.name, league.id,league.country.toString(),league?.logo.toString() ?? "");
                                  //     }else{
                                  //       deleteFavoriteLeague(
                                  //           league.id,league.name, league.id,league..country.toString(),league?.logo.toString() ?? "");
                                  //     }
                                  //   },
                                  //   icon: Icon(
                                  //     footballController!.footballLeaguesList[index].isFavourite==true
                                  //         ? Icons.favorite        // filled
                                  //         : Icons.favorite_border, // outline
                                  //     color: Color(0xff2C4E80),
                                  //     size: 25,
                                  //   ),
                                  // )),
                                  // Obx(() {
                                  //   final isFav = footballController!
                                  //       .isFavouriteLeague(league.leagueId ?? 0);
                                  //   return IconButton(
                                  //     onPressed: () {
                                  //       footballController!.toggleFavouriteLeague(league);
                                  //     },
                                  //     icon: Icon(
                                  //       isFav ? Icons.favorite : Icons.favorite_border,
                                  //       color: isFav ? Colors.red : Colors.grey,
                                  //     ),
                                  //   );
                                  // }),
                                  // Obx(
                                  //   child: IconButton(
                                  //     onPressed: () {
                                  //       footballController!.toggleFavouriteLeague(league);
                                  //     },
                                  //     icon: Icon(
                                  //       footballController!.isFavouriteLeague(league.leagueId ?? 0)
                                  //           ? Icons.favorite
                                  //           : Icons.favorite_border,
                                  //       color: footballController!.isFavouriteLeague(league.leagueId ?? 0)
                                  //           ? Colors.red
                                  //           : Colors.grey,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            onTap:  (){
                              AppConstants.league_id = league.leagueId ?? 01;
                              //League click....


                              if (AppConstants.adLoadStatus.toLowerCase() !=
                                  "none") {
                                if (AppConstants.adLoadStatus
                                    .toLowerCase() ==
                                    "loaded") {
                                  _adManager.checkAdLoadedOrNot(
                                          (value) {
                                        if (value.toLowerCase() == "finish") {
                                          navigateToNextScreen(league);
                                        }
                                      }, beforeProvider,"");
                                } else {
                                  navigateToNextScreen(league);
                                }
                              } else {
                                navigateToNextScreen(league);
                              }
                            },
                          ),
                        );
                      },

                      itemCount: footballController!.footballLeaguesList.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Center(
              child: Visibility(
                visible: footballController!.leagueProgress.value,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void searchLeagues(String query) {
    if (query.isEmpty) {
      footballController?.footballLeaguesList.assignAll(footballController!.allLeagues);
    } else {
      footballController?.footballLeaguesList.assignAll(
        footballController!.allLeagues.where((league) =>
            league.name!.toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
    }
  }

  void navigateToNextScreen(LeagueFootball league) {
    Get.toNamed(Routes.leagueTeam,
        arguments: {"selectedLeague": league})?.then((value) =>
        apiController.loadAdAtLocation(AppConstants.locationBefore)
    );
  }

  // Future<void> saveFavoriteLeague(int? id, String? name, int? id2, season, String s) async {
  //   final database = await DatabaseHelper.instance.database;
  //   final favoriteLeague = FavouriteLeague(
  //       id!,
  //       name!,
  //       id2!,
  //       season.toString(),
  //       s
  //   );
  //
  //   await database.leagueDao.insertFavouriteLeague(favoriteLeague);
  // }
  //
  // Future<void> deleteFavoriteLeague(int? id, String? name, int? id2, season, String s) async {
  //   final database = await DatabaseHelper.instance.database;
  //   final favoriteLeague = FavouriteLeague(
  //       id!,
  //       name!,
  //       id2!,
  //       season.toString(),
  //       s
  //   );
  //   await database.leagueDao.deleteFavouriteLeague(favoriteLeague);
  // }


}
