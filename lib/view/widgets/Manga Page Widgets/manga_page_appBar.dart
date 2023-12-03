import 'package:flutter/material.dart';
import 'package:yomu_no_ikiru/model/manga_builder.dart';

import '../../../constants.dart';
import '../top_button.dart';
import 'manga_page_background.dart';
import 'manga_page_detail.dart';

class CustomSliverAppBar extends StatelessWidget {
  final bool save;
  final double expandedHeight;
  final String tag;
  final MangaBuilder mangaBuilder;
  final Function()? rightButtonFunction;
  const CustomSliverAppBar({
    super.key,
    required this.save,
    this.expandedHeight = 380,
    required this.mangaBuilder,
    required this.tag,
    this.rightButtonFunction,
  });

  final double artistAuthorSize = 12;

  @override
  Widget build(BuildContext context) {
    final manga = mangaBuilder.build();
    return SliverAppBar(
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(defaultPadding / 2),
        child: TopButtonsFunctions(
          ic: const Icon(Icons.arrow_back_ios_new_rounded),
          function: () => Navigator.of(context).pop(),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        collapseMode: CollapseMode.parallax,
        titlePadding: const EdgeInsets.symmetric(
            horizontal: defaultPadding * 2, vertical: defaultPadding / 2),
        title: SafeArea(
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  manga.title.toString(),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      manga.author.toString(),
                      style: TextStyle(fontSize: artistAuthorSize, fontWeight: FontWeight.w200),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      manga.artist.toString(),
                      style: TextStyle(fontSize: artistAuthorSize, fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            MangaPageBackground(manga: manga),
            Positioned(
              top: kToolbarHeight + 50,
              child: MangaPageDetailAppBar(
                manga: manga,
                expandedHeight: expandedHeight,
                tag: tag,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding / 2),
          child: TopButtonsFunctions(
            ic: save
                ? const Icon(Icons.favorite_rounded)
                : const Icon(Icons.favorite_outline_rounded),
            function: rightButtonFunction,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(
          width: defaultPadding / 2,
        ),
      ],
    );
  }
}
