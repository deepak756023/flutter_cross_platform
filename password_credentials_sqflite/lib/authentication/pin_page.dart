import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_credentials_sqflite/authentication/auth_page.dart';
import 'package:password_credentials_sqflite/authentication/auth_service.dart';
import 'package:password_credentials_sqflite/authentication/pin_reset_page.dart';
import 'package:password_credentials_sqflite/data/local/db_helper.dart';
import 'package:password_credentials_sqflite/myhome_page.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  DBHelper? dbRef;

  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 130),
              const Text(
                'Unlock Credentials',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                'ENTER PIN',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      height: 68,
                      width: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          }
                        },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthPage(),
                        ),
                      );
                    },
                    child: const Text("CANCEL", style: TextStyle(fontSize: 20)),
                  ),
                  TextButton(
                    onPressed: _getPinValue,
                    child: const Text(
                      "CONFIRM",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: _showHelpSheet,
                child: const Text(
                  "CREATE/RESET PIN?",
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return Container(
          color: Colors.white,
          height: 340,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Unlock for PIN Set or Reset',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 50),
                IconButton(
                  onPressed: () async {
                    bool check = await AuthService().authenticateLocally();
                    if (check) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PinResetPage()),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Touch the fingerprint sensor',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _getPinValue() async {
    String? code = await dbRef?.getAuthCode();
    String pin = _controllers.map((controller) => controller.text).join();

    if (code == null || code.isEmpty) {
      _showSnackBar("Please Set the PIN for First Time");
      return;
    }

    if (pin.length < 4) {
      _showSnackBar("Please enter all 4 digits");
      return;
    }

    if (code != pin) {
      _showSnackBar("Wrong Pin");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
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
