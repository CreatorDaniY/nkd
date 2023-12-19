// ignore_for_file: non_constant_identifier_names
import 'package:flutter/foundation.dart';

class KEYS {

  static final NONAMED_TOKEN = 'norKor_token';

  static final Map<String, String> UNIT_ID = kReleaseMode ? {
    'ios': 'ca-app-pub-1354011941568570/1744959105',
    'android': 'ca-app-pub-1354011941568570/9462037689',
  } : {
    'ios': 'ca-app-pub-1354011941568570/1744959105',
    'android': 'ca-app-pub-1354011941568570/9462037689',
  };

  static final Map<String, String> INTERSTITIAL_UNIT_ID = !kReleaseMode ? {
    'ios': 'ca-app-pub-1354011941568570/4206454269',
    'android': 'ca-app-pub-1354011941568570/4541496181',
  } : {
    'ios': 'ca-app-pub-1354011941568570/4206454269',
    'android': 'ca-app-pub-3940256099942544/1033173712',
  };

  static final Map<String, String> REWARD_UNIT_ID = kReleaseMode ? {
    'ios': 'ca-app-pub-1354011941568570/7671056552',
    'android': 'ca-app-pub-1354011941568570/7655293428',
  } : {
    'ios': 'ca-app-pub-3940256099942544/5224354917',
    'android': 'ca-app-pub-3940256099942544/5224354917',
  };

}