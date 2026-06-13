import 'package:floor/floor.dart';

@Entity(tableName: 'FavouriteEvent')
class FavouriteEvent {
  @primaryKey
  final int id;
  final int eventCode;
  final String eventName;

  FavouriteEvent(this.id, this.eventCode, this.eventName);
}
