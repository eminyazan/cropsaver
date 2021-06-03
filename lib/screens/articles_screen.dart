import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';

import '../common/loading_screen.dart';
import '../bases/articles_base.dart';
import '../common/custom_button.dart';
import '../common/screen_sizes.dart';
import '../db/database_base.dart';

class ArticlesScreen extends StatefulWidget {
  final String lanCode;

  const ArticlesScreen({Key key, @required this.lanCode}) : super(key: key);

  @override
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  Database _database = Database();

  List<Article> _articles = [];

  var head = tr("articles");

  @override
  void initState() {
    super.initState();
    _getArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(head),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent.shade200,
      ),
      body: _articles.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _articles.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return Card(
                          elevation: 20,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  widget.lanCode != "tr"
                                      ? _articles[index].head
                                      : _articles[index].trHead,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: pageHeight * 0.2,
                                    width: pageWidth * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              _articles[index].url),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: pageWidth *0.5,
                                      child: AutoSizeText(
                                        widget.lanCode != "tr"
                                            ? _articles[index].body
                                            : _articles[index].trBody,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  _articles.length<8?CustomButton(
                    buttonIcon: Icon(
                      Icons.article_outlined,
                      color: Colors.white,
                    ),
                    buttonText: "load_more".tr(),
                    buttonColor: Colors.lightBlueAccent.shade200,
                    onPressed: () => _loadMoreArticle(_articles.last.id),
                  ):SizedBox(),
                ],
              ),
            )
          : LoadingScreen(),
    );
  }

  void _getArticles() async {
    _articles = await _database.getArticles();
    if (_articles.isNotEmpty) {
      setState(() {});
    }
  }

  _loadMoreArticle(int lastId) async {
    List<Article> _moreArticle;
    _moreArticle = await _database.loadMoreArticle(lastId);
    _articles.addAll(_moreArticle);
    setState(() {});
  }
}
