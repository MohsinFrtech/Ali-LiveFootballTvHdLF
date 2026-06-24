import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/datamodels/team.dart';
import 'package:get/get.dart';

import '../datamodels/leagues.dart';
import '../datamodels/venu_model.dart';
import '../routing/approutes.dart';
import '../viewmodels/footcontroller.dart';

class VenueMainClass extends StatefulWidget {
  const VenueMainClass({super.key});

  @override
  State<VenueMainClass> createState() => _VenueMainState();
}

class _VenueMainState extends State<VenueMainClass> {
  LeagueFootball? league;
  FootballController? footballController;

  @override
  void initState() {
    bool controllerCheck = Get.isRegistered<FootballController>();
    if (controllerCheck) {
      footballController = Get.find();
    } else {
      footballController = Get.put(FootballController());
    }

    footballController?.fetchAllVenuesFromRemote();
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
                    bottomRight: Radius.circular(0.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 0.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1, // First flexible space
                        child: Container(
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
                              // )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1, // First flexible space
                        child: Container(
                          child: const Padding(
                              padding: EdgeInsets.only(bottom: 20, top: 10),
                              child: Text(
                                "All Venues",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 1, // First flexible space
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Visibility(
                    visible: footballController!.showVenues.value,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemBuilder: (BuildContext context, int index) {
                        VenueClass venue =
                            footballController!.allVenuesList[index];
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
                              color: Colors.white,
                              child: Row(
                                children: [
                                  SizedBox(width: 5,),
                                  Image.network(
                                    "",
                                    height: 45.0,
                                    width: 45.0,
                                    loadingBuilder:
                                        (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
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
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            venue.name ?? "",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(venue.city ?? ""),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              AppConstants.venue_id = venue.id;
                              Get.toNamed(Routes.venuMatches);
                            },
                          ),
                        );
                      },

                      itemCount: footballController!.allVenuesList.length,
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
                  visible: footballController!.showVenueError.value,
                  child: const Text(
                    "Venues are not available to show.",
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
                visible: footballController!.venuProgress.value,
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
