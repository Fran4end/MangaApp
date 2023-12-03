import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yomu_no_ikiru/constants.dart';

import '../../Api/Adapter/mangakatana_adapter.dart';
import '../../Api/adapter.dart';
import '../../controller/reader_page_controller.dart';
import '../../model/chapter.dart';
import '../../model/manga_builder.dart';
import '../widgets/Reader Page Widgets/animated_bar.dart';
import '../widgets/Reader Page Widgets/app_bar_reader_page.dart';
import '../widgets/Reader Page Widgets/bottom_navigation_bar_reader.dart';
import '../widgets/Reader Page Widgets/reader_page_widget.dart';

class Reader extends StatefulWidget {
  const Reader({
    required this.chapterIndex,
    required this.pageIndex,
    required this.builder,
    required this.onScope,
    required this.axis,
    required this.reverse,
    required this.icon,
    required this.onPageChange,
    required this.api,
    this.lastPage = false,
    super.key,
  });
  final int chapterIndex, pageIndex;
  final MangaBuilder builder;
  final Axis axis;
  final bool reverse;
  final Widget icon;
  final MangaApiAdapter api;
  final Function(MangaBuilder builder) onScope;
  final Function(int page, int chapterIndex) onPageChange;
  final bool lastPage;

  @override
  State<StatefulWidget> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  late final Function(MangaBuilder builder) onScope = widget.onScope;
  late final MangaBuilder builder = widget.builder;
  late final WebViewController controller;
  late final api = widget.api;
  late bool reverse = widget.reverse;
  late Axis axis = widget.axis;
  late Widget icon = widget.icon;
  late int pageIndex = widget.pageIndex;
  late final Chapter chapter;

  double sliderValue = 2;
  bool isSliding = false;
  Future<List<String>>? imageFutures;
  PageController? pageController;
  bool showAppBar = false;
  NativeAd? nativeAd1;
  NativeAd? nativeAd2;

  @override
  void initState() {
    super.initState();
    final manga = builder.build();
    chapter = manga.chapters[widget.chapterIndex];
    nativeAd1 = ReaderPageController.loadAd();
    nativeAd2 = ReaderPageController.loadAd();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(chapter.link!),
      );
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          var document =
              await controller.runJavaScriptReturningResult('document.documentElement.innerHTML');
          var dom = parse(json.decode(document.toString()));
          imageFutures = api.getImageUrls(dom);
          _setController();
          setState(() {});
        },
      ),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  _setController() {
    imageFutures!.then((images) {
      if (mounted) {
        if (widget.lastPage) {
          pageIndex = images.length;
        }
        pageController = PageController(initialPage: pageIndex);
        pageController?.addListener(
          () => ReaderPageController.pageControllerListener(
            imageUrls: images,
            pageController: pageController!,
            context: context,
            builder: builder,
            chapterIndex: widget.chapterIndex,
            axis: axis,
            icon: icon,
            reverse: reverse,
            onScope: onScope,
            onPageChange: widget.onPageChange,
            controller: controller,
            api: api,
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    onScope(builder);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: imageFutures,
        builder: (context, snapshot) {
          if (snapshot.data != null &&
              snapshot.data!.isEmpty &&
              api.runtimeType != MangaKatanaAdapter) {
            return const Center(child: Text("No chapter pages found"));
          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            final List<String> imageUrls = snapshot.data!;
            for (var img in imageUrls) {
              ReaderPageController.preloadImage(context, img);
            }
            return Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: AnimatedBar(
                begin: const Offset(0, -1),
                builder: () => !showAppBar
                    ? const SizedBox.shrink()
                    : ReaderPageAppBar(
                        chapter: chapter,
                        onPressed: () {
                          var (a, i, r) = ReaderPageController.changeDirection(
                              axis: axis, icon: icon, reverse: reverse);
                          setState(() {
                            axis = a;
                            icon = i;
                            reverse = r;
                          });
                        },
                        mangaTitle: builder.title,
                        icon: icon,
                      ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: AnimatedBar(
                  begin: const Offset(0, 1),
                  builder: () => !showAppBar
                      ? const SizedBox.shrink()
                      : SafeArea(
                          child: ReaderBottomNavigationBar(
                            reverse: reverse,
                            chapters: builder.chapters,
                            builder: builder,
                            chapterIndex: widget.chapterIndex,
                            axis: axis,
                            icon: icon,
                            onScope: onScope,
                            onPageChange: widget.onPageChange,
                            images: imageUrls,
                            pageIndex: pageIndex,
                            slider: Slider.adaptive(
                              inactiveColor: Theme.of(context).colorScheme.secondary,
                              value: sliderValue,
                              divisions: imageUrls.length + 2,
                              label: "${sliderValue.toInt() - 1} / ${imageUrls.length}",
                              min: 2,
                              max: (imageUrls.length.toDouble() + 1),
                              onChangeStart: (value) => setState(() {
                                isSliding = true;
                              }),
                              onChangeEnd: (value) => setState(() {
                                isSliding = false;
                              }),
                              onChanged: (value) {
                                if (!(value == 1 || value == imageUrls.length + 2)) {
                                  sliderValue = value;
                                }
                                pageIndex = value.toInt() - 1;
                                pageController?.animateToPage(
                                  pageIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                setState(() {});
                              },
                            ),
                            api: api,
                          ),
                        ),
                ),
              ),
              body: ReaderPageWidget(
                axis: axis,
                reverse: reverse,
                imageUrls: imageUrls,
                pageController: pageController,
                chapters: builder.chapters,
                chapterIndex: widget.chapterIndex,
                nativeAd1: nativeAd1!,
                nativeAd2: nativeAd2!,
                onPageChanged: (index) {
                  double value = index.toDouble() + 1;
                  if (!(value == 1 || value == imageUrls.length + 2) && !isSliding) {
                    sliderValue == value;
                  }
                  pageIndex = index;
                  setState(() {});
                },
                onTapUp: (p0, p1, p2) => onTap(),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  onTap() {
    if (showAppBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    showAppBar = !showAppBar;
    setState(() {});
  }
}
