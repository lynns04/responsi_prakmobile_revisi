import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lintang_responsi_ppam/meals.dart';
import 'package:lintang_responsi_ppam/model/categori_models.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

Future<List<Category>> fetchCategories() async {
  final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
  if (response.statusCode == 200) {
    List<Category> categories = (json.decode(response.body)['categories'] as List)
        .map((data) => Category.fromJson(data))
        .toList();
    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Meal Categories",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
          child: Center(
            child: FutureBuilder<List<Category>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.map((category) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HalamanCategory(category: category.strCategory)));
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 50), // Add margin for spacing
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.width * 0.6,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(category.strCategoryThumb),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        category.strCategory,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(category.strCategoryDescription),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
