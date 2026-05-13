import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _localizedValues = {
    'en': {
      'title': 'FloodMap-K',
      'report_tab': 'Report',
      'map_tab': 'Live Map',
      'header': 'RURAL KENYA FLOOD REPORTING',
      'button': 'REPORT FLOOD',
      'add_photo': 'ADD PHOTO (Optional)',
      'change_photo': 'CHANGE PHOTO',
      'success': 'Report saved and queued for upload!',
    },
    'sw': {
      'title': 'RamaniYaMafuriko-K',
      'report_tab': 'Ripoti',
      'map_tab': 'Ramani',
      'header': 'RIPOTI MAFURIKO VIJIJINI KENYA',
      'button': 'RIPOTI MAFURIKO',
      'add_photo': 'WEKA PICHA (Hiari)',
      'change_photo': 'BADILISHA PICHA',
      'success': 'Ripoti imehifadhiwa na inapakiwa!',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }
}
