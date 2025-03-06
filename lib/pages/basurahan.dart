import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MerchantSelectionApp());
}

class MerchantSelectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merchant Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MerchantSelectionScreen(),
    );
  }
}

class MerchantSelectionScreen extends StatefulWidget {
  @override
  _MerchantSelectionScreenState createState() => _MerchantSelectionScreenState();
}

class _MerchantSelectionScreenState extends State<MerchantSelectionScreen> {
  List<dynamic> merchants = [];
  List<dynamic> posList = [];
  String? selectedMerchant;
  String? selectedPos;
  bool isMerchantSelected = false;
  bool isPosSelected = false;

  @override
  void initState() {
    super.initState();
    fetchMerchants();
  }

  Future<void> fetchMerchants() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/JayMatawaran/APIs/refs/heads/main/merchants%26pos.json'));
    if (response.statusCode == 200) {
      setState(() {
        merchants = json.decode(response.body)['merchants'];
      });
    } else {
      throw Exception('Failed to load merchants');
    }
  }

  void onMerchantSelected(String merchant) {
    setState(() {
      selectedMerchant = merchant;
      isMerchantSelected = true;
      selectedPos = null;
      isPosSelected = false;
      posList = merchants.firstWhere((m) => m['merchant_name'] == merchant)['pos_systems'];
    });
  }

  void onPosSelected(String pos) {
    setState(() {
      selectedPos = pos;
      isPosSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return MerchantSelectionPanel(
                      merchants: merchants,
                      onMerchantSelected: onMerchantSelected,
                    );
                  },
                );
              },
              child: Text('Select Merchant'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isMerchantSelected
                  ? () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return PosSelectionPanel(
                      posList: posList,
                      onPosSelected: onPosSelected,
                    );
                  },
                );
              }
                  : null,
              child: Text('Select POS'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isPosSelected ? () {} : null,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class MerchantSelectionPanel extends StatelessWidget {
  final List<dynamic> merchants;
  final Function(String) onMerchantSelected;

  MerchantSelectionPanel({
    required this.merchants,
    required this.onMerchantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final merchant = merchants[index]['merchant_name'];
        return ListTile(
          title: Text(merchant),
          onTap: () {
            onMerchantSelected(merchant);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class PosSelectionPanel extends StatelessWidget {
  final List<dynamic> posList;
  final Function(String) onPosSelected;

  PosSelectionPanel({
    required this.posList,
    required this.onPosSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posList.length,
      itemBuilder: (context, index) {
        final pos = posList[index]['pos_name'];
        return ListTile(
          title: Text(pos),
          onTap: () {
            onPosSelected(pos);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
