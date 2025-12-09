import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailsPage extends StatefulWidget {
  final DocumentSnapshot articleData;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  ArticleDetailsPage({required this.articleData});

  @override
  // ignore: library_private_types_in_public_api
  _ArticleDetailsPageState createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = widget.articleData['ArticleSave'];
  }

  void toggleSave() async {
    setState(() {
      isSaved = !isSaved;
    });

    await widget.articleData.reference.update({
      'ArticleSave': isSaved,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF355B8C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.articleData['ArticleSubject'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: toggleSave,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.articleData['Articleimg']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.articleData['ArticleContent'],
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}