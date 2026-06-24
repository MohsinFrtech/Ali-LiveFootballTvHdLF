import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/datamodels/team.dart';
import 'package:get/get.dart';

import '../datamodels/leagues.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';

class LeagueTeams extends StatefulWidget {
  const LeagueTeams({super.key});

  @override
  State<LeagueTeams> createState() => _LeagueTeamsState();
}

class _LeagueTeamsState extends State<LeagueTeams> {
  LeagueFootball? league;
  FootballController? footballController;

  @override
  void initState() {
    var arguments = Get.arguments;
    var selectedLeague = arguments['selectedLeague'];
    if (selectedLeague != null) {
      league = selectedLeague;
    }
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    footballController?.fetchTeamsFromRemote();
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
                      //         height: isTablet ? 40 : 30,
                      //         width: isTablet ? 40 : 30,
                      //         "images/back.svg",
                      //         colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      //       ),
                      //     )
                      // ),
                      Expanded(child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            league?.name.toString() ?? "",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold),
                          ))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  "Teams",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                      () => Visibility(
                    visible: footballController!.showTeams.value,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        TeamData teamData =
                        footballController!.leagueTeamsList[index];
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
                                    teamData.team?.logo ??
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
                                          teamData.team?.name ?? "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: isTablet ? 18 : 13,
                                              fontWeight: FontWeight.bold
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
                              AppConstants.team_id = teamData.team?.id ?? 12;
                              //League click....
                              Get.toNamed(Routes.teamMatchesAndPlayers);
                            },
                          ),
                        );
                      },
                      itemCount: footballController!.leagueTeamsList.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
                () =>
                Center(
                  child: Visibility(
                    visible: footballController!.teamProgress.value,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
          ),
          Obx(
                () => Center(
              child: Visibility(
                visible: footballController!.noTeams.value,
                child: Text("Teams not available to show.",
                    style: TextStyle(
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
