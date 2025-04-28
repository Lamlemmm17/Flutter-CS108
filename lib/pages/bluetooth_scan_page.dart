import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '/provider/bluetooth_provider.dart';

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({super.key});

  @override
  State<BluetoothScanPage> createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  bool isScanning = false;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions();
  }

  Future<void> requestBluetoothPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void startScan() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('assets/logo.png', fit: BoxFit.contain, height: 150),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: startScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isScanning ? 'Scanning...' : 'Mulai Scan',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromRGBO(60, 180, 170, 10.0),
              ),
            ),
          ),
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (!isScanning && scanResults.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tidak ada perangkat ditemukan',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          if (!isScanning && scanResults.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Scan selesai, perangkat ditemukan:',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;
                final advName = scanResults[index].advertisementData.advName;
                return ListTile(
                  title: Text(
                    advName.isNotEmpty ? advName : 'Unknown Device',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    device.remoteId.toString(),
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () => bluetoothProvider.connectToDevice(device, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
