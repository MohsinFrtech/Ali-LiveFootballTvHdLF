
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../codeutils/event_dao_class.dart';
import '../datamodels/fav_event_class.dart';
import '../datamodels/favourite_league_class.dart';
// import 'league_dao_class.dart';
part 'database.g.dart'; // the generated code will be there

// @Database(version: 1, entities: [FavouriteEvent,FavouriteLeague])
// abstract class AppDatabase extends FloorDatabase {
//   EventDao get eventDao;
//
//   LeagueDao get leagueDao;
// }

// 2. Add FavouriteLeague to the entities list below
@Database(version: 1, entities: [FavouriteEvent])
abstract class AppDatabase extends FloorDatabase {
  EventDao get eventDao;

}