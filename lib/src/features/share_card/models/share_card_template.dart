import 'package:flutter/material.dart';

enum ShareCardTemplate {
  postcard(
    label: 'Postcard',
    chineseLabel: '明信片',
    description: '照片与白色便签区，适合温柔学习分享。',
    icon: Icons.local_post_office_outlined,
  ),
  magazine(
    label: 'Magazine',
    chineseLabel: '杂志封面',
    description: '全幅照片与大标题，视觉冲击更强。',
    icon: Icons.auto_stories_outlined,
  ),
  filmNote(
    label: 'Film Note',
    chineseLabel: '胶片笔记',
    description: '拍立得相纸感，像旅行里的单词注脚。',
    icon: Icons.photo_camera_back_outlined,
  );

  const ShareCardTemplate({
    required this.label,
    required this.chineseLabel,
    required this.description,
    required this.icon,
  });

  final String label;
  final String chineseLabel;
  final String description;
  final IconData icon;
}
