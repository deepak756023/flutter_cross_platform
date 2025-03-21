import 'package:currency_converter_sqflite/data/local/db_helper.dart';
import 'package:currency_converter_sqflite/manage_currency.dart';
import 'package:flutter/material.dart';

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});
  @override
  State<CurrencyConverterMaterialPage> createState() {
    return _CurrencyConverterMaterialPageState();
  }
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  List<String> fromDropdownItems = [];
  String fromSelectedValue = 'USD';
  String toSelectedValue = 'INR';
  double fromExchangeRate = 1.0;
  double toExchangeRate = 87.0;
  double topResult = 1;

  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getCurrenciesNames();
  }

  void getCurrenciesNames() async {
    //getCurrenciesNames();
    fromDropdownItems = await dbRef!.getAllCurrenciesNames();
    setState(() {});
  }

  void getFromExchangeRate(String fromSelectedValue) async {
    fromExchangeRate = await dbRef!.getExchangeRate(fromSelectedValue);
    setState(() {});
  }

  void getToExchangeRate(String toSelectedValue) async {
    toExchangeRate = await dbRef!.getExchangeRate(toSelectedValue);
    setState(() {});
  }

  double result = 0;
  double dollar = 0;

  double getDollar(String fromSelectedValue, double amount) {
    return amount / fromExchangeRate;
  }

  double getToOutput(String toSelectedValue) {
    return dollar * toExchangeRate;
  }

  double getTopOutput() {
    return toExchangeRate / fromExchangeRate;
  }

  String formatNumber(double num, int maxDecimals) {
    String str = num.toStringAsFixed(maxDecimals);
    double parsedNum = double.parse(str);
    return parsedNum == parsedNum.toInt()
        ? parsedNum.toInt().toString()
        : parsedNum.toString();
  }

  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    topResult = getTopOutput();
    final border = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.black,
        width: 2,
        style: BorderStyle.solid,
        // strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 209, 142, 245),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageCurrency()),
          );
        },
        label: const Text('Manage Currency'),
        icon: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      backgroundColor: const Color.fromARGB(255, 144, 199, 190),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 80, 189, 171),
        title: Text(
          'Currency Converter',
          style: TextStyle(
            fontSize: 30,
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 30,
                      color: Color.fromARGB(255, 244, 246, 246),
                    ),
                    onPressed: () {
                      setState(() {
                        getCurrenciesNames();
                      });
                    },
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.only(bottom: 27, top: 40),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '1 $fromSelectedValue = ', // Normal INR
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: topResult.toStringAsFixed(2),
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                      TextSpan(
                        text: ' $toSelectedValue',
                        style: TextStyle(fontSize: 30, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100, // Set width
                      height: 60, // Set height
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Rounded corners
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ), // Border
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          iconSize: 40,
                          value: fromSelectedValue, // Ensured non-null value
                          items:
                              fromDropdownItems
                                  .where((value) => value != toSelectedValue)
                                  .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  })
                                  .toList(),

                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              // Ensure non-null value before updating
                              setState(() {
                                fromSelectedValue = newValue;
                                debugPrint(fromSelectedValue);
                                getFromExchangeRate(fromSelectedValue);
                              });
                            }
                          },

                          underline: SizedBox(),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),

                        decoration: InputDecoration(
                          enabled: true,
                          label: Align(
                            alignment:
                                Alignment
                                    .topLeft, // Ensures the label stays at the top
                            child: Text(
                              'Convert From',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 5, 66, 235),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          hintText: 'ENTER THE AMOUNT',
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
                    ),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 35),
                child: Icon(
                  Icons.south, // Downward arrow icon
                  size: 30.0, // Icon size
                  color: Colors.black, // Icon color
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 13),
                      width: 100, // Set width
                      height: 60, // Set height
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Rounded corners
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ), // Border
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          iconSize: 40,
                          value: toSelectedValue, // Ensured non-null value
                          items:
                              fromDropdownItems
                                  .where((value) => value != fromSelectedValue)
                                  .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  })
                                  .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              // Ensure non-null value before updating
                              setState(() {
                                toSelectedValue = newValue;
                                debugPrint(toSelectedValue);
                                getToExchangeRate(toSelectedValue);
                              });
                            }
                          },
                          underline: SizedBox(),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          // Label for the TextField
                          enabled: false,
                          label: Text(
                            formatNumber(result, 3), // Dynamically show result
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    dollar = getDollar(
                      fromSelectedValue,
                      double.parse(textEditingController.text),
                    );
                    result = getToOutput(toSelectedValue);
                  });
                },

                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color.fromARGB(255, 10, 91, 230),
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  minimumSize: WidgetStatePropertyAll(
                    Size(double.infinity, 50),
                  ),

                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                child: const Text(
                  'Convert',
                  // style: TextStyle(color: Colors.white),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      result = 0;
                      textEditingController.text = '';
                      dollar = 0;
                    });
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color.fromARGB(255, 10, 91, 230),
                    ),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    minimumSize: WidgetStatePropertyAll(
                      Size(double.infinity, 50),
                    ),

                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Clear',
                    // style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              //
              // FloatingActionButton.extended(

              //   backgroundColor: const Color.fromARGB(255, 198, 242, 242),
              //   onPressed: () {
              //     setState(() {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const ManageCurrency(),
              //         ),
              //       );
              //     });
              //   },
              //   label: const Text('Manage Currency'),
              //   icon: const Icon(Icons.edit),

              // ),
            ],
          ),
        ),
      ),
    );
  }
}
