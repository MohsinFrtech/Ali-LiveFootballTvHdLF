import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/datamodels/football.dart';
import 'package:get/get.dart';

import '../admanager/addata.dart';
import '../codeutils/appconstants.dart';
import '../viewmodels/streamcontroller.dart';

class FootballMatchDetail extends StatefulWidget {
  const FootballMatchDetail({super.key});

  @override
  State<FootballMatchDetail> createState() => _FootballMatchDetailState();
}

class _FootballMatchDetailState extends State<FootballMatchDetail> {
  FootballData? matchData;
  final StreamingApiController apiController = Get.find();
  final AdManager _adManager = AdManager();
  String afterProvider = "none";

  @override
  void initState() {
    if (apiController.initialized) {
      afterProvider = apiController.loadAdAtLocation(
        AppConstants.locationAfter,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    var arguments = Get.arguments;
    var selectedMatch = arguments['footballMatch'];
    matchData = selectedMatch;

    return WillPopScope(
      child: Scaffold(
        body: Column(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (AppConstants.adLoadStatus.toLowerCase() != "none") {
                            if (AppConstants.adLoadStatus.toLowerCase() == "loaded") {
                              _adManager.checkAdLoadedOrNot((value) {
                                if (value.toLowerCase() == "finish") {
                                  Get.back();
                                }
                              }, afterProvider,"");
                            } else {
                              Get.back();
                            }
                          } else {
                            Get.back();
                          }
                        },
                        child: SvgPicture.asset(
                          height: isTablet ? 40 : 30,
                          width: isTablet ? 40 : 30,
                          "images/back.svg",
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          matchData?.league?.name.toString() ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 22 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              clipBehavior: Clip.none, // allow shadow to draw outside
              margin: const EdgeInsets.only(bottom: 0.3),
              decoration: const BoxDecoration(
                color:  Color(0xff0b3bbf),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            matchData?.homeTeam?.logo ?? "",
                            height: isTablet ? 60 : 50,
                            width: isTablet ? 60 : 50,
                            loadingBuilder:
                                (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child; // Return the child widget if loading is complete
                                  }
                                  return Image(
                                    height: isTablet ? 60 : 50,
                                    width: isTablet ? 60 : 50,
                                    image: const AssetImage("images/placeholder.png"),
                                  ); // Return a loading indicator while the image is being loaded
                                },
                            errorBuilder:
                                (_, Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    height: isTablet ? 60 : 50,
                                    width: isTablet ? 60 : 50,
                                    "images/placeholder.png",
                                    fit: BoxFit.fill,
                                  );
                                },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              left: 10.0,
                            ),
                            child: Text(
                              matchData?.homeTeam?.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchData?.goals != null
                                ? matchData?.goals?.home != null
                                      ? matchData!.goals!.home.toString()
                                      : ""
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            matchData?.goals != null
                                ? matchData?.goals?.away != null
                                      ? matchData!.goals!.away.toString()
                                      : ""
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            matchData?.awayTeam?.logo ?? "",
                            height: isTablet ? 60 : 50,
                            width: isTablet ? 60 : 50,
                            loadingBuilder:
                                (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child; // Return the child widget if loading is complete
                                  }
                                  return Image(
                                    height: isTablet ? 60 : 50,
                                    width: isTablet ? 60 : 50,
                                    image: const AssetImage("images/placeholder.png"),
                                  ); // Return a loading indicator while the image is being loaded
                                },
                            errorBuilder:
                                (_, Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    height: isTablet ? 60 : 50,
                                    width: isTablet ? 60 : 50,
                                    "images/placeholder.png",
                                    fit: BoxFit.fill,
                                  );
                                },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              right: 10.0,
                            ),
                            child: Text(
                              matchData?.awayTeam?.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "MATCH STATS",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 10.0,
                    left: 10.0,
                  ),
                  child: Text(
                    "First Half",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          matchData?.homeTeam?.name ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                      ),
                      Image.network(
                        matchData!.homeTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff00327a),
                      // Set the border radius on the container
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.halftime?.home != null
                                      ? matchData!.score!.halftime!.home
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.halftime?.away != null
                                      ? matchData!.score!.halftime!.away
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        matchData!.awayTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height:isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            matchData?.awayTeam?.name ?? "",
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 10.0,
                    left: 10.0,
                  ),
                  child: Text(
                    "Full Time",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          matchData?.homeTeam?.name ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                      ),
                      Image.network(
                        matchData!.homeTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff00327a),
                      // Set the border radius on the container
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.fulltime?.home != null
                                      ? matchData!.score!.fulltime!.home
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.fulltime?.away != null
                                      ? matchData!.score!.fulltime!.away
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        matchData!.awayTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            matchData?.awayTeam?.name ?? "",
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 10.0,
                    left: 10.0,
                  ),
                  child: Text(
                    "Extra Time",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          matchData?.homeTeam?.name ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                      ),
                      Image.network(
                        matchData!.homeTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff00327a),
                      // Set the border radius on the container
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.extratime?.home != null
                                      ? matchData!.score!.extratime!.home
                                            .toString()
                                      : "0"
                                : "0",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.extratime?.away != null
                                      ? matchData!.score!.extratime!.away
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        matchData!.awayTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            matchData?.awayTeam?.name ?? "",
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 10.0,
                    left: 10.0,
                  ),
                  child: Text(
                    "Penalty",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          matchData?.homeTeam?.name ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                      ),
                      Image.network(
                        matchData!.homeTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff00327a),
                      // Set the border radius on the container
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.penalty?.home != null
                                      ? matchData!.score!.extratime!.home
                                            .toString()
                                      : "0"
                                : "0",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            "-",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                          Text(
                            matchData?.score != null
                                ? matchData?.score?.penalty?.away != null
                                      ? matchData!.score!.extratime!.away
                                            .toString()
                                      : "0"
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 22 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        matchData!.awayTeam?.logo ?? "",
                        height: isTablet ? 40 : 30,
                        width: isTablet ? 40 : 30,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the child widget if loading is complete
                              }
                              return Image(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                image: const AssetImage("images/placeholder.png"),
                              ); // Return a loading indicator while the image is being loaded
                            },
                        errorBuilder:
                            (_, Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                height: isTablet ? 40 : 30,
                                width: isTablet ? 40 : 30,
                                "images/placeholder.png",
                                fit: BoxFit.fill,
                              );
                            },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            matchData?.awayTeam?.name ?? "",
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onWillPop: () {
        if (AppConstants.adLoadStatus.toLowerCase() != "none") {
          if (AppConstants.adLoadStatus.toLowerCase() == "loaded") {
            _adManager.checkAdLoadedOrNot((value) {
              if (value.toLowerCase() == "finish") {
                Get.back();
              }
            }, afterProvider,"");
          } else {
            Get.back();
          }
        } else {
          Get.back();
        }
        return Future.value(false);
      },
    );
  }
}
