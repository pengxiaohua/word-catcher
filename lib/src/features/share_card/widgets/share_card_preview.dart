import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../models/share_card_data.dart';
import '../models/share_card_template.dart';
import 'film_template.dart';
import 'magazine_template.dart';
import 'postcard_template.dart';

class ShareCardPreview extends StatelessWidget {
  const ShareCardPreview({required this.data, super.key});

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
          child: switch (data.template) {
            ShareCardTemplate.postcard => PostcardTemplate(data: data),
            ShareCardTemplate.magazine => MagazineTemplate(data: data),
            ShareCardTemplate.filmNote => FilmNoteTemplate(data: data),
          },
        ),
      ),
    );
  }
}
