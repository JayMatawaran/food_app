import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:food_app/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CarouselImage()),

          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Container(
                height: 100,
                width: double.infinity,
                color: AppColors.airforceBlue.withAlpha((0.7 * 255).round()),
                child: Center(
                  child: Text(
                    'Touch to start',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarouselImage extends StatefulWidget {
  const CarouselImage({super.key});

  @override
  CarouselImageState createState() => CarouselImageState();
}

class CarouselImageState extends State<CarouselImage> {
  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/JayMatawaran/APIs/refs/heads/main/logo.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> recipes = data['users'];

        final filteredRecipes =
        recipes.where((recipe) => [2, 4, 7].contains(recipe['id'])).toList();

        setState(() {
          imageUrls = filteredRecipes.map((recipe) => recipe['image'] as String).toList();
          isLoading = false;
        });
      }
      else {
        throw Exception('Failed to load images');
      }
    }
    catch (e) {
      setState(() {
        isLoading = false;
      });
      SnackBar(
        content: Text('Error: $e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
      ),
      items: imageUrls.map((imageUrl) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
