import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';

import '../../constants.dart';
import '../../controller/firebase_controller.dart';
import '../../controller/file_manager.dart';
import '../../model/manga_builder.dart';
import '../../controller/utils.dart';
import '../widgets/manga_widget.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final PagingController<int, MangaBuilder> pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((page) {
      _fetchData(page);
    });
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
        ),
        actions: [
          IconButton(
            onPressed: () {
              _syncLibrary();
              refresh.input!.change(true);
              Future.delayed(const Duration(seconds: 1), () {
                refresh.input!.change(false);
              });
            },
            icon: SizedBox(
              width: 36,
              height: 36,
              child: RiveAnimation.asset(
                refresh.src,
                artboard: refresh.artboard,
                onInit: (artboard) {
                  StateMachineController controller =
                      Utils.getRiveController(artboard, stateMachineName: refresh.stateMachineName);
                  refresh.input = controller.findSMI("active");
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              FileManager.delateAllLocalAndCloudFiles();
              pagingController.refresh();
            },
            icon: SizedBox(
              width: 36,
              height: 36,
              child: RiveAnimation.asset(
                cycleBin.src,
                artboard: cycleBin.artboard,
                onInit: (artboard) {
                  StateMachineController controller = Utils.getRiveController(artboard,
                      stateMachineName: cycleBin.stateMachineName);
                  cycleBin.input = controller.findSMI("active");
                },
              ),
            ),
            /* Stack(
              alignment: Alignment.topCenter,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Icon(FontAwesomeIcons.trash),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        "ALL",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )),
              ],
            ),*/
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => pagingController.refresh()),
        child: Padding(
          padding: const EdgeInsets.only(top: defaultPadding),
          child: MangaGrid(
            pagingController: pagingController,
            save: true,
            tag: "library",
          ),
        ),
      ),
    );
  }

  Future _fetchData(int page) async {
    try {
      final newItems = await FileManager.readPagedLocalFile(page, 20);
      final isLastPage = newItems.length < 20;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        pagingController.appendPage(newItems, ++page);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  Future _syncLibrary() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Directory dir = await getApplicationDocumentsDirectory();
      try {
        List<File> files =
            Directory("${dir.path}/${user.uid}").listSync().map((e) => (e as File)).toList();
        for (var file in files) {
          if (mounted) {
            await FirebaseController.uploadJson(file, context);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Line 97: $e");
        }
      } finally {
        FirebaseController.downloadJson()
            .then((refs) => FileManager.downloadAllFile(refs).then((files) {
                  pagingController.refresh();
                }));
      }
    } else {
      Utils.showSnackBar('You need to login before sync all manga');
    }
  }
}
