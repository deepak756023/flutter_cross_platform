import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_credentials_sqflite/authentication/auth_page.dart'
    as authentication;
import 'package:password_credentials_sqflite/data/local/db_helper.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/src/painting/text_span.dart' as textSpan;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool _obscureText;
  late bool _obscureTextUpdate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var title = titleController.text;
      var userName = userNameController.text;
      var password = passwordController.text;
      if (title.isNotEmpty && userName.isNotEmpty && password.isNotEmpty) {
        dbRef!.addCredential(
          mTitle: title,
          mUserName: userName,
          mPassword: password,
        );
        setState(() {});
        titleController.text = '';
        userNameController.text = '';
        passwordController.text = '';
        getCredentials();
        Navigator.pop(context);
      }
    }
  }

  String? _validateTitle(value) {
    if (value!.isEmpty) {
      return 'Please enter a Title';
    }
    if (value.toString().length > 20) {
      return 'allows less than 20 chars';
    }
    return null;
  }

  String? _validateUsername(value) {
    if (value!.isEmpty) {
      return 'Please enter a Username';
    }
    if (value.toString().length > 30) {
      return 'allows less than 30 chars';
    }
    return null;
  }

  String? _validatePassword(value) {
    if (value!.isEmpty) {
      return 'Please enter a Password';
    }
    if (value.toString().length > 30) {
      return 'allows less than 30 chars';
    }
    return null;
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> dataList) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue("TITLE");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = TextCellValue("USERID");
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = TextCellValue("PASSWORD");
    // Append each value as a row
    for (int i = 0; i < dataList.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(dataList[i][DBHelper.COLUMN_TITLE_NAME]);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(dataList[i][DBHelper.COLUMN_USERNAME]);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(dataList[i][DBHelper.COLUMN_PASSWORD]);
    }

    List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      Directory directory = Directory('/storage/emulated/0/Download');
      String filePath = '${directory.path}/password_credentials.xlsx';

      File file = File(filePath);
      await file.writeAsBytes(fileBytes);

      print('Excel file saved at: $filePath');
      await OpenFilex.open(filePath); // Open file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        leading: Container(),
        backgroundColor: const Color.fromARGB(255, 160, 196, 231),
        title: const Center(child: Text("My Credentials")),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert), // Your icon here
            onSelected: (value) {
              if (value == "Export") {
                exportToExcel(allCredentials);
              }
              if (value == "Import") {
                showDialog<String>(
                  context: context,
                  builder:
                      (BuildContext context) => AlertDialog(
                        title: const Text(
                          'Coming Soon!!!',
                          style: TextStyle(fontSize: 30),
                        ),
                        content: const Text(
                          'This feature is yet to be developed. Stay tuned...',
                          style: TextStyle(fontSize: 20),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
              if (value == "Logout") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => authentication.AuthPage(),
                  ),
                );
              }
            },

            offset: Offset(0, 45), // Adjust this value to position the dropdown
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: "Export",
                    child: Row(
                      children: [
                        Text("Export"),
                        SizedBox(width: 15), // Space between icon and text
                        Icon(Icons.arrow_circle_up),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Import",
                    child: Row(
                      children: [
                        Text("Import"),
                        SizedBox(width: 15), // Space between icon and text
                        Icon(Icons.arrow_circle_down),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Logout",
                    child: Row(
                      children: [
                        Text("Logout"),
                        SizedBox(width: 15), // Space between icon and text
                        Icon(Icons.logout),
                      ],
                    ),
                  ),
                ],
          ),
          // IconButton(
          //   icon: const Icon(Icons.share), //Icons.more_vert
          //   onPressed: () {
          //     exportToExcel(allCredentials);
          //   },
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _obscureText = true;
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return FractionallySizedBox(
                    heightFactor: 0.9,
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Form(
                        key: _formKey,
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
                                  child: TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                      hintText: "Enter title here",
                                      labelText: 'Title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                    ),
                                    validator: _validateTitle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    controller: userNameController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Username here",
                                      labelText: 'Username',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                    ),
                                    validator: _validateUsername,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    obscureText: _obscureText,
                                    obscuringCharacter: '*',
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Password here",
                                      labelText: 'Password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  252,
                                                  84,
                                                  84,
                                                ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            side: const BorderSide(
                                              width: 0,
                                              color: const Color.fromARGB(
                                                255,
                                                252,
                                                84,
                                                84,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            "CANCEL",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _submitForm,
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            backgroundColor: Colors.green,
                                            side: const BorderSide(
                                              width: 0,
                                              color: Colors.green,
                                            ),
                                          ),
                                          child: const Text(
                                            "SAVE",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
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
                      ),
                    ),
                  );
                },
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
            return const Center(child: Text(""));
          }

          List<Map<String, dynamic>> credentials = snapshot.data!;

          return ListView.builder(
            itemCount: credentials.length,
            itemBuilder: (BuildContext context, int index) {
              bool isVisible = _visibleIndex == index;
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  elevation: 2,
                  color: Colors.grey[200],

                  child: Container(
                    // decoration: BoxDecoration(
                    //   color: const Color.fromARGB(255, 191, 222, 245),
                    // ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // RichText(
                              //   //overflow: TextOverflow.ellipsis,
                              //   text: textSpan.TextSpan(
                              //     style: const TextStyle(
                              //       fontSize: 18,
                              //       color: Colors.black,
                              //     ),
                              //     children: [
                              //       textSpan.TextSpan(
                              //         text: 'TITLE: ',
                              //         style: TextStyle(fontWeight: FontWeight.bold),
                              //       ),
                              //       textSpan.TextSpan(
                              //         text:
                              //             credentials[index][DBHelper
                              //                 .COLUMN_TITLE_NAME] ??
                              //             '',
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    credentials[index][DBHelper
                                            .COLUMN_TITLE_NAME] ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _obscureTextUpdate = true;
                                          TextEditingController
                                          titleController =
                                              TextEditingController(
                                                text:
                                                    credentials[index][DBHelper
                                                        .COLUMN_TITLE_NAME],
                                              );
                                          TextEditingController
                                          userNameController =
                                              TextEditingController(
                                                text:
                                                    credentials[index][DBHelper
                                                        .COLUMN_USERNAME],
                                              );
                                          TextEditingController
                                          passwordController =
                                              TextEditingController(
                                                text:
                                                    credentials[index][DBHelper
                                                        .COLUMN_PASSWORD],
                                              );

                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                builder: (
                                                  BuildContext context,
                                                  StateSetter setModalState,
                                                ) {
                                                  return FractionallySizedBox(
                                                    heightFactor: 0.9,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                        bottom:
                                                            MediaQuery.of(
                                                              context,
                                                            ).viewInsets.bottom,
                                                      ),
                                                      child: Form(
                                                        key: _formKey,
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  10.0,
                                                                ),
                                                            child: Column(
                                                              children: <
                                                                Widget
                                                              >[
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        8.0,
                                                                      ),
                                                                  child: Text(
                                                                    'Update Credential',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        10.0,
                                                                      ),
                                                                  child: TextFormField(
                                                                    controller:
                                                                        titleController,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          "Enter title here",
                                                                      labelText:
                                                                          'Title',
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              11,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    validator:
                                                                        _validateTitle,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        10.0,
                                                                      ),
                                                                  child: TextFormField(
                                                                    controller:
                                                                        userNameController,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          "Enter username here",
                                                                      labelText:
                                                                          'Username',
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              11,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    validator:
                                                                        _validateUsername,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        10.0,
                                                                      ),
                                                                  child: TextFormField(
                                                                    obscureText:
                                                                        _obscureTextUpdate,
                                                                    obscuringCharacter:
                                                                        '*',
                                                                    controller:
                                                                        passwordController,
                                                                    decoration: InputDecoration(
                                                                      hintText:
                                                                          "Enter Password here",
                                                                      labelText:
                                                                          'Password',
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              11,
                                                                            ),
                                                                      ),
                                                                      suffixIcon: IconButton(
                                                                        icon: Icon(
                                                                          _obscureTextUpdate
                                                                              ? Icons.visibility_off
                                                                              : Icons.visibility,
                                                                        ),
                                                                        onPressed: () {
                                                                          setModalState(() {
                                                                            _obscureTextUpdate =
                                                                                !_obscureTextUpdate;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    validator:
                                                                        _validatePassword,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        10.0,
                                                                      ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: OutlinedButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          style: OutlinedButton.styleFrom(
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                25,
                                                                              ),
                                                                            ),
                                                                            backgroundColor: const Color.fromARGB(
                                                                              255,
                                                                              252,
                                                                              84,
                                                                              84,
                                                                            ),
                                                                            side: const BorderSide(
                                                                              color: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                84,
                                                                                84,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child: const Text(
                                                                            "Cancel",
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              fontSize:
                                                                                  16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child: OutlinedButton(
                                                                          onPressed: () {
                                                                            if (_formKey.currentState!.validate()) {
                                                                              var title =
                                                                                  titleController.text;
                                                                              var userName =
                                                                                  userNameController.text;
                                                                              var password =
                                                                                  passwordController.text;
                                                                              if (title.isNotEmpty &&
                                                                                  userName.isNotEmpty &&
                                                                                  password.isNotEmpty) {
                                                                                dbRef!.updateCredential(
                                                                                  id:
                                                                                      credentials[index][DBHelper.COLUMN_CREDENTIAL_ID],
                                                                                  mTitle:
                                                                                      title,
                                                                                  mUserName:
                                                                                      userName,
                                                                                  mPassword:
                                                                                      password,
                                                                                );
                                                                                setState(
                                                                                  () {},
                                                                                );
                                                                                titleController.text = '';
                                                                                userNameController.text = '';
                                                                                passwordController.text = '';
                                                                                getCredentials();
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                              }
                                                                            }
                                                                          },
                                                                          style: OutlinedButton.styleFrom(
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                25,
                                                                              ),
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.green,
                                                                            side: const BorderSide(
                                                                              width:
                                                                                  1.2,
                                                                              color:
                                                                                  Colors.green,
                                                                            ),
                                                                          ),
                                                                          child: const Text(
                                                                            "Update",
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              fontSize:
                                                                                  16,
                                                                            ),
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
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(
                                            255,
                                            3,
                                            136,
                                            245,
                                          ),
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap:
                                            () => showDialog<String>(
                                              context: context,
                                              builder:
                                                  (
                                                    BuildContext context,
                                                  ) => AlertDialog(
                                                    title: const Text(
                                                      'Confirmation?',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    content: Text.rich(
                                                      textSpan.TextSpan(
                                                        text:
                                                            'Are you sure you want to delete ',
                                                        children: [
                                                          textSpan.TextSpan(
                                                            text:
                                                                '${credentials[index][DBHelper.COLUMN_TITLE_NAME]}',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const textSpan.TextSpan(
                                                            text:
                                                                ' Credential?',
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
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          dbRef!.deleteCredential(
                                                            id:
                                                                credentials[index][DBHelper
                                                                    .COLUMN_CREDENTIAL_ID],
                                                          );
                                                          getCredentials();
                                                          Navigator.pop(
                                                            context,
                                                          );
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
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'title  ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(top: 10),
                              //   child: Row(
                              //     children: [
                              //       RichText(
                              //         text: textSpan.TextSpan(
                              //           style: const TextStyle(
                              //             fontSize: 18,
                              //             color: Colors.black,
                              //           ),
                              //           children: [
                              //             const textSpan.TextSpan(
                              //               text: 'USERNAME: ',
                              //               style: TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //             textSpan.TextSpan(
                              //               text:
                              //                   credentials[index][DBHelper
                              //                       .COLUMN_USERNAME],
                              //             ),
                              //           ],
                              //         ),
                              //       ),

                              //       Tooltip(
                              //         message: "Copy Username",
                              //         child: IconButton(
                              //           onPressed: () async {
                              //             await Clipboard.setData(
                              //               ClipboardData(
                              //                 text:
                              //                     credentials[index][DBHelper
                              //                         .COLUMN_USERNAME],
                              //               ),
                              //             );

                              //             // Show confirmation message
                              //             // ignore: use_build_context_synchronously
                              //             ScaffoldMessenger.of(context).showSnackBar(
                              //               SnackBar(
                              //                 content: const Text(
                              //                   "Username copied to clipboard!",
                              //                 ),
                              //                 duration: const Duration(seconds: 2),
                              //               ),
                              //             );
                              //           },
                              //           icon: const Icon(
                              //             Icons.copy,
                              //             color: Colors.black,
                              //             size: 20,
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    credentials[index][DBHelper
                                            .COLUMN_USERNAME] ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Tooltip(
                                    message: "Copy Username",
                                    child: GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text:
                                                credentials[index][DBHelper
                                                    .COLUMN_USERNAME],
                                          ),
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Username copied to clipboard!",
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.copy,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'username  ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Row(
                              //   children: [
                              //     RichText(
                              //       text: textSpan.TextSpan(
                              //         style: const TextStyle(
                              //           fontSize: 18,
                              //           color: Colors.black,
                              //         ),
                              //         children: [
                              //           const textSpan.TextSpan(
                              //             text: 'PASSWORD: ',
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //           textSpan.TextSpan(
                              //             text:
                              //                 isVisible
                              //                     ? credentials[index]["password"]
                              //                     : stars(
                              //                       credentials[index]["password"],
                              //                     ),
                              //           ),
                              //         ],
                              //       ),
                              //       overflow: TextOverflow.visible,
                              //     ),
                              //     IconButton(
                              //       icon: Icon(
                              //         isVisible
                              //             ? Icons.visibility_off
                              //             : Icons.visibility,
                              //       ),
                              //       onPressed: () {
                              //         setState(() {
                              //           _visibleIndex = isVisible ? null : index;
                              //         });
                              //       },
                              //     ),
                              //   ],
                              // ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    isVisible
                                        ? credentials[index]["password"]
                                        : stars(credentials[index]["password"]),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ), // Optional spacing between text and icon
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _visibleIndex =
                                            isVisible ? null : index;
                                      });
                                    },
                                    child: Icon(
                                      isVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'password  ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
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
      ),
    );
  }
}
