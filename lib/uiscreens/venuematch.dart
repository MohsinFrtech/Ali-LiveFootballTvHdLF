import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../datamodels/football.dart';
import '../datamodels/sortedlist.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';

class VenueMatchesList extends StatefulWidget {
  const VenueMatchesList({super.key});

  @override
  State<VenueMatchesList> createState() => _VenueMatchesListState();
}

class _VenueMatchesListState extends State<VenueMatchesList> {
  FootballController? footballController;

  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    footballController?.fetchVenuMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Color(0xff0b3bbf),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                decoration: const BoxDecoration(
                  color: Color(0xff00327a),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
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
                      //         "images/back.svg",
                      //         colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      //       ),
                      //     )
                      // ),
                      Expanded(child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "Venu Matches",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Visibility(
                    visible: footballController!.showVenuMatches.value,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        SortedFootballClass match =
                            footballController!.seasonMatches[index];
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
                                          height: 25.0,
                                          width: 25.0,
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
                                                return const Image(
                                                  height: 25.0,
                                                  width: 25.0,
                                                  image: AssetImage(
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
                                                  height: 25.0,
                                                  width: 25.0,
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
                                            fontSize: 13.0,
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
                                                  height: 25.0,
                                                  width: 25.0,
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
                                                        return const Image(
                                                          height: 25.0,
                                                          width: 25.0,
                                                          image: AssetImage(
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
                                                          height: 25.0,
                                                          width: 25.0,
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
                                                      fontSize: 14.0,
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
                                                        fontSize: 14.0,
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
                                                  height: 25.0,
                                                  width: 25.0,
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
                                                        return const Image(
                                                          height: 25.0,
                                                          width: 25.0,
                                                          image: AssetImage(
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
                                                          height: 25.0,
                                                          width: 25.0,
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
                                                      fontSize: 14.0,
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
                                                        fontSize: 14.0,
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
                                                    fontSize: 14.0,
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

                      itemCount: footballController!.seasonMatches.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() =>
              Center(
                child: Visibility(
                  visible: footballController!.showVenueMatchesError.value,
                  child: const Text(
                    "Venues matches are not available to show.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              )),
          Obx(
            () => Center(
              child: Visibility(
                visible: footballController!.venuMatchProgress.value,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToNextScreen(FootballData footballMatch) {
    Get.toNamed(Routes.footballMatchDetail,
        arguments: {"footballMatch": footballMatch});
  }
}
