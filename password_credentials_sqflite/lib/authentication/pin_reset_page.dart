import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_credentials_sqflite/authentication/pin_page.dart';
import 'package:password_credentials_sqflite/data/local/db_helper.dart';

class PinResetPage extends StatefulWidget {
  const PinResetPage({super.key});

  @override
  State<PinResetPage> createState() => _PinResetPageState();
}

class _PinResetPageState extends State<PinResetPage> {
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
  }

  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  final List<TextEditingController> _againController = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _againFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 100),
                  const Text('Reset/Set Pin', style: TextStyle(fontSize: 30)),
                  const SizedBox(height: 10),
                  const Text('ENTER PIN', style: TextStyle(fontSize: 15)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          height: 68,
                          width: 64,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 3) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_focusNodes[index + 1]);
                                } else {
                                  _focusNodes[index].unfocus();
                                }
                              }
                              setState(() {});
                            },
                            style: Theme.of(context).textTheme.headlineMedium,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('RE-ENTER PIN', style: TextStyle(fontSize: 15)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          height: 68,
                          width: 64,
                          child: TextField(
                            controller: _againController[index],
                            focusNode: _againFocusNodes[index],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 3) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_againFocusNodes[index + 1]);
                                } else {
                                  _againFocusNodes[index].unfocus();
                                }
                              }
                              setState(() {});
                            },
                            style: Theme.of(context).textTheme.headlineMedium,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PinPage()),
                      );
                    },
                    child: const Text("CANCEL", style: TextStyle(fontSize: 20)),
                  ),
                  TextButton(
                    onPressed: () {
                      _matchAndInputValidationPinValues();
                    },
                    child: const Text("SAVE", style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _matchAndInputValidationPinValues() {
    String pin = _controllers.map((c) => c.text).join();
    String confirmPin = _againController.map((c) => c.text).join();

    // Validation for incomplete PINs
    if (pin.length < 4 || confirmPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all 4 digits in both fields"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      return;
    }

    // Validation for mismatched PINs
    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PINs do not match"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      return;
    }

    // code = int.parse(pin);
    dbRef?.saveAuthCode(pin);

    // If validation passes, navigate
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PinPage()),
    );

    setState(() {});
  }
}
