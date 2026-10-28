import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AvatarIconHelper {
  AvatarIconHelper._();

  static const List<String> availableKeys = [
    'user',
    'smile',
    'heart',
    'star',
    'sparkles',
    'coffee',
    'briefcase',
    'music',
    'code',
    'palette',
    'camera',
    'flame',
    'compass',
    'gem',
    'crown',
    'sun',
  ];

  static const Map<String, IconData> iconMap = {
    'user': LucideIcons.user,
    'smile': LucideIcons.smile,
    'heart': LucideIcons.heart,
    'star': LucideIcons.star,
    'sparkles': LucideIcons.sparkles,
    'coffee': LucideIcons.coffee,
    'briefcase': LucideIcons.briefcase,
    'music': LucideIcons.music,
    'code': LucideIcons.code,
    'palette': LucideIcons.palette,
    'camera': LucideIcons.camera,
    'flame': LucideIcons.flame,
    'compass': LucideIcons.compass,
    'gem': LucideIcons.gem,
    'crown': LucideIcons.crown,
    'sun': LucideIcons.sun,
  };

  static IconData resolve(String? key) {
    if (key == null) return LucideIcons.user;
    return iconMap[key] ?? LucideIcons.user;
  }
}
