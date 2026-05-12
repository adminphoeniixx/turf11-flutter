import 'package:intl/intl.dart';

class TurfModel {
  final int id;
  final String name;
  final String format;
  final String city;
  final String address;
  final String location;
  final String sportType;
  final String description;
  final int maxCapacity;
  final num pricePerHour;
  final num rating;
  final int totalReviews;
  final int totalBookings;
  final bool isAvailable;
  final num? distanceKm;
  final double? latitude;
  final double? longitude;
  final TurfPricing? pricing;
  final TurfOperatingHours? operatingHours;
  final List<String> amenities;
  final List<TurfMediaModel> photos;
  final List<TurfMediaModel> videos;
  final String ownerName;
  final String ownerBusiness;

  const TurfModel({
    required this.id,
    required this.name,
    required this.format,
    required this.city,
    required this.address,
    required this.location,
    required this.sportType,
    required this.description,
    required this.maxCapacity,
    required this.pricePerHour,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    required this.isAvailable,
    required this.amenities,
    required this.ownerName,
    required this.ownerBusiness,
    this.photos = const <TurfMediaModel>[],
    this.videos = const <TurfMediaModel>[],
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.pricing,
    this.operatingHours,
  });

  String get priceLabel => hasPrice ? 'Rs ${_formatAmount(pricePerHour)}/hr' : '';
  String get ratingLabel => rating <= 0 ? '' : rating.toStringAsFixed(1);
  bool get hasPrice => pricePerHour > 0;
  String get reviewLabel => totalReviews > 0 ? '($totalReviews)' : '';
  String get formatLabel => format.trim().isEmpty ? 'Standard' : format;

  factory TurfModel.fromJson(Map<String, dynamic> json) {
    final nested = _readNested(json);
    final merged = <String, dynamic>{...json, ...nested};
    final pricingMap = _readMap(merged['pricing']);
    final hoursMap = _readMap(merged['operating_hours']);
    final ownerMap = _readMap(merged['owner']);

    return TurfModel(
      id: _readInt(merged, const ['id', 'turf_id']) ?? 0,
      name: _readString(merged, const ['name', 'turf_name'], fallback: 'Turf'),
      format: _readString(merged, const ['format'], fallback: ''),
      city: _readString(merged, const ['city'], fallback: ''),
      address: _readString(merged, const ['address', 'location'], fallback: ''),
      location: _readString(
        merged,
        const ['location', 'address', 'city', 'area'],
        fallback: 'Location unavailable',
      ),
      sportType: _readString(
        merged,
        const ['sport_type', 'sport', 'game_type'],
        fallback: 'cricket',
      ),
      description: _readString(merged, const ['description'], fallback: ''),
      maxCapacity: _readInt(merged, const ['max_capacity']) ?? 0,
      pricePerHour: _readNum(
            merged,
            const [
              'price_hr',
              'price_per_hour',
              'hourly_price',
              'price',
              'amount',
              'per_hour',
            ],
          ) ??
          _readNum(
            pricingMap,
            const ['per_hour', 'weekday', 'weekend', 'peak', 'night'],
          ) ??
          0,
      rating: _readNum(
            merged,
            const [
              'rating',
              'avg_rating',
              'average_rating',
              'rating_avg',
              'reviews_avg_rating',
            ],
          ) ??
          0,
      totalReviews:
          _readInt(
                merged,
                const ['total_reviews', 'reviews_count', 'review_count'],
              ) ??
              0,
      totalBookings: _readInt(merged, const ['total_bookings']) ?? 0,
      isAvailable: _readBool(
            merged,
            const ['is_available', 'available', 'is_open', 'open_now'],
          ) ??
          true,
      distanceKm: _readNum(merged, const ['distance_km', 'distance']),
      latitude: _readDouble(merged, const ['lat', 'latitude']),
      longitude: _readDouble(merged, const ['lng', 'longitude', 'long']),
      pricing:
          pricingMap.isEmpty ? null : TurfPricing.fromJson(pricingMap),
      operatingHours: hoursMap.isEmpty
          ? null
          : TurfOperatingHours.fromJson(hoursMap),
      amenities: _readStringList(merged['amenities']),
      photos: _readMediaList(
        merged,
        const [
          'photos',
          'photo_urls',
          'images',
          'image_urls',
          'gallery',
          'gallery_images',
        ],
        TurfMediaType.photo,
      ),
      videos: _readMediaList(
        merged,
        const ['videos', 'video_urls', 'video_gallery'],
        TurfMediaType.video,
      ),
      ownerName: _readString(ownerMap, const ['name'], fallback: ''),
      ownerBusiness: _readString(ownerMap, const ['business'], fallback: ''),
    );
  }

  static Map<String, dynamic> _readNested(Map<String, dynamic> source) {
    for (final key in const ['data', 'turf']) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static int? _readInt(Map<String, dynamic> source, List<String> keys) {
    final value = _readNum(source, keys);
    return value?.toInt();
  }

  static num? _readNum(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) {
        return value;
      }
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        final parsed = num.tryParse(cleaned);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> source, List<String> keys) {
    final value = _readNum(source, keys);
    return value?.toDouble();
  }

  static bool? _readBool(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }
    return null;
  }

  static String _readString(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final normalized = value.trim();
      if (normalized.startsWith('[') && normalized.endsWith(']')) {
        final inner = normalized.substring(1, normalized.length - 1);
        return inner
            .split(',')
            .map((item) => item.replaceAll('"', '').trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (normalized.isNotEmpty) {
        return [normalized];
      }
    }
    return const <String>[];
  }

  static List<TurfMediaModel> _readMediaList(
    Map<String, dynamic> source,
    List<String> directKeys,
    TurfMediaType expectedType,
  ) {
    final items = <TurfMediaModel>[];

    for (final key in directKeys) {
      items.addAll(_readMediaItems(source[key], fallbackType: expectedType));
    }

    for (final key in const ['media', 'media_files', 'attachments']) {
      items.addAll(
        _readMediaItems(source[key]).where((item) => item.type == expectedType),
      );
    }

    final seen = <String>{};
    return items.where((item) => seen.add(item.url)).toList();
  }

  static List<TurfMediaModel> _readMediaItems(
    dynamic value, {
    TurfMediaType? fallbackType,
  }) {
    if (value is List) {
      return value
          .expand((item) => _readMediaItems(item, fallbackType: fallbackType))
          .toList();
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in const ['data', 'items', 'files']) {
        final nested = map[key];
        if (nested is List) {
          return _readMediaItems(nested, fallbackType: fallbackType);
        }
      }

      final url = _readString(
        map,
        const [
          'url',
          'path',
          'file',
          'file_url',
          'media_url',
          'src',
          'full_url',
          'video_url',
          'photo_url',
          'image_url',
        ],
      );
      if (url.isEmpty) {
        return const <TurfMediaModel>[];
      }
      final typeText = _readString(
        map,
        const ['type', 'media_type', 'mime_type', 'mime'],
      );
      final type = _mediaTypeFromText(typeText, url, fallbackType);
      return [
        TurfMediaModel(
          url: url,
          type: type,
          title: _readString(map, const ['title', 'name', 'caption']),
        ),
      ];
    }
    if (value is String) {
      final url = value.trim();
      if (url.isEmpty) {
        return const <TurfMediaModel>[];
      }
      if (url.contains(',')) {
        return url
            .split(',')
            .expand((item) => _readMediaItems(item, fallbackType: fallbackType))
            .toList();
      }
      return [
        TurfMediaModel(
          url: url,
          type: _mediaTypeFromText('', url, fallbackType),
        ),
      ];
    }
    return const <TurfMediaModel>[];
  }

  static TurfMediaType _mediaTypeFromText(
    String typeText,
    String url,
    TurfMediaType? fallbackType,
  ) {
    final normalized = '$typeText $url'.toLowerCase();
    if (normalized.contains('video') ||
        normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m3u8') ||
        normalized.endsWith('.webm')) {
      return TurfMediaType.video;
    }
    if (normalized.contains('image') ||
        normalized.contains('photo') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.png') ||
        normalized.endsWith('.webp')) {
      return TurfMediaType.photo;
    }
    return fallbackType ?? TurfMediaType.photo;
  }

  static String _formatAmount(num value) {
    final isWhole = value == value.roundToDouble();
    return value.toStringAsFixed(isWhole ? 0 : 2);
  }
}

enum TurfMediaType { photo, video }

class TurfMediaModel {
  final String url;
  final TurfMediaType type;
  final String title;

  const TurfMediaModel({
    required this.url,
    required this.type,
    this.title = '',
  });
}

class TurfPricing {
  final num weekday;
  final num weekend;
  final num peak;
  final bool surgeEnabled;

  const TurfPricing({
    required this.weekday,
    required this.weekend,
    required this.peak,
    required this.surgeEnabled,
  });

  factory TurfPricing.fromJson(Map<String, dynamic> json) {
    return TurfPricing(
      weekday: TurfModel._readNum(json, const ['weekday']) ?? 0,
      weekend: TurfModel._readNum(json, const ['weekend']) ?? 0,
      peak: TurfModel._readNum(json, const ['peak', 'night']) ?? 0,
      surgeEnabled:
          TurfModel._readBool(json, const ['surge_enabled']) ?? false,
    );
  }
}

class TurfOperatingHours {
  final String opens;
  final String closes;
  final bool openSundays;
  final bool openHolidays;

  const TurfOperatingHours({
    required this.opens,
    required this.closes,
    required this.openSundays,
    required this.openHolidays,
  });

  factory TurfOperatingHours.fromJson(Map<String, dynamic> json) {
    return TurfOperatingHours(
      opens: TurfModel._readString(
        json,
        const ['opens', 'open'],
        fallback: '--:--',
      ),
      closes: TurfModel._readString(
        json,
        const ['closes', 'close'],
        fallback: '--:--',
      ),
      openSundays:
          TurfModel._readBool(json, const ['open_sundays']) ?? false,
      openHolidays:
          TurfModel._readBool(json, const ['open_holidays']) ?? false,
    );
  }
}

class TurfReviewModel {
  final String playerName;
  final num rating;
  final String text;
  final List<String> tags;
  final String ownerReply;
  final String createdAt;

  const TurfReviewModel({
    required this.playerName,
    required this.rating,
    required this.text,
    required this.tags,
    required this.ownerReply,
    required this.createdAt,
  });

  factory TurfReviewModel.fromJson(Map<String, dynamic> json) {
    return TurfReviewModel(
      playerName:
          TurfModel._readString(json, const ['player_name'], fallback: 'Player'),
      rating: TurfModel._readNum(json, const ['rating']) ?? 0,
      text: TurfModel._readString(json, const ['text'], fallback: ''),
      tags: TurfModel._readStringList(json['tags']),
      ownerReply:
          TurfModel._readString(json, const ['owner_reply'], fallback: ''),
      createdAt:
          TurfModel._readString(json, const ['created_at'], fallback: ''),
    );
  }
}

class TurfDetailResponse {
  final TurfModel? turf;
  final List<TurfReviewModel> reviews;

  const TurfDetailResponse({
    required this.turf,
    required this.reviews,
  });

  factory TurfDetailResponse.fromJson(Map<String, dynamic> json) {
    final turfMap = TurfModel._readMap(json['turf']);
    final mergedTurfMap = <String, dynamic>{...json, ...turfMap};
    final reviewsRaw = json['reviews'];
    return TurfDetailResponse(
      turf: turfMap.isEmpty ? null : TurfModel.fromJson(mergedTurfMap),
      reviews: reviewsRaw is List
          ? reviewsRaw
              .whereType<Map>()
              .map(
                (item) => TurfReviewModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <TurfReviewModel>[],
    );
  }
}

class TurfSlotModel {
  final int id;
  final String label;
  final num price;
  final bool isAvailable;

  const TurfSlotModel({
    required this.id,
    required this.label,
    required this.price,
    required this.isAvailable,
  });

  bool isExpiredForDate(DateTime selectedDate, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final normalizedSelected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final normalizedCurrent =
        DateTime(current.year, current.month, current.day);

    if (normalizedSelected.isBefore(normalizedCurrent)) {
      return true;
    }
    if (normalizedSelected.isAfter(normalizedCurrent)) {
      return false;
    }

    final slotStart = startDateTimeOn(selectedDate);
    if (slotStart == null) {
      return false;
    }

    return !slotStart.isAfter(current);
  }

  DateTime? startDateTimeOn(DateTime selectedDate) {
    final startText = _extractStartTime(label);
    if (startText == null) {
      return null;
    }

    for (final pattern in const [
      'HH:mm:ss',
      'HH:mm',
      'H:mm',
      'hh:mm a',
      'h:mm a',
      'h a',
    ]) {
      try {
        final parsedTime = DateFormat(pattern).parseStrict(startText);
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          parsedTime.hour,
          parsedTime.minute,
          parsedTime.second,
        );
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  factory TurfSlotModel.fromJson(Map<String, dynamic> json) {
    final start = _readString(
      json,
      const ['time_start', 'start_time', 'start'],
    );
    final end = _readString(
      json,
      const ['time_end', 'end_time', 'end'],
    );
    final derivedLabel = start.isNotEmpty || end.isNotEmpty
        ? '${start.isEmpty ? '--:--' : start} - ${end.isEmpty ? '--:--' : end}'
        : _readString(json, const ['slot', 'time', 'label'], fallback: 'Slot');

    final isBooked = _readBool(
          json,
          const ['is_booked', 'booked'],
        ) ??
        false;
    final isAvailable = _readBool(
          json,
          const ['is_available', 'available'],
        ) ??
        !isBooked;

    return TurfSlotModel(
      id: _readInt(json, const ['id', 'slot_id']) ?? 0,
      label: derivedLabel,
      price:
          _readNum(json, const ['price', 'amount', 'price_per_hour']) ?? 0,
      isAvailable: isAvailable,
    );
  }

  static int? _readInt(Map<String, dynamic> source, List<String> keys) {
    final value = _readNum(source, keys);
    return value?.toInt();
  }

  static num? _readNum(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) {
        return value;
      }
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
        final parsed = num.tryParse(cleaned);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }
    return null;
  }

  static String _readString(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  static String? _extractStartTime(String label) {
    final normalized = label.trim();
    if (normalized.isEmpty) {
      return null;
    }

    for (final separator in const [' - ', '–', '-']) {
      final parts = normalized.split(separator);
      if (parts.length >= 2) {
        final start = parts.first.trim();
        if (start.isNotEmpty) {
          return start;
        }
      }
    }

    return normalized;
  }
}
