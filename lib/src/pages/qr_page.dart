import 'package:flutter/material.dart';
import 'package:latest/src/helper/object_box.dart';
import 'package:latest/src/models/user_model.dart';
import 'package:latest/src/pages/update_page.dart';
import 'package:latest/src/models/updated_location.dart';
import 'package:location/location.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:latest/main.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key, required this.userId});

  final int userId;
  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Scan for User ${widget.userId}"),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
          allowDuplicates: true,
          controller: cameraController,
          onDetect: _foundbarCode),
    );
  }

  _foundbarCode(Barcode barcode, MobileScannerArguments? args) {
    /// open screen
    if (!_screenOpened) {
      final String code = barcode.rawValue ?? "---";
      if (code == widget.userId.toString()) {
        // ^ GOTO OUR UPDATE PAGE
        print("it is a match $code");
        // const UpdateUser();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateFoundUser(
                  screenClosed: _screenWasClosed,
                  value: code,
                  userId: widget.userId),
            ));
      } else {
        // ^ SHOW ERROR SNACK AND RETURN TO LIST
        print("No it is not our id $code");
      }
      // debugPrint('Barcode found! $code');
      // _screenOpened = true;
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }
}

class UpdateFoundUser extends StatefulWidget {
  final String value;
  final int userId;
  final Function() screenClosed;

  const UpdateFoundUser({
    Key? key,
    required this.value,
    required this.screenClosed,
    required this.userId,
  }) : super(key: key);

  @override
  State<UpdateFoundUser> createState() => _UpdateFoundUserState();
}

class _UpdateFoundUserState extends State<UpdateFoundUser> {
  // ^ CONTROLLERS
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();
  final _userCountryController = TextEditingController();
  final _userGenderController = TextEditingController();

  // ^ VALIDATION FLAGS
  bool _validateFirstName = false;
  bool _validateLastName = false;
  bool _validateCountry = false;
  bool _validateGender = false;

  // ^ INITIALISE STATE
  @override
  void initState() {
    var user = objectbox.userBox.get(widget.userId);
    setState(() {
      _userFirstNameController.text = user?.firstName ?? '';
      _userLastNameController.text = user?.lastName ?? '';
      _userCountryController.text = user?.country ?? '';
      _userGenderController.text = user?.gender ?? '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update User"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // ^ NAVIGATE BACK TO HOME
            returnHome(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 20.0,
            ),
            TextField(
                enabled: false,
                controller: _userFirstNameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Firstname',
                  labelText: 'Firstname',
                  errorText:
                      _validateFirstName ? 'Name Value Can\'t Be Empty' : null,
                )),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
                enabled: false,
                controller: _userLastNameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Lastname ',
                  labelText: 'Lastname ',
                  errorText: _validateLastName
                      ? 'Lastname  Value Can\'t Be Empty'
                      : null,
                )),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
                controller: _userCountryController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Country',
                  labelText: 'Country',
                  errorText:
                      _validateCountry ? 'Country Value Can\'t Be Empty' : null,
                )),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
                controller: _userGenderController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Gender',
                  labelText: 'Gender',
                  errorText:
                      _validateGender ? 'Gender Value Can\'t Be Empty' : null,
                )),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        textStyle: const TextStyle(fontSize: 15)),
                    onPressed: () async {
                      setState(() {
                        _userCountryController.text.isEmpty
                            ? _validateCountry = true
                            : _validateCountry = false;
                        _userGenderController.text.isEmpty
                            ? _validateGender = true
                            : _validateGender = false;
                      });

                      if (_validateCountry == false &&
                          _validateGender == false) {
                        // ^ UPDATE DATA LOGIC HERE
                        print("DO YOUR THING GURU");
                        _updateUser();
                        returnHome(context);
                      }
                    },
                    child: const Text('Update Details')),
                const SizedBox(
                  width: 10.0,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(fontSize: 15)),
                    onPressed: () {
                      _userCountryController.text = '';
                      _userGenderController.text = '';
                    },
                    child: const Text('Clear Details'))
              ],
            )
          ]),
        ),
      ),
    );
  }

  void returnHome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Future _updateUser() async {
    // ^ LOCATION SERVICE ON AND PERMISSION
    var location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        return;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }
    // ^ GET LOCATION DATA
    var loc = await location.getLocation();
    print("${loc.latitude} ${loc.longitude}");

    // & LIVE LISTENER OF LOCATION => CAN BE USED TO TRACK SUDDEN LOCATION CHANGES
    // location.onLocationChanged.listen((LocationData loc) {
    //   print("${loc.latitude} ${loc.longitude}");
    // });

    // ^ UPDATE USER AND COMPLETED FLAG
    // & get user by id
    User? user = await objectbox.getUser(widget.userId);
    print(user?.completed);
    // & get location variables
    if (loc.latitude != null) {
      objectbox.addUpdatedLocation(
          loc.latitude, loc.longitude, DateTime(2022), user!);
      objectbox.setCompleted(user);
    } else {
      // ^ SHOW ERROR MESSAGE
    }
  }
}
