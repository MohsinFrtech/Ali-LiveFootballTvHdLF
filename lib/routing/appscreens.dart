import 'package:footscore/routing/approutes.dart';
import 'package:footscore/uiscreens/favourite_league_screen.dart';
import 'package:footscore/uiscreens/firstpage.dart';
import 'package:footscore/uiscreens/footballdetail.dart';
import 'package:footscore/uiscreens/innerchannels.dart';
import 'package:footscore/uiscreens/secondpage.dart';
import 'package:footscore/uiscreens/teammatch.dart';
import 'package:footscore/uiscreens/teams.dart';
import 'package:footscore/uiscreens/venuematch.dart';
import 'package:get/get.dart';

import '../uiscreens/favourite_events.dart';
import '../uiscreens/player_stat_screen.dart';
import '../uiscreens/team_players_and_matches.dart';
import '../uiscreens/venu_class.dart';
import '../uiscreens/vlcplayer.dart';

class AppScreens {
  static final List<GetPage> screens = [
    GetPage(name: Routes.firstpage, page: ()=> const FirstPage()),
    GetPage(name: Routes.secondpage, page: ()=> const SecondPage()),
    GetPage(name: Routes.footballMatchDetail, page: ()=> const FootballMatchDetail()),
    GetPage(name: Routes.leagueTeam, page: ()=> const LeagueTeams()),
    GetPage(name: Routes.teammatches, page: ()=> const TeamMatchesList()),
    GetPage(name: Routes.innerchannels, page: ()=> const InnerChannelClass()),
    GetPage(name: Routes.playerScreen, page: ()=> const VlcPlayerClass()),
    GetPage(name: Routes.venuClass, page: ()=> const VenueMainClass()),
    GetPage(name: Routes.venuMatches, page: ()=> const VenueMatchesList()),
    GetPage(name: Routes.teamMatchesAndPlayers, page: ()=> const TeamPlayersAndMatches()),
    GetPage(name: Routes.playersStatScreen, page: ()=> const PlayersStatScreen()),
    GetPage(name: Routes.favEvents, page: () => const FavouriteEvents()),
    GetPage(name: Routes.favLeagues, page: () => FavouriteLeagueScreen()),

  ];
}
