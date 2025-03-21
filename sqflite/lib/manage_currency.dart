import 'package:currency_converter_sqflite/add_currency.dart';
import 'package:currency_converter_sqflite/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class ManageCurrency extends StatefulWidget {
  const ManageCurrency({super.key});

  @override
  State<ManageCurrency> createState() => _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState extends State<ManageCurrency> {
  List<Map<String, dynamic>> allCurrencies = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getCurrencies();
  }

  void getCurrencies() async {
    allCurrencies = await dbRef!.getAllCurrencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        stream: Stream.periodic(const Duration(seconds: 0)),
        builder: (context, snapshot) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: dbRef!.getAllCurrencies(),
            builder: (context, futureSnapshot) {
              if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                return const Center(child: Text("No Currencies yet!!!"));
              }

              List<Map<String, dynamic>> allCurrencies = futureSnapshot.data!;

              return ListView.builder(
                itemCount: allCurrencies.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 228, 241, 117),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Country: ${allCurrencies[index][DBHelper.COLUMN_COUNTRY_NAME]}',
                            ),
                            Text(
                              'Name: ${allCurrencies[index][DBHelper.COLUMN_CURRENCY_NAME]}',
                            ),
                            Text(
                              'Exchange Rate (\$): ${double.tryParse(allCurrencies[index][DBHelper.COLUMN_EXCHANGE_RATE].toString()) ?? 0.0}',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showUpdateDialog(allCurrencies[index]);
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                dbRef!.deleteCurrency(
                                  mCountry:
                                      allCurrencies[index][DBHelper
                                          .COLUMN_COUNTRY_NAME],
                                );
                                getCurrencies();
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void showUpdateDialog(Map<String, dynamic> currency) {
    TextEditingController countryController = TextEditingController(
      text: currency[DBHelper.COLUMN_COUNTRY_NAME],
    );
    TextEditingController currencyController = TextEditingController(
      text: currency[DBHelper.COLUMN_CURRENCY_NAME],
    );
    TextEditingController exchangeRateController = TextEditingController(
      text: currency[DBHelper.COLUMN_EXCHANGE_RATE].toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    Expanded(
                      child: const Text(
                        "    Update Currency",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 149, 24, 227),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  countryController.text,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: TextStyle(fontSize: 20),
                  controller: currencyController,
                  decoration: InputDecoration(
                    labelText: "Currency Name",
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: TextStyle(fontSize: 20),
                  controller: exchangeRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Exchange Rate",
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (countryController.text.isEmpty ||
                        currencyController.text.isEmpty ||
                        exchangeRateController.text.isEmpty) {
                      return;
                    }

                    await dbRef!.updateCurrency(
                      mCountry: countryController.text,
                      mCurrency: currencyController.text,
                      mExchangeRate: double.parse(exchangeRateController.text),
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
