import 'package:flutter/material.dart';
import 'package:food_app/color.dart';
import 'package:food_app/pages/login_page.dart';
import 'package:food_app/pages/welcome_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantPage extends StatefulWidget {
  const MerchantPage({super.key});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  List<dynamic> merchants = [];
  List<dynamic> posSystems = [];
  dynamic selectedMerchant;
  dynamic selectedPOS;
  bool isPOSEnabled = false;
  bool isContinueEnabled = false;
  String searchMerchantQuery = '';
  String searchPOSQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMerchants();
  }

  Future<void> fetchMerchants() async {
    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/JayMatawaran/APIs/refs/heads/main/merchants%26pos.json'));
      if (response.statusCode == 200) {
        setState(() {
          merchants = json.decode(response.body)['merchants'];
          print('Merchants loaded: ${merchants.length}'); // Debug print
        });
      } else {
        throw Exception('Failed to load merchants');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showMerchantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Merchant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchMerchantQuery = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Container(
                  constraints: BoxConstraints(maxHeight: 200), // Constrain height
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(), // Prevent scrolling issues
                    itemCount: merchants.length,
                    itemBuilder: (context, index) {
                      final merchant = merchants[index];
                      if (searchMerchantQuery.isNotEmpty &&
                          !merchant['merchant_name']
                              .toLowerCase()
                              .contains(searchMerchantQuery.toLowerCase())) {
                        return SizedBox.shrink(); // Hide non-matching items
                      }
                      return ListTile(
                        title: Text(merchant['merchant_name']),
                        onTap: () {
                          setState(() {
                            selectedMerchant = merchant;
                            posSystems = merchant['pos_systems'];
                            isPOSEnabled = true;
                            isContinueEnabled = false;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select POS'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchPOSQuery = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Container(
                  constraints: BoxConstraints(maxHeight: 200), // Constrain height
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(), // Prevent scrolling issues
                    itemCount: posSystems.length,
                    itemBuilder: (context, index) {
                      final pos = posSystems[index];
                      if (searchPOSQuery.isNotEmpty &&
                          !pos['pos_name']
                              .toLowerCase()
                              .contains(searchPOSQuery.toLowerCase())) {
                        return SizedBox.shrink(); // Hide non-matching items
                      }
                      return ListTile(
                        title: Text(pos['pos_name']),
                        onTap: () {
                          setState(() {
                            selectedPOS = pos;
                            isContinueEnabled = true;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.8;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 150, width: 150),
                SizedBox(height: 40),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      _showMerchantDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.jet,
                    ),
                    child: Text(
                      'Select Merchant',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isPOSEnabled ? () {
                      _showPOSDialog(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: isPOSEnabled ? AppColors.jet : Colors.grey,
                    ),
                    child: Text(
                      'Select POS',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: isContinueEnabled ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: isContinueEnabled ? AppColors.airforceBlue : Colors.grey,
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}