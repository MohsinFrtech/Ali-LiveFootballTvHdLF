import 'package:floor/floor.dart';

@Entity(tableName: 'FavouriteLeague')
class FavouriteLeague {
  @primaryKey
  final int id;
  final String leagueName;
  final int leagueId;
  final String leagueSeason;
  final String leagueLogo;

  FavouriteLeague(this.id, this.leagueName, this.leagueId, this.leagueSeason,
      this.leagueLogo);
}
