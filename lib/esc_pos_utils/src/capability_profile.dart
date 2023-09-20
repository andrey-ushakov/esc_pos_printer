// ignore_for_file: prefer_final_locals, prefer_single_quotes

/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:esc_pos_printer/esc_pos_utils/src/capabilities.dart';

class CodePage {
  CodePage(this.id, this.name);
  int id;
  String name;
}

class CapabilityProfile {
  CapabilityProfile._internal(this.name, this.codePages);

  static CapabilityProfile load({String name = 'default'}) {
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
}
