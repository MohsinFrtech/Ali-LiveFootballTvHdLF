import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:footscore/admanager/addata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/routing/approutes.dart';
import 'package:get/get.dart';
import '../database/databasehelper.dart';
import '../datamodels/fav_event_class.dart';
import '../datamodels/streammodel.dart';
import '../viewmodels/streamcontroller.dart';

class LiveStreamingScreen extends StatefulWidget {
  const LiveStreamingScreen({super.key});

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  final StreamingApiController _streamingApiController = Get.find();
  final AdManager _adManager = AdManager();
  String middleProvider = "none";

  @override
  void initState() {
    if (_streamingApiController.initialized) {
      middleProvider = _streamingApiController
          .loadAdAtLocation(AppConstants.locationMiddle);
    }
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
          SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                      clipBehavior: Clip.none, // allow shadow to draw outside
                      margin: const EdgeInsets.only(bottom: 0.3),
                      decoration: const BoxDecoration(
                        color: Color(0xff00327a),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 0.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1, // First flexible space
                              child: Row(
                                children: [
                                  SizedBox(width: 15,),
                                  IconButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.favEvents);
                                    },
                                    icon:  Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 20, top: 10),
                                child: Text(
                                  "Live Streaming",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 22 : 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            Flexible(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                          onTap: () {
                                            ///show rewarded ad...
                                            _adManager.showRewardedAds(AppConstants.rewardedLocationProvider,
                                                    (value) {
                                                  if (value.toLowerCase() ==
                                                      "finish") {
                                                    AppConstants.rewardGrant.value = false;
                                                  }
                                                }, AppConstants.rewardedLocation);

                                          },
                                          child: Obx(() => Visibility(
                                              visible: AppConstants.rewardGrant.value,
                                              child: SvgPicture.asset(
                                                height: isTablet ? 40 : 30,
                                                width: isTablet ? 40 : 30,
                                                "images/coffee_ic.svg",
                                                color: Colors.white,
                                              )), )

                                      ),
                                    ),
                                    Padding(
                                      padding:  const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          ///
                                          _streamingApiController.onRefreshLiveEvents();
                                        },
                                        child: Icon(Icons.refresh_sharp,
                                          size: isTablet ? 40 : 30,
                                          color: Colors.white,),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Obx(() => Visibility(
                      visible: _streamingApiController.isLiveEvents.value,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: isTablet ? 260 : 210,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          EventStreaming event = _streamingApiController.finalEventList[index];

                          return GestureDetector(
                            onTap: () {
                              if (AppConstants.adLoadStatus.toLowerCase() !=
                                    "none") {
                                  if (AppConstants.adLoadStatus
                                      .toLowerCase() ==
                                      "loaded") {
                                    _adManager.checkAdLoadedOrNot(
                                            (value) {
                                          if (value.toLowerCase() == "finish") {
                                            navigateToChannelScreen(event);
                                          }
                                        }, middleProvider,"");
                                  } else {
                                    navigateToChannelScreen(event);
                                  }
                                } else {
                                  navigateToChannelScreen(event);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0,
                                  bottom: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                color: Color(0xff00327a),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.all(1.0),
                                            height: isTablet ? 190 : 140,
                                            width: screenSize.width,
                                            child: Image.network(
                                              fit: BoxFit.fill,
                                              event.image_url.toString(),
                                              loadingBuilder:
                                                  (BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                  loadingProgress) {
                                                if (loadingProgress ==
                                                    null) {
                                                  return child; // Return the child widget if loading is complete
                                                }
                                                return const Image(
                                                    fit: BoxFit.fill,
                                                    image: AssetImage(
                                                        "images/placeholder.png")); // Return a loading indicator while the image is being loaded
                                              },
                                              errorBuilder: (_,
                                                  Object exception,
                                                  StackTrace? stackTrace) {
                                                return Image.asset(
                                                  "images/placeholder.png",
                                                  fit: BoxFit.fill,
                                                );
                                              },
                                            )),
                                        SizedBox(
                                          width: screenSize.width,
                                          height: 50.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                                            child: Text(
                                              event.name ?? "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isTablet ? 18 : 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Obx(()=> Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        onPressed: () {
                                          _streamingApiController!.finalEventList[index].isFavourite?.toggle();
                                          if(_streamingApiController!.finalEventList[index].isFavourite==true) {
                                            saveFavoriteLeague(
                                                event?.priority ?? 0, event?.priority ?? 0, event?.name ?? "Test Event"
                                            );
                                          }else{
                                            deleteFavoriteLeague(
                                                event?.priority ?? 0, event?.priority ?? 0, event?.name ?? "Test Event");
                                          }
                                        },
                                        icon: Icon(
                                          _streamingApiController!.finalEventList[index].isFavourite == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),)
                                  ],
                                )
                              ),
                            ),
                          );
                        },
                        itemCount: _streamingApiController.finalEventList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    )),
                  ),
                  Obx(() => Visibility(
                      visible:
                      _streamingApiController.isAppLive.value == false ? true : false,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: Text(
                            "Live Streaming Channels are not available.",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )))
                ],
              )),
          Obx(() => Center(
            child: Visibility(
              visible: _streamingApiController.isLoadingEvents.value,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )),
          // Obx(
          //       () => Visibility(
          //     visible: _streamingApiController.showSplashConfig.value ?? false,
          //     child: Container(
          //       color: Color(0xff6dbd58),
          //       width: screenSize.width,
          //       height: screenSize.height,
          //       child: Stack(
          //         children: [
          //           Padding(
          //             padding: EdgeInsets.only(top: 40),
          //             child: Stack(
          //               children: [
          //                 Padding(
          //                     padding: EdgeInsets.only(top: 30, bottom: 50),
          //                     child: Align(
          //                       alignment: Alignment.topCenter,
          //                       child: Text(
          //                         _streamingApiController.appConfiguration.title.toString() ?? "",
          //                         style: TextStyle(
          //                             color: Colors.black,
          //                             fontSize: 20,
          //                             fontWeight: FontWeight.bold),
          //                       ),
          //                     )),
          //                 Padding(
          //                     padding: EdgeInsets.only(top: 100, bottom: 50),
          //                     child: Align(
          //                       alignment: Alignment.topCenter,
          //                       child: Text(
          //                         _streamingApiController.appConfiguration.heading.toString() ?? "",
          //                         style: TextStyle(
          //                             color: Colors.black,
          //                             fontSize: 20),
          //                       ),
          //                     )),
          //                 Visibility(
          //                   visible: _streamingApiController.appConfiguration.showButton == true
          //                       ? true
          //                       : false,
          //                   child: Align(
          //                     alignment: Alignment.bottomCenter,
          //                     child: Padding(
          //                       padding: const EdgeInsets.only(
          //                         bottom: 50,
          //                       ),
          //                       child: ElevatedButton(
          //                         style: ElevatedButton.styleFrom(
          //                           foregroundColor: Colors.white,
          //                           backgroundColor: Colors.green.shade900, // foreground
          //                         ),
          //                         onPressed: () async {
          //                           if (_streamingApiController.appConfiguration.button_link != null) {
          //                             Uri googleUrl = Uri.parse(
          //                                 _streamingApiController.appConfiguration.button_link);
          //                             _launchInBrowserView(googleUrl);
          //                           }
          //                         },
          //                         child: Text(_streamingApiController.appConfiguration.button_heading
          //                             .toString() ??
          //                             ""),
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> saveFavoriteLeague(int? id, int? code, String? eventName) async {
    if (id == null || code == null || eventName == null) {
      print("Error: One or more fields are null");
      return;
    }
    try {
      final database = await DatabaseHelper.instance.database;
      final favoriteLeague = FavouriteEvent(
        id!,
        code!,
        eventName!,
      );

      await database.eventDao.insertFavouriteLeague(favoriteLeague);
    } catch (e) {
      print("Database Error: $e");
    }

  }

  Future<void> deleteFavoriteLeague(int? id, int? code, String? eventName) async {

    if (id == null || code == null || eventName == null) {
      print("Error: One or more fields are null");
      return;
    }
    try {
      final database = await DatabaseHelper.instance.database;
      await database.eventDao.deleteFavouriteEvent(eventName!, code!);
    } catch (e) {
      print("Database Error: $e");
    }

  }

  void navigateToChannelScreen(EventStreaming event) {

    event.channels?.forEach((element) {
      element.sSelected?.value=false;
    });
    Get.toNamed(Routes.innerchannels,
        arguments: {"selectedEvent": event})?.then((value) =>
        _streamingApiController.loadAdAtLocation(AppConstants.locationMiddle)
    );

  }

}
