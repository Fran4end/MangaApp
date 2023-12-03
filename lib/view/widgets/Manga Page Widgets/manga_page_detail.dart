import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../model/manga.dart';
import '../skeleton.dart';

class MangaPlot extends StatelessWidget {
  final Manga manga;
  final double expandedHeight;

  const MangaPlot({
    super.key,
    required this.manga,
    this.expandedHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: ExpandableNotifier(
        child: ExpandablePanel(
          header: manga.readings == null
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 22.0,
                    ),
                    const SizedBox(width: defaultPadding / 2),
                    Text(
                      manga.vote == null ? "0" : manga.vote.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(width: defaultPadding / 2),
                    Text(
                      '(${manga.readings})',
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
          collapsed: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                manga.plot,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.fade,
              ),
              const Positioned(
                bottom: -8,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 25,
                ),
              ),
            ],
          ),
          expanded: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: Text(manga.plot),
              ),
              const Positioned(
                bottom: -10,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 25,
                ),
              ),
            ],
          ),
          theme: const ExpandableThemeData(
            hasIcon: false,
            useInkWell: false,
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            bodyAlignment: ExpandablePanelBodyAlignment.center,
            tapBodyToCollapse: true,
            tapBodyToExpand: true,
          ),
        ),
      ),
    );
  }
}

class MangaPageDetailAppBar extends StatelessWidget {
  final Manga manga;
  final double expandedHeight;
  final String tag;

  const MangaPageDetailAppBar({
    super.key,
    required this.manga,
    required this.expandedHeight,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Opacity(
          opacity: .8,
          child: Hero(
            tag: tag,
            child: CachedNetworkImage(
              imageUrl: manga.image,
              width: 120,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  const Center(child: Skeleton(color: Colors.white)),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              child: GenresWrap(manga: manga),
            ),
            Container(
              height: 30,
              width: 100,
              margin: const EdgeInsets.only(top: defaultPadding / 2),
              alignment: Alignment.center,
              child: Text(
                manga.status.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GenresWrap extends StatelessWidget {
  const GenresWrap({
    Key? key,
    required this.manga,
  }) : super(key: key);

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      runAlignment: WrapAlignment.center,
      children: manga.genres.map((e) {
        return Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(e, style: const TextStyle(fontSize: 12)),
            ));
      }).toList(),
    );
  }
}
