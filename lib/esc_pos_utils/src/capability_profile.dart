// ignore_for_file: prefer_final_locals, prefer_single_quotes

/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert' show json;
import 'package:esc_pos_printer/esc_pos_utils/src/capabilities.dart';
import 'package:flutter/services.dart' show rootBundle;

class CodePage {
  CodePage(this.id, this.name);
  int id;
  String name;
}

class CapabilityProfile {
  CapabilityProfile._internal(this.name, this.codePages);

  /// Public factory
  static Future<CapabilityProfile> load({String name = 'default'}) async {
    Map<String, dynamic> capabilities = capabilitiesJosn;

    dynamic profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<CodePage> list = [];
    profile['codePages'].forEach((dynamic k, dynamic v) {
      list.add(CodePage(int.parse(k), v));
    });

    // Call the private constructor
    return CapabilityProfile._internal(name, list);
  }

  String name;
  List<CodePage> codePages;

  int getCodePageId(String? codePage) {
    return codePages
        .firstWhere((cp) => cp.name == codePage,
            orElse: () => throw Exception("Code Page '$codePage' isn't defined for this profile"))
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles() async {
    final content =
        await rootBundle.loadString('packages/esc_pos_utils/resources/capabilities.json');
    Map capabilities = json.decode(content);

    dynamic profiles = capabilities['profiles'];

    List<dynamic> res = <dynamic>[];

    profiles.forEach((dynamic k, dynamic v) {
      res.add(<String, dynamic>{
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}
