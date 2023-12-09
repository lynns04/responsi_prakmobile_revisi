import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lintang_responsi_ppam/model/detail_models.dart';
import 'package:url_launcher/url_launcher.dart';

class HalamanDetail extends StatefulWidget {
  final String id;
  const HalamanDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  late Future<List<DetailMeal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = fetchMeals();
  }

  Future<List<DetailMeal>> fetchMeals() async {
    final response = await http.get(Uri.parse(
        "https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.id}"));
    if (response.statusCode == 200) {
      List<DetailMeal> meals = (json.decode(response.body)['meals'] as List)
          .map((data) => DetailMeal.fromJson(data))
          .toList();
      return meals;
    } else {
      throw Exception('Failed Load Detail Meals');
    }
  }

  Widget _buildIngredients(List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ...ingredients.map((ingredient) => Text(
          ingredient,
          style: TextStyle(fontSize: 16),
        )),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInstructions(String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Instructions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          instructions,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent[100],
        centerTitle: true,
        title: Text("Meal Detail"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.075),
          child: FutureBuilder<List<DetailMeal>>(
            future: _meals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No meals found.'),
                );
              } else {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.075),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    snapshot.data![0].strMealThumb)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        Text(
                          "${snapshot.data![0].strMeal}",
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          " Area : ${snapshot.data![0].strArea}   Category : ${snapshot.data![0].strCategory}",
                          style: TextStyle(fontSize: 18),
                        ),

                        SizedBox(
                          height: 20,
                        ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIngredients([
                                snapshot.data![0].strIngredient1,
                                snapshot.data![0].strIngredient2,
                                snapshot.data![0].strIngredient3,
                                snapshot.data![0].strIngredient4,
                                snapshot.data![0].strIngredient5,
                                snapshot.data![0].strIngredient6,
                                snapshot.data![0].strIngredient7,
                                snapshot.data![0].strIngredient8,
                              ]),
                              _buildInstructions(snapshot.data![0].strInstructions),
                              SizedBox(height: 20),


                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple.shade100),
                                ),

                                onPressed: () {
                                  _launchYoutube("${snapshot.data![0].strYoutube}");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      color: Colors.purple,
                                    ),
                                    Text(
                                      "Watch Tutorial",
                                      style: TextStyle(
                                          color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchYoutube(String url) async {
    final Uri _url = Uri.parse(url);
    try {
      await launch(_url.toString());
    } catch (e) {
      print('Error launching URL: $_url');
      print('Error details: $e');
      throw Exception('Failed to open link: $_url');
    }
  }
}
