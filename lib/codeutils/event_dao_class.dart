import 'package:floor/floor.dart';

import '../datamodels/fav_event_class.dart';

@dao
abstract class EventDao {
  // Insert or replace
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFavouriteLeague(FavouriteEvent event);

  // Delete by leagueId (recommended)
  @Query("DELETE FROM FavouriteEvent WHERE eventName = :name AND eventCode = :code")
  Future<void> deleteFavouriteEvent(String name, int code);

  // Get all favourites
  @Query('SELECT * FROM FavouriteEvent')
  Future<List<FavouriteEvent>> getAllFavouriteEvents();

  // // Check if favourite
  // @Query(
  //     'SELECT EXISTS(SELECT 1 FROM FavouriteEvent WHERE leagueId = :leagueId)'
  // )
  // Future<bool?> isFavourite(int leagueId);

}
