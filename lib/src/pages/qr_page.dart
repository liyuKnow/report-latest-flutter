// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QRPage extends StatefulWidget {
//   const QRPage({super.key, required this.title});

//   final String title;

//   @override
//   State<QRPage> createState() => _QRPageState();
// }

// class _QRPageState extends State<QRPage> {
//   final GlobalKey _gLobalkey = GlobalKey();
//   QRViewController? controller;
//   Barcode? result;

//   void qr(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((event) {
//       setState(() {
//         result = event;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               height: 400,
//               width: 400,
//               child: QRView(key: _gLobalkey, onQRViewCreated: qr),
//             ),
//             Center(
//               child: (result != null)
//                   ? Text('${result!.code}')
//                   : Text('Scan a code'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

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
        title: Text("Scan QR"),
      ),
    );
  }
}

// class QRPage extends StatelessWidget {
//   const QRPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mobile Scanner')),
//       body: MobileScanner(
//           allowDuplicates: false,
//           onDetect: (barcode, args) {
//             if (barcode.rawValue == null) {
//               debugPrint('Failed to scan Barcode');
//             } else {
//               final String code = barcode.rawValue!;
//               debugPrint('Barcode found! $code');
//             }
//           }),
//     );
//   }
// }
