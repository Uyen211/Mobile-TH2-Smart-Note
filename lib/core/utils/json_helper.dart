// /core/utils/json_helper

import 'dart:convert';

class JsonHelper {
  static T? safeDecode<T>(String? jsonString, T Function(dynamic) mapper) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final dynamic decoded = json.decode(jsonString);
      return mapper(decoded);
    } catch (e) {
      // swallow and return null for resilience
      return null;
    }
  }
}
