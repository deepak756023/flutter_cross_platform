import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:curr_converter/add_currency.dart';

class ManageCurrency extends StatefulWidget {
  const ManageCurrency({super.key});

  @override
  State<ManageCurrency> createState() => _ManageCurrencyState();
}

class _ManageCurrencyState extends State<ManageCurrency> {
  final TextEditingController currencyNameController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();
  final TextEditingController exchangeRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 112, 189, 240),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCurrency()),
          );
        },
        label: const Text(
          'Add Currency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 174, 115, 236),
        title: const Text(
          'Manage Currency',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("currencies").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Data Available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var doc = snapshot.data!.docs[index];

              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 228, 241, 117),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Country: ${doc['country']}', style: textStyle),
                        Text('Name: ${doc['name']}', style: textStyle),
                        Text('Exchange Rate (\$): ${doc['exchangeRate']}', style: textStyle),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            countryNameController.text = doc['country'];
                            currencyNameController.text = doc['name'];
                            double exchangeRate = (doc['exchangeRate'] as num).toDouble();
                            exchangeRateController.text = exchangeRate.toString();
                            updateCurrencyDetails(doc.id);
                          },
                          child: const Icon(Icons.edit, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection("currencies").doc(doc.id).delete();
                          },
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future updateCurrencyDetails(String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.cancel),
                  ),
                  const Text(
                    "Update Currency",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(controller: currencyNameController),
              const SizedBox(height: 20),
              TextField(controller: countryNameController),
              const SizedBox(height: 20),
              TextField(controller: exchangeRateController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (currencyNameController.text.isEmpty || countryNameController.text.isEmpty || exchangeRateController.text.isEmpty) {
                    return;
                  }
                  Map<String, dynamic> updateInfo = {
                    "country": countryNameController.text,
                    "name": currencyNameController.text,
                    "exchangeRate": double.parse(exchangeRateController.text),
                  };
                  await updateCurrency(id, updateInfo);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Update", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

  Future<void> updateCurrency(String id, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance.collection("currencies").doc(id).update(updateInfo);
  }
}
