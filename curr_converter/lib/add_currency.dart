import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCurrency extends StatefulWidget {
  const AddCurrency({super.key});

  @override
  State<AddCurrency> createState() => _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState extends State<AddCurrency> {
  final TextEditingController currencyNameController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();

  final TextEditingController exchangeRateController = TextEditingController();

  Future<void> uploadCurrency() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot querySnapshot =
          await firestore
              .collection('currencies')
              .where(
                'country',
                isEqualTo: currencyNameController.text.toUpperCase().trim(),
              )
              .get();
      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("currencies").add({
          "name": currencyNameController.text.toUpperCase().trim(),
          "country": countryNameController.text.trim(),
          "exchangeRate": double.parse(exchangeRateController.text),
        });
        debugPrint("Currency Added Successfully");
      } else {
        debugPrint("Country Already Exists");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 2),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 190, 234),
        title: const Text(
          'Add Currency',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 50), // Add spacing at the top
            // Name of the Currency
            TextField(
              controller: currencyNameController,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Name of the Currency',
                hintStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: border,
                enabledBorder: border,
              ),
            ),

            const SizedBox(height: 20), // Add spacing between fields
            // Name of the Country
            TextField(
              controller: countryNameController,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Name of the Country',
                hintStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: border,
                enabledBorder: border,
              ),
            ),

            const SizedBox(height: 20),

            // Exchange Rate
            TextField(
              controller: exchangeRateController,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Exchange Rate wrt Dollar',
                hintStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: border,
                enabledBorder: border,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 50),

            // Row for Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clear Button
                SizedBox(
                  width: 100,
                  child: TextButton(
                    onPressed: () {
                      currencyNameController.text = '';
                      countryNameController.text = '';
                      exchangeRateController.text = '';
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 104, 104),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Clear', style: TextStyle(fontSize: 20)),
                  ),
                ),

                const SizedBox(width: 20), // Add spacing between buttons
                // Save Button
                SizedBox(
                  width: 100,
                  child: TextButton(
                    onPressed: () async {
                      await uploadCurrency();

                       Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 232, 221),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
