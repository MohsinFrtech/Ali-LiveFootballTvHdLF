import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:get/get.dart';

import '../datamodels/football.dart';
import '../datamodels/sortedlist.dart';
import '../datamodels/teamplayers.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';

class TeamPlayersAndMatches extends StatefulWidget {
  const TeamPlayersAndMatches({super.key});

  @override
  State<TeamPlayersAndMatches> createState() => _TeamPlayersAndMatchesState();
}

class _TeamPlayersAndMatchesState extends State<TeamPlayersAndMatches> {

  int tabs = 2;
  FootballController? footballController;

  List<Tab> tabsList = [
    const Tab(text: "Players"),
    const Tab(text: "Matches"),
  ];

  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    footballController?.fetchTeamPlayers();
    footballController?.fetchTeamMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return WillPopScope(
        child: Scaffold(
          backgroundColor: Color(0xff0b3bbf),
          body: Stack(
            children: [
              Container(color: Color(0xff0b3bbf)),
              SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        clipBehavior: Clip.none, // allow shadow to draw outside

                        margin: const EdgeInsets.only(bottom: 0.3),
                        decoration: const BoxDecoration(
                          color: Color(0xff00327a),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              // shadow color
                              offset: Offset(0, 2),
                              // x=0, y=2 → shadow goes downwards
                              blurRadius: 10, // softness of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.only(top: 60.0, bottom: 20.0),
                          child: Row(
                            children: [

                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    height: isTablet ? 50 : 40,
                                    width: isTablet ? 50 : 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "images/back.svg",
                                        height: isTablet ? 20 : 16,
                                        width: isTablet ? 20 : 16,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Padding(
                              //     padding: const EdgeInsets.only(left: 10),
                              //     child: GestureDetector(
                              //       onTap: () {
                              //         Get.back();
                              //       },
                              //       child: SvgPicture.asset(
                              //         height: isTablet ? 40 : 30,
                              //         width: isTablet ? 40 : 30,
                              //         "images/back.svg",
                              //         color: Colors.white,
                              //       ),
                              //     )
                              // ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Team Detail",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 22 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              // same width as back button to balance
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: tabs,
                          child: NestedScrollView(
                            headerSliverBuilder: (context, isbool) {
                              return <Widget>[
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _SliverAppBarDelegate(
                                    TabBar(
                                      labelColor: Colors.white,
                                      labelStyle: TextStyle(
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                      unselectedLabelColor: Colors.black,
                                      indicator: const UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 5.0,
                                        ),
                                      ),
                                      tabs: tabsList,
                                    ),
                                  ),
                                ),
                              ];
                            },
                            body: TabBarView(
                              children: [
                                TeamPlayersClass(controller: footballController),
                                TeamMatchesClass(controller: footballController),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
        onWillPop: () {
          Get.back();
          return Future.value(false);
        });
  }
}

class TeamPlayersClass extends StatelessWidget {
  const TeamPlayersClass({super.key ,  required this.controller});

  final FootballController? controller;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Obx(
                    () => Visibility(
                  visible: controller!.showTeamPlayers.value,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemBuilder: (BuildContext context, int index) {
                      Player? player =
                      controller!.teamPlayers?[index];
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
                                  player?.photo ??
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
                                        player?.name ?? "",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isTablet ? 20 : 14,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        player?.position ?? "",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isTablet ? 20 : 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                SvgPicture.asset(
                                  height: isTablet ? 30 : 20,
                                  width: isTablet ? 30 : 20,
                                  "images/forward.svg",
                                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                )
                              ],
                            ),
                          ),
                          onTap:  (){
                            AppConstants.player_id = player?.id ?? 12;
                            Get.toNamed(Routes.playersStatScreen);
                          },
                        ),
                      );
                    },

                    itemCount: controller!.teamPlayers.length,
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
              visible: controller!.teamPlayersProgress.value,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
        Obx(
              () => Center(
            child: Visibility(
              visible: controller!.noTeamPlayers.value,
              child: Text("No Team Players available to show.",
                style: TextStyle(
                  color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  void navigateToPlayerStatScreen(FootballData footballMatch) {
    Get.toNamed(Routes.playersStatScreen);
  }
}


class TeamMatchesClass extends StatelessWidget {
  const TeamMatchesClass({super.key , required this.controller});

 final FootballController? controller;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Obx(
                    () => Visibility(
                  visible: controller!.showTeamMatches.value,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemBuilder: (BuildContext context, int index) {
                      SortedFootballClass match =
                      controller!.teamMatches[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 10.0,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff00327a),
                                  // Set the border radius on the container
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                width: screenSize.width,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 5.0,
                                        top: 5.0,
                                        bottom: 5.0,
                                      ),
                                      child: Image.network(
                                        match.league.logo?.toString() ?? "",
                                        height: isTablet ? 35 : 25,
                                        width: isTablet ? 35 : 25,
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
                                            height: isTablet ? 35 : 25,
                                            width: isTablet ? 35 : 25,
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
                                            height: isTablet ? 35 : 25,
                                            width: isTablet ? 35 : 25,
                                            "images/placeholder.png",
                                            fit: BoxFit.fill,
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      child: Text(
                                        match.league.name ?? "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 19 : 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.only(top: 10.0),
                                itemCount: match.matchesList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  FootballData footballMatch =
                                  match.matchesList[index];
                                  return InkWell(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 10.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            footballMatch.status?.long ?? "",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: isTablet ? 18 : 13
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            bottom: 15.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                footballMatch
                                                    .homeTeam
                                                    ?.logo ??
                                                    "",
                                                height: isTablet ? 35 : 25,
                                                width: isTablet ? 35 : 25,
                                                loadingBuilder:
                                                    (
                                                    BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                    loadingProgress,
                                                    ) {
                                                  if (loadingProgress ==
                                                      null) {
                                                    return child; // Return the child widget if loading is complete
                                                  }
                                                  return Image(
                                                    height: isTablet ? 35 : 25,
                                                    width: isTablet ? 35 : 25,
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
                                                    height: isTablet ? 35 : 25,
                                                    width: isTablet ? 35 : 25,
                                                    "images/placeholder.png",
                                                    fit: BoxFit.fill,
                                                  );
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 10.0,
                                                ),
                                                child: Text(
                                                  footballMatch.homeTeam
                                                      ?.name ??
                                                      "",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: isTablet ? 18 : 14,
                                                  ),
                                                ),
                                              ),
                                              Spacer(flex: 1),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 0.0,
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    right: 10.0,
                                                  ),
                                                  child: Text(
                                                    footballMatch.goals !=
                                                        null
                                                        ? footballMatch.goals
                                                        ?.home !=
                                                        null
                                                        ? footballMatch
                                                        .goals!
                                                        .home
                                                        .toString()
                                                        : ""
                                                        : "",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: isTablet ? 18 : 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                footballMatch
                                                    .awayTeam
                                                    ?.logo ??
                                                    "",
                                                height: isTablet ? 35 : 25,
                                                width: isTablet ? 35 : 25,
                                                loadingBuilder:
                                                    (
                                                    BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                    loadingProgress,
                                                    ) {
                                                  if (loadingProgress ==
                                                      null) {
                                                    return child; // Return the child widget if loading is complete
                                                  }
                                                  return Image(
                                                    height: isTablet ? 35 : 25,
                                                    width: isTablet ? 35 : 25,
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
                                                    height: isTablet ? 35 : 25,
                                                    width: isTablet ? 35 : 25,
                                                    "images/placeholder.png",
                                                    fit: BoxFit.fill,
                                                  );
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 10.0,
                                                ),
                                                child: Text(
                                                  footballMatch.awayTeam
                                                      ?.name ??
                                                      "",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: isTablet ? 18 : 14,
                                                  ),
                                                ),
                                              ),
                                              Spacer(flex: 1),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 0.0,
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    right: 10.0,
                                                  ),
                                                  child: Text(
                                                    footballMatch.goals !=
                                                        null
                                                        ? footballMatch.goals
                                                        ?.away !=
                                                        null
                                                        ? footballMatch
                                                        .goals!
                                                        .away
                                                        .toString()
                                                        : ""
                                                        : "",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: isTablet ? 18 : 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10.0,
                                            right: 10.0,
                                            bottom: 5.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Spacer(flex: 1),
                                              Text(
                                                footballMatch.venue?.name !=
                                                    null
                                                    ? footballMatch
                                                    .venue!
                                                    .name
                                                    .toString()
                                                    : match.league.round ??
                                                    "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isTablet ? 18 : 14,
                                                ),
                                              ),
                                              Spacer(flex: 1),
                                            ],
                                          ),
                                        ),
                                        index != match.matchesList.length - 1
                                            ? Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            left: 5.0,
                                            right: 5.0,
                                            bottom: 10.0,
                                          ),
                                          child: DottedLine(
                                            direction: Axis.horizontal,
                                            lineThickness: 1.0,
                                            dashLength: 8.0,
                                            dashGapLength: 5.0,
                                            dashColor: Colors.black,
                                          ),
                                        )
                                            : Container(),
                                      ],
                                    ),
                                    onTap: () {
                                      //particular match click....
                                      navigateToNextScreen(footballMatch);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },

                    itemCount: controller!.teamMatches.length,
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
              visible: controller!.teamMatchProgress.value,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void navigateToNextScreen(FootballData footballMatch) {
    Get.toNamed(Routes.footballMatchDetail,
        arguments: {"footballMatch": footballMatch});
  }

}



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return Container(
      color: const Color(0xff00327a), // Match your background color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

