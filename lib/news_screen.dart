import 'package:count_up_app/news_webview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api/news_api.dart';
import 'article.dart';
import 'model/news.dart';
import 'model/news_result.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Dio _dio = Dio();
  late final NewsApi _newsApi;
  List<Article>? _article;

  //final List<Article> _favorites = [];

  @override
  void initState() {
    super.initState();
    _newsApi = NewsApi(_dio);
    getNews();
  }

  Future<void> getNews() async {
    final apiKey = dotenv.env['NEWS_API_KEY'];
    if (apiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('APIキーが設定されていません'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    await _newsApi.getNews(apiKey).then(
      (NewsResult response) {
        // Convert the list of News objects to a list of Article objects.
        final articles = response.articles?.map((News news) {
          return Article(
            title: news.title ?? '',
            url: news.url ?? '',
          );
        }).toList();
        setState(() {
          _article =
              articles; // Now we are setting _articles (of type List<Article>)
        });
      },
      onError: (dynamic e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ニュースが取得できません: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ニュース一覧'),
        leading: IconButton(
          icon: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          onPressed: () async {
            // await Navigator.push(
            //   context,
            //   MaterialPageRoute<Widget>(
            //     builder: (context) => FavoriteNewsScreen(
            //       favorites: _article,
            //     ),
            //   ),
            // ).catchError((dynamic e) {
            //   return AlertDialog(
            //     title: const Text('ニュースを表示できません'),
            //     content: Text(e.toString()),
            //     actions: [
            //       TextButton(
            //         onPressed: () {
            //           Navigator.of(context).pop();
            //         },
            //         child: const Text('閉じる'),
            //       ),
            //     ],
            //   );
            // });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getNews,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: getNews,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Flexible(
              child: SafeArea(
                child: ListView.separated(
                  itemCount: _article?.length ?? 0,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemBuilder: (context, index) {
                    final title = _article?[index].title;
                    return ListTile(
                      title: Text(
                        title ?? 'ニュースがありません',
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() {
                            _article?[index].isFavorite =
                                !_article![index].isFavorite;
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          color: _article![index].isFavorite
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      onTap: () async {
                        final url = _article?[index].url;
                        if (url != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<Widget>(
                              builder: (context) => NewsWebView(
                                url: url,
                              ),
                            ),
                          ).catchError((dynamic e) {
                            return AlertDialog(
                              title: const Text('ニュースを表示できません'),
                              content: Text(e.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('閉じる'),
                                ),
                              ],
                            );
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
