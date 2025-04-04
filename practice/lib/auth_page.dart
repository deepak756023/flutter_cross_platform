import 'package:flutter/material.dart';
import 'package:practice/auth_service.dart';
import 'package:practice/credential_page.dart';
import 'package:practice/pin_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSheet();
    });
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return Container(
          color: Colors.white,
          height: 400,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Unlock Credentials',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 80),
                IconButton(
                  onPressed: () async {
                    bool check = await AuthService().authenticateLocally();
                    if (check) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CredentialPage(),
                        ),
                      );
                      //Navigator.pop(context);
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
                  'Touch the fingerprint icon',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PinPage()),
                    );
                  },
                  child: const Text("USE PIN", style: TextStyle(fontSize: 20)),
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
    return Scaffold();
  }
}
