import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:footscore/codeutils/apidata.dart';
import 'package:footscore/codeutils/appconstants.dart';
import 'package:footscore/datamodels/sortedlist.dart';
import 'package:footscore/datamodels/team.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../datamodels/football.dart';
import '../datamodels/leagues.dart';
import '../datamodels/player_stats.dart' hide League;
import '../datamodels/teamplayers.dart';
import '../datamodels/venu_model.dart';

class FootballController extends GetxController {
  final Dio _dio = Dio();
  RxBool liveFootballCall = RxBool(true);
  RxBool showFootballMatches = RxBool(false);
  RxBool showFootballError = RxBool(false);

  RxString showSelectedDate = RxString("");
  RxBool upcomingProgress = RxBool(true);
  RxBool showUpcomingMatches = RxBool(false);

  RxBool leagueProgress = RxBool(true);
  RxBool showLeagues = RxBool(true);

  RxBool teamProgress = RxBool(true);
  RxBool showTeams = RxBool(false);
  RxBool noTeams = RxBool(false);


  RxBool showVenueError = RxBool(false);
  RxBool showVenueMatchesError = RxBool(false);

  final RxList<SortedFootballClass> sortedListWithLeague =
      RxList<SortedFootballClass>();
  final RxList<SortedFootballClass> upcomingListLeague =
      RxList<SortedFootballClass>();

  final RxList<LeagueFootball> footballLeaguesList = RxList<LeagueFootball>();
  List<LeagueFootball> allLeagues = [];

  final RxList<TeamData> leagueTeamsList = RxList<TeamData>();

  final RxList<SortedFootballClass> teamMatches = RxList<SortedFootballClass>();

  RxBool teamMatchProgress = RxBool(true);
  RxBool showTeamMatches = RxBool(false);

  RxBool venuProgress = RxBool(true);
  RxBool showVenues = RxBool(false);

  final RxList<VenueClass> allVenuesList = RxList<VenueClass>();

  RxBool venuMatchProgress = RxBool(true);
  RxBool showVenuMatches = RxBool(false);
  final RxList<SortedFootballClass> seasonMatches =
      RxList<SortedFootballClass>();

  RxBool teamPlayersProgress = RxBool(true);
  RxBool showTeamPlayers = RxBool(false);
  RxBool noTeamPlayers = RxBool(false);

  final RxList<Player> teamPlayers = RxList<Player>();


  RxBool showStatsProgress = RxBool(false);
  RxBool showPlayerStats = RxBool(false);
  RxBool noPlayerStats = RxBool(false);
  final RxList<TeamPlayerStat> playerAllStats = RxList<TeamPlayerStat>();
  Rxn<StatPlayer> statPlayerModel = Rxn<StatPlayer>();
  final RxList<Statistic> playerStatstics = RxList<Statistic>();


  @override
  void onInit() {
    DateTime now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    fetchFootballDataWithDate(formattedDate, now);
    super.onInit();
  }

  void changeDataAccordingToDate(String newDate, DateTime value) {
    liveFootballCall.value = true;
    showFootballMatches.value = false;
    fetchFootballDataWithDate(newDate, value);
  }

  ///fetch teams.....
  Future<void> fetchTeamsFromRemote() async {
    try {
      teamProgress.value = true;
      showTeams.value = false;
      var data = {
        "token": ApiData.footballApiToken,
        "league_id": AppConstants.league_id,
        "season": 2025,
      };
      var responseTeams = await _dio.post(
        "${ApiData.footballApiUrl}teams/all",
        data: data,
      );

      if (responseTeams.statusCode == HttpStatus.ok &&
          responseTeams.data != null &&
          !responseTeams.data.isEmpty) {
        List<TeamData> footballTeams = [];

        footballTeams.assignAll(
          (responseTeams.data as List).map((e) {
            var data = TeamData.fromMap(e);
            return data;
          }).toList(),
        );

        if (footballTeams.isNotEmpty) {
          showTeams.value = true;
          leagueTeamsList.value = footballTeams;
          noTeams.value = false;
        } else {
          showTeams.value = false;
           noTeams.value = true;
        }

        teamProgress.value = false;
      } else {
        teamProgress.value = false;
        showTeams.value = false;
        noTeams.value = true;
      }
    } on DioException catch (e) {
      teamProgress.value = false;
      showTeams.value = false;
      noTeams.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  //fetch venues....
  Future<void> fetchAllVenuesFromRemote() async {
    try {
      venuProgress.value = true;
      showVenues.value = false;
      var data = {"token": ApiData.footballApiToken};
      var responseVenues = await _dio.post(
        "${ApiData.footballApiUrl}venues/all",
        data: data,
      );

      if (responseVenues.statusCode == HttpStatus.ok &&
          responseVenues.data != null &&
          !responseVenues.data.isEmpty) {
        List<VenueClass> venues = [];

        venues.assignAll(
          (responseVenues.data as List).map((e) {
            var data = VenueClass.fromJson(e);
            return data;
          }).toList(),
        );

        if (venues.isNotEmpty) {
          showVenues.value = true;
          allVenuesList.value = venues;
          showVenueError.value = false;
        } else {
          showVenues.value = false;
          showVenueError.value = true;
        }

        venuProgress.value = false;
      } else {
        venuProgress.value = false;
        showVenues.value = false;
        showVenueError.value = true;
      }
    } on DioException catch (e) {
      venuProgress.value = false;
      showVenues.value = false;
      showVenueError.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  ///fetch leagues.....
  Future<void> fetchLeaguesFromRemote() async {
    try {
      var data = {"token": ApiData.footballApiToken};
      var responseLeague = await _dio.post(
        "${ApiData.footballApiUrl}leagues/all",
        data: data,
      );

      if (responseLeague.statusCode == HttpStatus.ok &&
          responseLeague.data != null &&
          !responseLeague.data.isEmpty) {
        List<LeagueFootball> footballLeagues = [];

        footballLeagues.assignAll(
          (responseLeague.data as List).map((e) {
            var data = LeagueFootball.fromMap(e);
            return data;
          }).toList(),
        );

        if (footballLeagues.isNotEmpty) {
          showLeagues.value = true;
          footballLeaguesList.value = footballLeagues;
          allLeagues = List.from(footballLeagues);
         
        } else {
          showLeagues.value = false;
        }
        leagueProgress.value = false;
      } else {
        leagueProgress.value = false;
        showLeagues.value = false;
      }
    } on DioException catch (e) {
      leagueProgress.value = false;
      showLeagues.value = false;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  ///fetch team matches.....
  Future<void> fetchTeamMatches() async {
    try {
      teamMatchProgress.value = true;
      showTeamMatches.value = false;
      var data = {"token": ApiData.footballApiToken};
      var responseTeamMatches = await _dio.post(
        "${ApiData.footballApiUrl}teams/${AppConstants.team_id}/matches",
        data: data,
      );

      if (responseTeamMatches.statusCode == HttpStatus.ok &&
          responseTeamMatches.data != null &&
          !responseTeamMatches.data.isEmpty) {
        List<FootballData> footballTeamMatches = [];

        footballTeamMatches.assignAll(
          (responseTeamMatches.data as List).map((e) {
            var data = FootballData.fromMap(e);
            return data;
          }).toList(),
        );

        if (footballTeamMatches.isNotEmpty) {
          sortTeamMatchesList(footballTeamMatches);
        } else {
          showTeamMatches.value = false;
        }

        teamMatchProgress.value = false;
      } else {
        teamMatchProgress.value = false;
        showTeamMatches.value = false;
      }
    } on DioException catch (e) {
      teamMatchProgress.value = false;
      showTeamMatches.value = false;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  ///fetch Players Stats.....
  Future<void> fetchPlayerStats() async {
    try {

      showStatsProgress.value = true;
      showPlayerStats.value = false;
      noPlayerStats.value = false;
      var data = {
        "token": ApiData.footballApiToken,
        "player_id": AppConstants.player_id,
        "season": 2025,
      };
      var responsePlayerStats = await _dio.post(
        "${ApiData.footballApiUrl}statistics/player",
        data: data,
      );

      if (responsePlayerStats.statusCode == HttpStatus.ok &&
          responsePlayerStats.data != null &&
          !responsePlayerStats.data.isEmpty) {
        List<TeamPlayerStat> playerStats = [];

        playerStats.assignAll(
          (responsePlayerStats.data as List).map((e) {
            var data = TeamPlayerStat.fromMap(e);
            return data;
          }).toList(),
        );

        if (playerStats.isNotEmpty) {
          statPlayerModel.value = playerStats[0].player;

          playerAllStats.value = playerStats;
          if(playerStats[0].statistics!=null){
            if(playerStats[0].statistics!.isNotEmpty){
              playerStatstics.value = playerStats[0].statistics!;
            }
          }
          showPlayerStats.value = true;
          noPlayerStats.value = false;
        } else {
          noPlayerStats.value = true;
          showPlayerStats.value = false;
        }

      } else {
        showPlayerStats.value = false;
        noPlayerStats.value = true;
      }

      showStatsProgress.value = false;
    } on DioException catch (e) {
      showStatsProgress.value = false;
      showPlayerStats.value = false;
      noPlayerStats.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  ///fetch venue matches.....
  Future<void> fetchVenuMatches() async {
    try {
      venuMatchProgress.value = true;
      showVenuMatches.value = false;
      showVenueMatchesError.value = false;

      var data = {"token": ApiData.footballApiToken};
      var responseVenueMatches = await _dio.post(
        "${ApiData.footballApiUrl}venues/${AppConstants.venue_id}/matches",
        data: data,
      );

      if (responseVenueMatches.statusCode == HttpStatus.ok &&
          responseVenueMatches.data != null &&
          !responseVenueMatches.data.isEmpty) {
        List<FootballData> footballVenueMatches = [];

        footballVenueMatches.assignAll(
          (responseVenueMatches.data as List).map((e) {
            var data = FootballData.fromMap(e);
            return data;
          }).toList(),
        );

        if (footballVenueMatches.isNotEmpty) {
          showVenueMatchesError.value = false;
          sortVenueMatchesList(footballVenueMatches);
        } else {
          showVenuMatches.value = false;
          showVenueMatchesError.value = true;
        }

        venuMatchProgress.value = false;
      } else {
        venuMatchProgress.value = false;
        showVenuMatches.value = false;
        showVenueMatchesError.value = true;
      }
    } on DioException catch (e) {
      venuMatchProgress.value = false;
      showVenuMatches.value = false;
      showVenueMatchesError.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  ///team Players.....
  Future<void> fetchTeamPlayers() async {
    try {
      showTeamPlayers.value = false;
      noTeamPlayers.value = false;
      teamPlayersProgress.value = true;
      var data = {"token": ApiData.footballApiToken};
      var responseTeamPlayers = await _dio.post(
        "${ApiData.footballApiUrl}teams/${AppConstants.team_id}/players",
        data: data,
      );

      if (responseTeamPlayers.statusCode == HttpStatus.ok &&
          responseTeamPlayers.data != null &&
          !responseTeamPlayers.data.isEmpty) {
        List<Teamplayers> footballTeamPlayers = [];

        footballTeamPlayers.assignAll(
          (responseTeamPlayers.data as List).map((e) {
            var data = Teamplayers.fromMap(e);
            return data;
          }).toList(),
        );

        if (footballTeamPlayers.isNotEmpty) {
          debugPrint("API resultssss: ${footballTeamPlayers[0].players?.length}");
          if(footballTeamPlayers[0].players!=null){
            if(footballTeamPlayers[0].players!.isNotEmpty){

              teamPlayers.value = footballTeamPlayers[0].players!;
              showTeamPlayers.value = true;
              noTeamPlayers.value = false;
            } else {
              showTeamPlayers.value = false;
              noTeamPlayers.value = true;
            }
          } else {
            showTeamPlayers.value = false;
            noTeamPlayers.value = true;
          }

        } else {
          showTeamPlayers.value = false;
          noTeamPlayers.value = true;
        }
      } else {
        showTeamPlayers.value = false;
        noTeamPlayers.value = true;
      }
      teamPlayersProgress.value = false;
    } on DioException catch (e) {
      showTeamPlayers.value = false;
      teamPlayersProgress.value = false;
      noTeamPlayers.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  Future<void> fetchFootballDataWithDate(
    String selectedDate,
    DateTime value,
  ) async {
    try {
      showSelectedDateInMonth(value);

      var data = {"token": ApiData.footballApiToken, "date": selectedDate};
      var response = await _dio.post(
        "${ApiData.footballApiUrl}matches/by_date",
        data: data,
      );

      if (response.statusCode == HttpStatus.ok &&
          response.data != null &&
          !response.data.isEmpty) {
        List<FootballData> footballMatchesList = [];

        footballMatchesList.assignAll(
          (response.data as List).map((e) {
            var data = FootballData.fromMap(e);
            return data;
          }).toList(),
        );
        /////////
        sortListWithLeague(footballMatchesList);

        if (kDebugMode) {
          print("API results: ${footballMatchesList.length}");
        }

        //////////////
        if (footballMatchesList.isNotEmpty) {
          showFootballMatches.value = true;
        }
        liveFootballCall.value = false;
      } else {
        showFootballError.value = true;
        showFootballMatches.value = false;
        liveFootballCall.value = false;
      }
    } on DioException catch (e) {
      showFootballError.value = true;
      showFootballMatches.value = false;
      liveFootballCall.value = false;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    } catch (e) {
      showFootballError.value = true;
      liveFootballCall.value = false;
      showFootballMatches.value = false;
    }
  }

  void liveMatchApiCall() {
    liveFootballCall.value = true;
    showFootballMatches.value = false;
    fetchFootballLiveMatches();
  }

  void upcomingMatches() {
    fetchFootballUpcomingMatches();
  }

  //Upcoming football matches....
  Future<void> fetchFootballUpcomingMatches() async {
    try {
      var data = {"token": ApiData.footballApiToken};
      var response = await _dio.post(
        "${ApiData.footballApiUrl}matches/upcoming",
        data: data,
      );

      if (response.statusCode == HttpStatus.ok &&
          response.data != null &&
          !response.data.isEmpty) {
        List<FootballData> upcomingFootballMatchesList = [];

        upcomingFootballMatchesList.assignAll(
          (response.data as List).map((e) {
            var data = FootballData.fromMap(e);
            return data;
          }).toList(),
        );

        if (upcomingFootballMatchesList.isNotEmpty) {
          sortUpcomingList(upcomingFootballMatchesList);
        } else {
          showUpcomingMatches.value = false;
        }
        upcomingProgress.value = false;
      } else {
        upcomingProgress.value = false;
        showUpcomingMatches.value = false;
      }
    } on DioException catch (e) {
      upcomingProgress.value = false;
      showUpcomingMatches.value = false;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    }
  }

  Future<void> fetchFootballLiveMatches() async {
    try {
      showSelectedDate.value = "Live Matches";
      var data = {"token": ApiData.footballApiToken};
      var response = await _dio.post(
        "${ApiData.footballApiUrl}matches/live",
        data: data,
      );

      if (response.statusCode == HttpStatus.ok &&
          response.data != null &&
          !response.data.isEmpty) {
        List<FootballData> footballMatchesList = [];

        footballMatchesList.assignAll(
          (response.data as List).map((e) {
            var data = FootballData.fromMap(e);
            return data;
          }).toList(),
        );
        /////////
        sortListWithLeague(footballMatchesList);

        if (kDebugMode) {
          print("API results: ${footballMatchesList.length}");
        }

        //////////////
        if (footballMatchesList.isNotEmpty) {
          showFootballMatches.value = true;
        }
        liveFootballCall.value = false;
      } else {
        showFootballError.value = true;
        showFootballMatches.value = false;
        liveFootballCall.value = false;
      }
    } on DioException catch (e) {
      showFootballMatches.value = false;
      liveFootballCall.value = false;
      showFootballError.value = true;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
      } else if (e.type == DioExceptionType.connectionError &&
          e.error is SocketException) {
      } else {
        debugPrint("Unhandled Dio error: ${e.message}");
      }
    } catch (e) {
      showFootballError.value = true;
      liveFootballCall.value = false;
      showFootballMatches.value = false;
    }
  }

  void sortUpcomingList(List<FootballData> footballMatchesList) {
    if (footballMatchesList.isNotEmpty) {
      List<String> list = [];
      footballMatchesList.forEach((it) {
        list.add(it.league?.name ?? '');
      });

      final listUpcoming = list.toSet().toList();
      final List<SortedFootballClass> finalUpcomingList = [];
      listUpcoming.forEach((valueDistinct) {
        League? valueB;
        final List<FootballData> upcomingMatchList = [];
        footballMatchesList.forEach((b) {
          final name = b.league?.name ?? '';

          if (valueDistinct == name) {
            valueB = b.league;
            upcomingMatchList.add(b);
          }
        });
        if (valueB != null) {
          finalUpcomingList.add(
            SortedFootballClass(valueB!, upcomingMatchList),
          );
        }
      });
      showUpcomingMatches.value = true;
      upcomingListLeague.value = finalUpcomingList;
    } else {
      showUpcomingMatches.value = false;
      showUpcomingMatches.value = false;
    }
  }

  void sortListWithLeague(List<FootballData> footballMatchesList) {
    if (footballMatchesList.isNotEmpty) {
      showFootballError.value = false;
      List<String> list = [];
      footballMatchesList.forEach((it) {
        list.add(it.league?.name ?? '');
      });

      // Use a Set to get the distinct league names.
      final distinctList = list.toSet().toList();
      final List<SortedFootballClass> listdetail = [];
      distinctList.forEach((valueDistinct) {
        League? valueB;
        final List<FootballData> updsedList = [];
        footballMatchesList.forEach((b) {
          final name = b.league?.name ?? '';

          if (valueDistinct == name) {
            valueB = b.league;
            updsedList.add(b);
          }
        });
        if (valueB != null) {
          listdetail.add(SortedFootballClass(valueB!, updsedList));
        }
      });
      sortedListWithLeague.value = listdetail;
    } else {
      showFootballError.value = true;
    }
  }

  void sortTeamMatchesList(List<FootballData> footballMatchesList) {
    if (footballMatchesList.isNotEmpty) {
      List<String> list = [];
      footballMatchesList.forEach((it) {
        list.add(it.league?.name ?? '');
      });

      final listTeams = list.toSet().toList();
      final List<SortedFootballClass> finalTeamList = [];
      listTeams.forEach((valueDistinct) {
        League? valueB;
        final List<FootballData> teamMatchList = [];
        footballMatchesList.forEach((b) {
          final name = b.league?.name ?? '';

          if (valueDistinct == name) {
            valueB = b.league;
            teamMatchList.add(b);
          }
        });
        if (valueB != null) {
          finalTeamList.add(SortedFootballClass(valueB!, teamMatchList));
        }
      });
      showTeamMatches.value = true;
      teamMatches.value = finalTeamList;
    } else {
      teamMatchProgress.value = false;
      showTeamMatches.value = false;
    }
  }

  ///sort matches list......
  void sortVenueMatchesList(List<FootballData> footballMatchesList) {
    if (footballMatchesList.isNotEmpty) {
      List<String> list = [];
      footballMatchesList.forEach((it) {
        list.add(it.league?.name ?? '');
      });

      final listVenuMatches = list.toSet().toList();
      final List<SortedFootballClass> finalTeamList = [];
      listVenuMatches.forEach((valueDistinct) {
        League? valueB;
        final List<FootballData> venueMatchList = [];
        footballMatchesList.forEach((b) {
          final name = b.league?.name ?? '';

          if (valueDistinct == name) {
            valueB = b.league;
            venueMatchList.add(b);
          }
        });
        if (valueB != null) {
          finalTeamList.add(SortedFootballClass(valueB!, venueMatchList));
        }
      });
      showVenuMatches.value = true;
      seasonMatches.value = finalTeamList;
    } else {
      venuMatchProgress.value = false;
      showVenuMatches.value = false;
    }
  }

  void showSelectedDateInMonth(DateTime selectedDate) {
    final dayDateFormatter = DateFormat("EEE, dd MMM yyyy");
    showSelectedDate.value = dayDateFormatter.format(selectedDate);
  }

  RxList<LeagueFootball> favouriteLeagues = <LeagueFootball>[].obs;

  bool isFavouriteLeague(int leagueId) {
    return favouriteLeagues.any(
          (e) => e.leagueId == leagueId,
    );
  }

  // void toggleFavouriteLeague(LeagueFootball league) {
  //   if (league.leagueId == null) return;
  //
  //   final leagueId = league.leagueId;
  //
  //   final index = favouriteLeagues.indexWhere(
  //         (item) => item.leagueId == leagueId,
  //   );
  //
  //   if (index != -1) {
  //     favouriteLeagues.removeAt(index);
  //   } else {
  //     favouriteLeagues.add(league);
  //   }
  // }

  // void toggleFavouriteLeague(LeagueFootball league) {
  //   final index = favouriteLeagues.indexWhere(
  //         (e) => e.leagueId == league.leagueId,
  //   );
  //
  //   if (index >= 0) {
  //     favouriteLeagues.removeAt(index);
  //   } else {
  //     favouriteLeagues.add(league);
  //   }
  // }

  void toggleFavouriteLeague(LeagueFootball league) {
    final exists = favouriteLeagues.any(
          (e) => e.leagueId == league.leagueId,
    );

    if (exists) {
      favouriteLeagues.removeWhere(
            (e) => e.leagueId == league.leagueId,
      );
      print("Removed: ${league.name}");
    } else {
      favouriteLeagues.add(league);
      print("Added: ${league.name}");
    }

    print("Total favourites: ${favouriteLeagues.length}");
  }
}
