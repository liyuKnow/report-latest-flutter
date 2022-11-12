import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latest/src/helper/object_box.dart';
import 'package:latest/src/models/user_model.dart';
import 'package:latest/src/pages/user_list.dart';
import 'package:permission_handler/permission_handler.dart'
    as PermissionHandler;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as XLSIO;
import 'package:location/location.dart';

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
      home: MyHomePage(),
    );
  }
}

// ! HOME OF APPLICATION

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest Build"),
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
    var status =
        await PermissionHandler.Permission.manageExternalStorage.status;

    // ^ REQUEST PERMISSION
    if (status.isDenied) {
      await PermissionHandler.Permission.manageExternalStorage.request();
    }

    // ^ GET FILE FROM DOWNLOADS
    final directory = Directory('/storage/emulated/0/Download/');
    const fileName = "usersDownload.xlsx";
    final file = File(directory.path + fileName);

    // ^ SAVE IT TO A LOCAL VARIABLE
    List<String> rowDetail = [];

    var excelBytes = File(file.path).readAsBytesSync();
    var excelDecoder = SpreadsheetDecoder.decodeBytes(excelBytes, update: true);

    // TODO : TEST JSON OR CSV AGAINST EXCEL FILE IF WE CAN AVOID THIS LOOPS
    for (var table in excelDecoder.tables.keys) {
      for (var row in excelDecoder.tables[table]!.rows) {
        rowDetail.add('$row'.replaceAll('[', '').replaceAll(']', ''));
      }
    }

    // ^ CLEAR OBJECTBOX
    objectbox.userBox.removeAll();

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

  Future<void> _exportData() async {
    // export current database data to downloads folder
    // ^ GET ALL USERS AND THEIR LOCATION DATA
    // ^ CREATE EXCEL AND EXPORT
    // Create a new Excel document.
    final XLSIO.Workbook workbook = XLSIO.Workbook();
    //Accessing worksheet via index.
    final XLSIO.Worksheet sheet = workbook.worksheets[0];

    // ADD THE HEADERS
    sheet.getRangeByName('A1').setText('FirstName');
    sheet.getRangeByName('B1').setText('LastName');
    sheet.getRangeByName('C1').setText('Gender');
    sheet.getRangeByName('C1').setText('Country');
    sheet.getRangeByName('D1').setText('Age');
    sheet.getRangeByName('E1').setText('Date');
    sheet.getRangeByName('F1').setText('Id');

    // for (var i = 2; i < _userList.length; i++) {
    //   print((_userList[i].firstName).toString());
    //   sheet
    //       .getRangeByName('A' + i.toString())
    //       .setText((_userList[i].firstName).toString());
    //   sheet
    //       .getRangeByName('B' + i.toString())
    //       .setText((_userList[i].lastName).toString());
    //   sheet
    //       .getRangeByName('C' + i.toString())
    //       .setText((_userList[i].gender).toString());
    //   sheet
    //       .getRangeByName('C' + i.toString())
    //       .setText((_userList[i].country).toString());
    //   sheet
    //       .getRangeByName('D' + i.toString())
    //       .setText((_userList[i].age).toString());
    //   // setDateTime(DateTime(2020, 12, 12, 1, 10, 20))
    //   sheet
    //       .getRangeByName('E' + i.toString())
    //       .setText((_userList[i].date).toString());
    //   sheet
    //       .getRangeByName('F' + i.toString())
    //       .setText((_userList[i].id).toString());
    // }

    // final List<int> bytes = workbook.saveAsStream();

    // final directory = Directory('/storage/emulated/0/Download/');
    // const fileName = "NewUsersDownload.xlsx";
    // final file = File(directory.path + fileName);

    // file.writeAsBytes(bytes);

    // //Dispose the workbook.
    // workbook.dispose();
  }

  _syncData() {
    // send current database data to API
  }
}
