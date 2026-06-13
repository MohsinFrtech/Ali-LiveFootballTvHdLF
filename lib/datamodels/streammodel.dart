import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';

part 'streammodel.g.dart';

@JsonSerializable()
class StreamModel {
  List<AppAd>? app_ads;
  List<ApplicationConfiguration>? application_configurations;
  String? build_no;
  List<Category>? categories;
  List<EventStreaming>? events;
  List<News>? news;
  bool? live;
  String? name;
  String? extra_1;
  String? extra_2 = "";
  String? extra_3;
  String? app_version;
  String? app_update_text;
  String? url;
  String? extras;
  bool? is_permanent_dialog = false;
  List<String>? countryCodes;


  StreamModel(
      this.app_ads,
      this.application_configurations,
      this.build_no,
      this.categories,
      this.events,
      this.news,
      this.live,
      this.name,
      this.extra_1,
      this.extra_2,
      this.extra_3,
      this.app_version,
      this.app_update_text,
      this.url,
      this.extras,
      this.is_permanent_dialog,
      this.countryCodes);

  factory StreamModel.fromJson(Map<String, dynamic> json) =>
      _$StreamModelFromJson(json);

  Map<String, dynamic> toJson() => _$StreamModelToJson(this);
}

@JsonSerializable()
class News {
  String? name;
  bool? live;
  int? priority = 0;
  String? status;

  News(this.name, this.live, this.priority, this.status);

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable()
class ApplicationConfiguration {
  String? key;
  String? value;

  ApplicationConfiguration(this.key, this.value);

  factory ApplicationConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ApplicationConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationConfigurationToJson(this);
}

@JsonSerializable()
class EventStreaming {
  List<Channel>? channels;
  String? event_image_url;
  String? image_url;
  bool? live;
  String? name;
  int? priority = 0;
  String? status;
  String? web_image_url;
  List<String>? countryCodes;
  RxBool? isFavourite=RxBool(false);

  EventStreaming(this.channels, this.event_image_url, this.image_url, this.live,
      this.name, this.priority, this.status, this.web_image_url , this.countryCodes);

  factory EventStreaming.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable()
class Category {
  String? category_image_url;
  List<Channel>? channels;
  String? image_url;
  bool? live;
  String? name;
  int? priority;
  String? thumbnail_image;
  String? web_image_url;

  Category(this.category_image_url, this.channels, this.image_url, this.live,
      this.name, this.priority, this.thumbnail_image, this.web_image_url);

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Channel {
  String? channel_image_url;
  String? channel_type;
  String? image_url;
  bool? live;
  String? name;
  int? position = 0;
  String? date;
  int? priority = 0;
  String? url;
  String? web_image_url;
  bool? isSelected;
  RxBool? sSelected=RxBool(false);
  List<String>? countryCodes;
  String? initial_time;
  List<ChannelConfiguration>? channel_configurations;

  Channel(
      this.channel_image_url,
      this.channel_type,
      this.image_url,
      this.live,
      this.name,
      this.position,
      this.date,
      this.priority,
      this.url,
      this.web_image_url,
      this.isSelected,
      this.countryCodes,
      this.initial_time,
      this.channel_configurations);

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}


@JsonSerializable()
class ChannelConfiguration {
  String? key;
  String? value;

  ChannelConfiguration(this.key, this.value);
  factory ChannelConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ChannelConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelConfigurationToJson(this);
}

@JsonSerializable()
class AppAd {
  List<AdLocation>? ad_locations;
  String? ad_provider;
  bool? enable;
  String? otherad;
  String? ad_key;
  String? time;

  AppAd(this.ad_locations, this.ad_provider, this.enable, this.otherad,
      this.ad_key, this.time);

  factory AppAd.fromJson(Map<String, dynamic> json) => _$AppAdFromJson(json);

  Map<String, dynamic> toJson() => _$AppAdToJson(this);
}

@JsonSerializable()
class AdLocation {
  String? title;

  AdLocation({this.title});

  factory AdLocation.fromJson(Map<String, dynamic> json) =>
      _$AdLocationFromJson(json);

  Map<String, dynamic> toJson() => _$AdLocationToJson(this);
}
