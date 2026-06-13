// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streammodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamModel _$StreamModelFromJson(Map<String, dynamic> json) => StreamModel(
  (json['app_ads'] as List<dynamic>?)
      ?.map((e) => AppAd.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['application_configurations'] as List<dynamic>?)
      ?.map((e) =>
      ApplicationConfiguration.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['build_no'] as String?,
  (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['events'] as List<dynamic>?)
      ?.map((e) => EventStreaming.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['news'] as List<dynamic>?)
      ?.map((e) => News.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['live'] as bool?,
  json['name'] as String?,
  json['extra_1'] as String?,
  json['extra_2'] as String?,
  json['extra_3'] as String?,
  json['app_version'] as String?,
  json['app_update_text'] as String?,
  json['url'] as String?,
  json['extras'] as String?,
  json['is_permanent_dialog'] as bool?,
  (json['countryCodes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$StreamModelToJson(StreamModel instance) =>
    <String, dynamic>{
      'app_ads': instance.app_ads,
      'application_configurations': instance.application_configurations,
      'build_no': instance.build_no,
      'categories': instance.categories,
      'events': instance.events,
      'news': instance.news,
      'live': instance.live,
      'name': instance.name,
      'extra_1': instance.extra_1,
      'extra_2': instance.extra_2,
      'extra_3': instance.extra_3,
      'app_version': instance.app_version,
      'app_update_text': instance.app_update_text,
      'url': instance.url,
      'extras': instance.extras,
      'is_permanent_dialog': instance.is_permanent_dialog,
      'countryCodes': instance.countryCodes,
    };

News _$NewsFromJson(Map<String, dynamic> json) => News(
  json['name'] as String?,
  json['live'] as bool?,
  (json['priority'] as num?)?.toInt(),
  json['status'] as String?,
);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
  'name': instance.name,
  'live': instance.live,
  'priority': instance.priority,
  'status': instance.status,
};

ApplicationConfiguration _$ApplicationConfigurationFromJson(
    Map<String, dynamic> json) =>
    ApplicationConfiguration(
      json['key'] as String?,
      json['value'] as String?,
    );

Map<String, dynamic> _$ApplicationConfigurationToJson(
    ApplicationConfiguration instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

EventStreaming _$EventFromJson(Map<String, dynamic> json) =>
    EventStreaming(
      (json['channels'] as List<dynamic>?)
          ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['event_image_url'] as String?,
      json['image_url'] as String?,
      json['live'] as bool?,
      json['name'] as String?,
      (json['priority'] as num?)?.toInt(),
      json['status'] as String?,
      json['web_image_url'] as String?,
      (json['countryCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EventToJson(EventStreaming instance) =>
    <String, dynamic>{
      'channels': instance.channels,
      'event_image_url': instance.event_image_url,
      'image_url': instance.image_url,
      'live': instance.live,
      'name': instance.name,
      'priority': instance.priority,
      'status': instance.status,
      'web_image_url': instance.web_image_url,
      'countryCodes': instance.countryCodes,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  json['category_image_url'] as String?,
  (json['channels'] as List<dynamic>?)
      ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['image_url'] as String?,
  json['live'] as bool?,
  json['name'] as String?,
  (json['priority'] as num?)?.toInt(),
  json['thumbnail_image'] as String?,
  json['web_image_url'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'category_image_url': instance.category_image_url,
  'channels': instance.channels,
  'image_url': instance.image_url,
  'live': instance.live,
  'name': instance.name,
  'priority': instance.priority,
  'thumbnail_image': instance.thumbnail_image,
  'web_image_url': instance.web_image_url,
};

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
  json['channel_image_url'] as String?,
  json['channel_type'] as String?,
  json['image_url'] as String?,
  json['live'] as bool?,
  json['name'] as String?,
  (json['position'] as num?)?.toInt(),
  json['date'] as String?,
  (json['priority'] as num?)?.toInt(),
  json['url'] as String?,
  json['web_image_url'] as String?,
  json['isSelected'] as bool?,
  (json['countryCodes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  json['initial_time'] as String?,
  (json['channel_configurations'] as List<dynamic>?)
      ?.map((e) => ChannelConfiguration.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
  'channel_image_url': instance.channel_image_url,
  'channel_type': instance.channel_type,
  'image_url': instance.image_url,
  'live': instance.live,
  'name': instance.name,
  'position': instance.position,
  'date': instance.date,
  'priority': instance.priority,
  'url': instance.url,
  'web_image_url': instance.web_image_url,
  'isSelected': instance.isSelected,
  'countryCodes': instance.countryCodes,
  'initial_time': instance.initial_time,
  'channel_configurations': instance.channel_configurations,
};
ChannelConfiguration _$ChannelConfigurationFromJson(
    Map<String, dynamic> json) =>
    ChannelConfiguration(
      json['key'] as String?,
      json['value'] as String?,
    );

Map<String, dynamic> _$ChannelConfigurationToJson(
    ChannelConfiguration instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

AppAd _$AppAdFromJson(Map<String, dynamic> json) => AppAd(
  (json['ad_locations'] as List<dynamic>?)
      ?.map((e) => AdLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['ad_provider'] as String?,
  json['enable'] as bool?,
  json['otherad'] as String?,
  json['ad_key'] as String?,
  json['time'] as String?,
);

Map<String, dynamic> _$AppAdToJson(AppAd instance) => <String, dynamic>{
  'ad_locations': instance.ad_locations,
  'ad_provider': instance.ad_provider,
  'enable': instance.enable,
  'otherad': instance.otherad,
  'ad_key': instance.ad_key,
  'time': instance.time,
};

AdLocation _$AdLocationFromJson(Map<String, dynamic> json) => AdLocation(
  title: json['title'] as String?,
);

Map<String, dynamic> _$AdLocationToJson(AdLocation instance) =>
    <String, dynamic>{
      'title': instance.title,
    };
