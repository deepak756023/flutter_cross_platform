import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:password_credentials_sqflite/authentication/pin_page.dart';
import 'package:password_credentials_sqflite/data/local/db_helper.dart';

class PinResetPage extends StatefulWidget {
  const PinResetPage({super.key});

  @override
  State<PinResetPage> createState() => _PinResetPageState();
}

class _PinResetPageState extends State<PinResetPage> {
  DBHelper? dbRef;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 64,
      height: 68,
      textStyle: const TextStyle(fontSize: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = pinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text('Reset/Set Pin', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 5),
            const Text('ENTER PIN', style: TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Pinput(
              controller: _pinController,
              length: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              defaultPinTheme: pinTheme,
              focusedPinTheme: focusedPinTheme,
              separatorBuilder: (index) => const SizedBox(width: 16),
            ),
            const SizedBox(height: 20),
            const Text('RE-ENTER PIN', style: TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Pinput(
              controller: _confirmPinController,
              length: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              defaultPinTheme: pinTheme,
              focusedPinTheme: focusedPinTheme,
              separatorBuilder: (index) => const SizedBox(width: 16),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinPage(),
                        ),
                      );
                    },
                    child: const Text("CANCEL", style: TextStyle(fontSize: 20)),
                  ),
                  TextButton(
                    onPressed: _matchAndInputValidationPinValues,
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
    String pin = _pinController.text;
    String confirmPin = _confirmPinController.text;

    if (pin.length < 4 || confirmPin.length < 4) {
      _showSnackBar("Please enter all 4 digits in both fields");
      return;
    }

    if (pin != confirmPin) {
      _showSnackBar("PINs do not match");
      return;
    }

    dbRef?.saveAuthCode(pin);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PinPage()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.only(bottom: 280),
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
