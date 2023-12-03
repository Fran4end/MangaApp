import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yomu_no_ikiru/Api/Adapter/mangaworld_adapter.dart';
import 'package:yomu_no_ikiru/Api/adapter.dart';
import 'package:yomu_no_ikiru/view/widgets/source_selector.dart';

import '../../constants.dart';
import '../../model/manga_builder.dart';
import '../widgets/manga_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final textController = TextEditingController();
  late String search;
  bool isSearching = false;
  final PagingController<int, MangaBuilder> pagingController = PagingController(firstPageKey: 1);
  late final StreamSubscription subscription;
  Timer? _debounce;
  MangaApiAdapter api = MangaWorldAdapter();

  @override
  void initState() {
    pagingController.addPageRequestListener((page) {
      _fetchData(page);
    });
    subscription = Connectivity().onConnectivityChanged.listen((connectivityResult) {
      if ((connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi) &&
          pagingController.itemList!.isEmpty) {
        pagingController.refresh();
      }
    });
    super.initState();
    textController.addListener(() {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      if (search != textController.text.trim().toLowerCase()) {
        _debounce = Timer(const Duration(milliseconds: 700), () {
          search = textController.text.trim().toLowerCase();
          pagingController.refresh();
        });
      }
    });
    search = "";
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Discover',
        ),
        actions: [
          isSearching
              ? PopupMenuButton(
                  icon: const Icon(FontAwesomeIcons.filter),
                  onSelected: (value) {
                    api = value;
                    setState(() {});
                    pagingController.refresh();
                  },
                  itemBuilder: (context) {
                    List<PopupMenuItem<MangaApiAdapter>> items = [];
                    for (SourceSelector source in sources) {
                      items.add(PopupMenuItem(value: source.mangaApi, child: source));
                    }
                    return items;
                  })
              : const Center(),
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => pagingController.refresh()),
        child: Column(
          children: [
            isSearching
                ? Container(
                    height: 50,
                    margin: const EdgeInsets.all(defaultPadding),
                    child: TextField(
                      controller: textController,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        labelText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              search = "";
                              textController.clear();
                              pagingController.refresh();
                            },
                            icon: const Icon(Icons.clear_rounded)),
                      ),
                    ),
                  )
                : const Center(),
            Expanded(
              child: MangaGrid(
                pagingController: pagingController,
                api: api,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _fetchData(int page) async {
    try {
      final newItems = await api.getResults(search, page);
      final isLastPage = newItems.length < api.pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        pagingController.appendPage(newItems, ++page);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }
}
