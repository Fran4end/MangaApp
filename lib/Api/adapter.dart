import 'package:html/dom.dart';
import 'package:yomu_no_ikiru/model/manga_builder.dart';

abstract class MangaApiAdapter {
  final String type = "";
  final int pageSize = 16;
  Future<MangaBuilder> getDetails(MangaBuilder builder, [String link = ""]);
  Future<double> getVote(MangaBuilder builder);
  Future<List<MangaBuilder>> getResults(String keyword, [int page = 1]);
  Future<List<String>> getImageUrls(Document source);
  Map<String, dynamic> toJson() {
    return {"type": type};
  }

  bool hasNewChapter(MangaBuilder manga);
}
