import 'package:flutter/material.dart';
import 'package:latest/src/helper/object_box.dart';
import 'package:latest/src/pages/user_list.dart';

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
      home: const MyHomePage(title: 'Latest Build :: Golden Lion'),
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
          children: <Widget>[
            Text(
              'Golden Lion',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const UserList()
          ],
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
            // ^ Navigation code -> QR SCANNER
            // ^ Navigator.of(context).push(MaterialPageRoute(
            // ^ builder : (context) => const ComponentName()
            // ^ ))
            print(value);
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

  _importData() {
    // Download From Downloads Folder

    // & CHECK FOR PERMISSION
    // & GET FILE FROM DOWNLOADS
    // & GET FILE FROM DOWNLOADS
    print("DATA IS ABOUT TO BE IMPORTED!");
  }

  _exportData() {
    // export current database data to downloads folder
    print("DATA IS ABOUT TO BE EXPORTED!");
  }

  _syncData() {
    // send current database data to API
  }
}
