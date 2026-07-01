import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../admanager/addata.dart';
import '../codeutils/appconstants.dart';
import '../database/databasehelper.dart';
import '../datamodels/football.dart';
import '../datamodels/streammodel.dart';
import '../routing/approutes.dart';
import '../viewmodels/streamcontroller.dart';
class FavouriteEvents extends StatefulWidget {
  const FavouriteEvents({super.key});

  @override
  State<FavouriteEvents> createState() => _FavouriteEventsState();
}

class _FavouriteEventsState extends State<FavouriteEvents> {
  RxList<EventStreaming> favoriteEvents = RxList();
  RxBool showEvents = RxBool(false);
  RxBool showError = RxBool(false);
  final StreamingApiController streamingContrller = Get.find();
  final AdManager _adController = AdManager();
  String middleLocationProvider = "none";

  @override
  void initState() {
    if (streamingContrller.initialized) {
      middleLocationProvider = streamingContrller
          .loadAdAtLocation(AppConstants.locationMiddle);
    }
    getAllFavoriteLeagues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff0b3bbf),
            ),
          ),
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xff00327a),
                  // borderRadius: BorderRadius.only(
                  //     bottomLeft: Radius.circular(40.0),
                  //     bottomRight: Radius.circular(40.0)
                  // ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 0.0),
                  child: Row(
                    children: [
                      Flexible(
                          flex: 1,
                          child: Row(
                            children: [
                              // Padding(
                              //     padding: const EdgeInsets.only(left: 10),
                              //     child: GestureDetector(
                              //       onTap: () {
                              //         Get.back();
                              //       },
                              //       child: SvgPicture.asset(
                              //         "images/back.svg",
                              //         color: Colors.white,
                              //       ),
                              //     )
                              // ),
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
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          child: Text(
                            "All Favourite Streaming",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 24 : 18,
                                fontWeight: FontWeight.bold),
                          )),
                      const Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [],
                          )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Obx(() => Visibility(
                    visible: showEvents.value,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: isTablet ? 260 : 210,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        EventStreaming event = favoriteEvents[index];

                        return GestureDetector(
                          onTap: () {
                            if (AppConstants.adLoadStatus.toLowerCase() !=
                                "none") {
                              if (AppConstants.adLoadStatus
                                  .toLowerCase() ==
                                  "loaded") {
                                _adController.checkAdLoadedOrNot(
                                        (value) {
                                      if (value.toLowerCase() == "finish") {
                                        navigateToChannelScreen(event);
                                      }
                                    }, middleLocationProvider,"");
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
                                  ],
                                )
                            ),
                          ),
                        );
                      },
                      itemCount: favoriteEvents.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  )),
                ),
              ),
            ],
          ),
          Obx(()=>
              Visibility(
                  visible: showError.value,
                  child: const Center(
                    child: Text(
                      "No favorite streaming available to show.",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                  ))
          )
        ],
      ),
    );
  }
  Widget safeNetworkImage(String? url) {
    // 1. Handle Null or Empty
    if (url == null || url.isEmpty) {
      return Image.asset("images/placeholder.png", fit: BoxFit.fill);
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return Image.asset("images/placeholder.png", fit: BoxFit.fill);
    }

    return Image.network(
      url,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset("images/placeholder.png", fit: BoxFit.fill);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Image.asset("images/placeholder.png", fit: BoxFit.fill);
      },
    );
  }

  void navigateToChannelScreen(EventStreaming event) {

    event.channels?.forEach((element) {
      element.sSelected?.value=false;
    });
    Get.toNamed(Routes.innerchannels,
        arguments: {"selectedEvent": event})?.then((value) =>
        streamingContrller.loadAdAtLocation(AppConstants.locationMiddle)
    );

  }



  Future<void> getAllFavoriteLeagues() async {
    favoriteEvents?.clear();
    if (streamingContrller?.finalEventList != null) {
      if (streamingContrller!.finalEventList!.isNotEmpty) {
        var liveEventsList = streamingContrller!.finalEventList;
        final database = await DatabaseHelper.instance.database;
        database.eventDao.getAllFavouriteEvents().then((value) {
          final favoriteKeys = value.map((fav) {
            final code = fav.eventCode ?? 0;
            final name = fav.eventName ?? "none";
            return "${code}_$name";
          }).toSet();

          List<EventStreaming> resultingList = liveEventsList.where((liveEvent) {
            final liveCode = liveEvent.priority ?? 0;
            final liveName = liveEvent.name ?? "none";
            final liveKey = "${liveCode}_$liveName";

            return favoriteKeys.contains(liveKey);
          }).toList();
          favoriteEvents.value = resultingList;
          if(favoriteEvents.isEmpty){
            showError.value = true;
          }
          else{
            showError.value = false;
          }
          showEvents.value = true;
        });



      }else{
        favoriteEvents.value = [];
        showEvents.value = false;
        showError.value = true;
      }
    } else {
      favoriteEvents.value = [];
      showEvents.value = false;
      showError.value = true;
    }
  }
}
