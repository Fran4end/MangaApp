import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yomu_no_ikiru/controller/custom_exceptions.dart';
import 'package:yomu_no_ikiru/controller/utils.dart';

import '../model/manga.dart';
import '../model/manga_builder.dart';

class FileManager {
  static User? user = FirebaseAuth.instance.currentUser;

  static Future<List<File>> downloadAllFile(List<Reference> refs) async {
    List<File> files = [];
    for (var ref in refs) {
      try {
        final file = await downloadFile(ref);
        files.add(file);
      } catch (e) {
        if (kDebugMode) {
          print("Line 24: $e");
        }
      }
    }
    return files;
  }

  static Future<File> downloadFile(Reference ref) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/${user?.uid}/${ref.name}');
    bool fileExist = await file.exists();
    if (!fileExist) {
      file = await createFile(ref.name.replaceAll(".json", ""));
    }
    await ref.writeToFile(file);
    return file;
  }

  static Future<List<MangaBuilder>> readFileFromList(List<File> files) async {
    List<MangaBuilder> builders = [];
    for (var file in files) {
      final builder = await _readFile(file);
      builders.add(builder);
    }
    return builders;
  }

  static Future<MangaBuilder> _readFile(File file) async {
    final content = await file.readAsString();
    final json = jsonDecode(content);
    MangaBuilder builder = MangaBuilder()
      ..fromJson = json
      ..save = true;
    return builder;
  }

  static Future<List<MangaBuilder>> readPagedLocalFile(int page, int pageSize) async {
    if (user == null) {
      Utils.showSnackBar("You need to login before save on library");
      return [];
    }
    List<File> files = [];
    Directory dir = await getApplicationDocumentsDirectory();
    try {
      files = Directory("${dir.path}/${user?.uid}").listSync().map((e) => (e as File)).toList();
      final subList = files.sublist((page - 1) * pageSize, page * pageSize);
      return await readFileFromList(subList);
    } on RangeError {
      return await readFileFromList(files.sublist((page - 1) * pageSize));
    } on PathNotFoundException {
      if (kDebugMode) {
        print("No manga already saved");
      }
      Utils.showSnackBar("No manga already saved");
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Line 75: $e");
      }
      return [];
    }
  }

  static get getAllLocalFile async {
    Directory dir = await getApplicationDocumentsDirectory();
    try {
      return Directory("${dir.path}/${user?.uid}").listSync().map((e) => (e as File)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Line 91: $e");
      }
      return [];
    }
  }

  static Future<File> createFile(String title) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/${user?.uid}/$title.json');
    return await file.create(recursive: true);
  }

  static Future<File> writeFile(MangaBuilder builder) async {
    user = FirebaseAuth.instance.currentUser;
    Manga manga = builder.build();
    Directory dir = await getApplicationDocumentsDirectory();
    File jsonFile = File('${dir.path}/${user?.uid}/${builder.title}.json');
    bool fileExist = await jsonFile.exists();
    Map<String, dynamic> jsonFileContent = manga.toJson();
    if (!fileExist) {
      jsonFile = await createFile(builder.title);
    }
    await jsonFile.writeAsString(jsonEncode(jsonFileContent));
    return jsonFile;
  }

  static void delateAllLocalAndCloudFiles() async {
    List<File> files = await getAllLocalFile;
    for (var file in files) {
      bool fileExist = await file.exists();
      if (user == null) {
        if (kDebugMode) {
          print('user not logged');
        }
      } else {
        final title = basename(file.path);
        final ref = FirebaseStorage.instance.ref('${user?.uid}/$title');
        try {
          await ref.delete();
        } catch (e) {
          if (kDebugMode) {
            print("Line 108: $e");
          }
        }
      }
      if (fileExist) {
        await file.delete();
      }
    }
  }

  static void deleteFile(String title) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File jsonFile = File('${dir.path}/${user?.uid}/$title.json');
    bool fileExist = await jsonFile.exists();
    if (user == null) {
      if (kDebugMode) {
        print('user not logged');
      }
    } else {
      final ref = FirebaseStorage.instance.ref('${user?.uid}/$title.json');
      try {
        await ref.delete();
      } catch (e) {
        if (kDebugMode) {
          print("Line 108: $e");
        }
      }
    }
    if (fileExist) {
      await jsonFile.delete();
    }
  }

  static Future isOnLibrary(String title) async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null || title == '') {
      if (kDebugMode) {
        print("user not logged or file not valid");
      }
    } else {
      List<File> files = await FileManager.getAllLocalFile();

      try {
        final file =
            files.firstWhere((element) => basename(element.path).replaceAll(".json", "") == title);
        return await _readFile(file);
      } catch (e) {
        if (kDebugMode) {
          print("Line 149: $e");
          return throw FileNotOnLibraryException("no file found");
        }
      }
    }
    return throw FileNotOnLibraryException("no file found");
  }
}
