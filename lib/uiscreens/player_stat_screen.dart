import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../datamodels/player_stats.dart';
import '../viewmodels/footcontroller.dart';

class PlayersStatScreen extends StatefulWidget {
  const PlayersStatScreen({super.key});

  @override
  State<PlayersStatScreen> createState() => _PlayersStatScreenState();
}

class _PlayersStatScreenState extends State<PlayersStatScreen> {
  FootballController? footballController;

  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    footballController?.fetchPlayerStats();
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
                      //         width: isTablet ? 40 : 30,
                      //         height: isTablet ? 40 : 30,
                      //         "images/back.svg",
                      //         color: Colors.white,
                      //       ),
                      //     )
                      // ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Player Statistics",
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
              Obx( ()=> Visibility(
                  visible: footballController!.showPlayerStats.value,
                  child:  Container(
                    margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                      color: Color(0xff00327a),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10,bottom:
                          20),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Image.network(
                                footballController!.statPlayerModel.value?.photo ??
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
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    footballController!.statPlayerModel.value?.name ?? "",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    footballController!.statPlayerModel.value?.nationality ?? "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Nationality",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    footballController!.statPlayerModel.value?.nationality ?? "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Age",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "${footballController!.statPlayerModel.value?.age}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Date of Birth",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    footballController!.statPlayerModel.value!.birth?.date != null ? DateFormat('MM/dd/yyyy').format(footballController!.statPlayerModel.value!.birth!.date!.add(const Duration(days: 2))) : "No Date Selected",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Height",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "${footballController!.statPlayerModel.value?.height  ?? '0'} cm" ?? "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Weight",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 20 : 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "${footballController!.statPlayerModel.value?.weight  ?? '0'} kg",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ))),
              Expanded(
                child: Obx(
                      () => Visibility(
                    visible: footballController!.showPlayerStats.value,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        Statistic? stats =
                        footballController!.playerStatstics?[index];
                        return Container(
                          margin: EdgeInsets.only(top: 10,left: 10,right: 10),
                          color: Color(0xff00327a),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10,bottom:
                                20),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Image.network(
                                      stats?.team?.logo ??
                                          "",
                                      height: 45.0,
                                      width: 45.0,
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
                                          height: 45.0,
                                          width: 45.0,
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
                                          height: 45.0,
                                          width: 45.0,
                                          "images/placeholder.png",
                                          fit: BoxFit.fill,
                                        );
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stats?.team?.name ?? "",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isTablet ? 20 : 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(
                                          stats?.league?.name  ?? "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 18 : 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Position",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      stats?.games?.position ?? "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Goals",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${stats?.goals?.total ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Passes",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${stats?.passes?.total ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rating",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      stats?.games?.rating ?? '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Shots",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${stats?.shots?.total ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Duels",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${stats?.duels?.total ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Dribbles",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${stats?.dribbles?.attempts ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                      itemCount: footballController!.playerStatstics.length,
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
                    visible: footballController!.showStatsProgress.value,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
          ),
          Obx(
                () => Center(
              child: Visibility(
                visible: footballController!.noPlayerStats.value,
                child: Text("No Player Statistics available to show.",
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