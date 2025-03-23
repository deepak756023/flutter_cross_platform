import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_credentials_sqflite/data/local/db_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _visibleIndex;
  TextEditingController titleController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<Map<String, dynamic>> allCredentials = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getCredentials();
  }

  Future<void> getCredentials() async {
    if (dbRef != null) {
      allCredentials = await dbRef!.getAllCredentials();
      setState(() {});
    }
  }

  String stars(String password) {
    return '*' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text("Password Credential")),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu), // Change to any icon
            onPressed: () {
              // Add functionality here
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 500,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Add Credential',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: "Enter title here",
                              label: const Text('Title'),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: userNameController,
                            decoration: InputDecoration(
                              hintText: "Enter username here",
                              label: const Text('Username'),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: "Enter password here",
                              label: const Text('Password'),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    var title = titleController.text;
                                    var userName = userNameController.text;
                                    var password = passwordController.text;
                                    if (title.isNotEmpty &&
                                        userName.isNotEmpty &&
                                        password.isNotEmpty) {
                                      dbRef!.addCredential(
                                        mTitle: title,
                                        mUserName: userName,
                                        mPassword: password,
                                      );
                                      setState(() {});
                                      titleController.text = '';
                                      userNameController.text = '';
                                      passwordController.text = '';
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        width: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  child: const Text("Add Credential"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        width: 1.2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbRef?.getAllCredentials(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No credentials stored yet!"));
          }

          List<Map<String, dynamic>> credentials = snapshot.data!;

          return ListView.builder(
            itemCount: credentials.length,
            itemBuilder: (BuildContext context, int index) {
              bool isVisible = _visibleIndex == index;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 193, 234, 241),
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'TITLE: ${credentials[index][DBHelper.COLUMN_TITLE_NAME]}',
                              style: const TextStyle(fontSize: 18),
                            ),

                            Container(
                              padding: EdgeInsets.only(left: 100),
                              child: IconButton(
                                onPressed: () {
                                  TextEditingController titleController =
                                      TextEditingController(
                                        text:
                                            credentials[index][DBHelper
                                                .COLUMN_TITLE_NAME],
                                      );
                                  TextEditingController userNameController =
                                      TextEditingController(
                                        text:
                                            credentials[index][DBHelper
                                                .COLUMN_USERNAME],
                                      );
                                  TextEditingController passwordController =
                                      TextEditingController(
                                        text:
                                            credentials[index][DBHelper
                                                .COLUMN_PASSWORD],
                                      );
                                  showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: 500,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: <Widget>[
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Update Credential',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    10.0,
                                                  ),
                                                  child: TextField(
                                                    controller: titleController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter title here",
                                                      label: const Text(
                                                        'Title',
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    10.0,
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        userNameController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter username here",
                                                      label: const Text(
                                                        'Username',
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    10.0,
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        passwordController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter password here",
                                                      label: const Text(
                                                        'Password',
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  11,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    10.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            var title =
                                                                titleController
                                                                    .text;
                                                            var userName =
                                                                userNameController
                                                                    .text;
                                                            var password =
                                                                passwordController
                                                                    .text;
                                                            if (title
                                                                    .isNotEmpty &&
                                                                userName
                                                                    .isNotEmpty &&
                                                                password
                                                                    .isNotEmpty) {
                                                              dbRef!.updateCurrency(
                                                                id:
                                                                    credentials[index][DBHelper
                                                                        .COLUMN_CREDENTIAL_ID],
                                                                mTitle: title,
                                                                mUserName:
                                                                    userName,
                                                                mPassword:
                                                                    password,
                                                              );
                                                              setState(() {});
                                                              titleController
                                                                  .text = '';
                                                              userNameController
                                                                  .text = '';
                                                              passwordController
                                                                  .text = '';
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            }
                                                          },
                                                          style: OutlinedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              side: const BorderSide(
                                                                width: 1.2,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Update Credential",
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          style: OutlinedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              side: const BorderSide(
                                                                width: 1.2,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ), // Added missing parenthesis here
                                                          ),
                                                          child: const Text(
                                                            "Cancel",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: IconButton(
                                onPressed:
                                    () => showDialog<String>(
                                      context: context,
                                      builder:
                                          (BuildContext context) => AlertDialog(
                                            title: const Text(
                                              'Confirmation?',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            content: Text.rich(
                                              TextSpan(
                                                text:
                                                    'Are you sure you want to delete ',
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${credentials[index][DBHelper.COLUMN_TITLE_NAME]}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' Credential?',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      'Cancel',
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  dbRef!.deleteCredential(
                                                    id:
                                                        credentials[index][DBHelper
                                                            .COLUMN_CREDENTIAL_ID],
                                                  );
                                                  getCredentials();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    ),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'USERNAME: ${credentials[index][DBHelper.COLUMN_USERNAME]}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Tooltip(
                                message: "Copy Username",
                                child: IconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            credentials[index][DBHelper
                                                .COLUMN_USERNAME],
                                      ),
                                    );

                                    // Show confirmation message
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Username copied to clipboard!",
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 250,
                              child: Text(
                                'PASSWORD: ${isVisible ? credentials[index]["password"] : stars(credentials[index]["password"])}',
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _visibleIndex = isVisible ? null : index;
                                });
                              },
                            ),
                          ],
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
}
