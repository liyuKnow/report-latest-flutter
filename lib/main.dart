import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latest/src/helper/object_box.dart';
import 'package:latest/src/models/user_model.dart';
import 'package:latest/src/pages/user_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Provides access to the ObjectBox Store throughout the app.
late ObjectBox objectbox;

enum MenuItems { import, export, sync }

void main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latest Build :: Golden Lion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Latest Build'),
    );
  }
}

// ! HOME OF APPLICATION

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [popupActions()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const UserList()],
        ),
      ),
    );
  }

  // ^ FUNCTIONS

  PopupMenuButton<MenuItems> popupActions() {
    return PopupMenuButton<MenuItems>(
        onSelected: (value) {
          if (value == MenuItems.import) {
            _importData();
          } else if (value == MenuItems.export) {
            _exportData(); //  yellow comments
          } else if (value == MenuItems.sync) {
            _syncData();
          }
        },
        itemBuilder: ((context) => [
              PopupMenuItem(
                  value: MenuItems.import,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.download,
                        color: Colors.indigo,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text("Import Data"),
                    ],
                  )),
              PopupMenuItem(
                  value: MenuItems.export,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.upload,
                        color: Colors.indigo,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text("Export Data"),
                    ],
                  )),
              PopupMenuItem(
                  value: MenuItems.sync,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.import_export,
                        color: Colors.indigo,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text("Sync Data"),
                    ],
                  )),
            ]));
  }

  _importData() async {
    // Download From Downloads Folder
    // ^ CHECK PERMISSION
    var status = await Permission.manageExternalStorage.status;

    // ^ REQUEST PERMISSION
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    // ^ GET FILE FROM DOWNLOADS
    final directory = Directory('/storage/emulated/0/Download/');
    const fileName = "usersDownload.xlsx";
    final file = File(directory.path + fileName);

    // ^ SAVE IT TO A LOCAL VARIABLE
    List<String> rowDetail = [];

    var excelBytes = File(file.path).readAsBytesSync();
    var excelDecoder = SpreadsheetDecoder.decodeBytes(excelBytes, update: true);

    for (var table in excelDecoder.tables.keys) {
      for (var row in excelDecoder.tables[table]!.rows) {
        rowDetail.add('$row'.replaceAll('[', '').replaceAll(']', ''));
      }
    }

    // ^ INSERT INTO OBJECTBOX
    for (var row in rowDetail) {
      var data = row.split(',');

      var firstName = data[1];
      var lastName = data[2];
      var country = data[3];
      var gender = data[4];

      User newUser = User(firstName, lastName, country, gender);
      objectbox.userBox.put(newUser);
    }
  }

  _exportData() {
    // export current database data to downloads folder
    print("DATA IS ABOUT TO BE EXPORTED!");
  }

  _syncData() {
    // send current database data to API
  }

  _updateUser() {
    // ^ LOCATION PERMISSION
    // ^ GET LOCATION DATA
    // ^ UPDATE USER AND COMPLETED FLAG
    // ^ INSERT UPDATED LOCATION DATA
  }
}
