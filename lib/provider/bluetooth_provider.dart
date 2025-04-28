import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '/pages/home_page.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _isScanning = false;
  bool _isConnected = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  BluetoothCharacteristic? _notifyCharacteristic;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _rfidCharacteristic;
  String _notifyData = ""; // Menyimpan data dari karakteristik Notify
  String _rfidData = ""; // Menyimpan data dari karakteristik 9800

  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothService> get services => _services;
  String get notifyData => _notifyData; // Getter untuk data Notify
  String get rfidData => _rfidData; // Getter untuk data RFID

  Future<void> startScan() async {
    if (_isScanning) return;

    _scanResults.clear();
    _isScanning = true;
    notifyListeners();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();

    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      notifyListeners();

      // Fetch services after connecting
      _services = await device.discoverServices();
      _findCharacteristics();
      notifyListeners();

      // Navigasi ke HomePage setelah berhasil konek
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
    }
  }

  Future<void> _findCharacteristics() async {
    if (_connectedDevice == null) return;
    for (var service in _services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString().toLowerCase() == "9901") {
          _notifyCharacteristic = characteristic;
          await _notifyCharacteristic!.setNotifyValue(true);

          // Mendengarkan perubahan data dari karakteristik Notify
          _notifyCharacteristic!.onValueReceived.listen((value) {
            _notifyData = value.map((e) => e.toRadixString(16)).join(' ');
            print("Data Notify: $_notifyData");
            notifyListeners();
          });
          print("Notify aktif: ${characteristic.uuid}");
        }
        if (characteristic.uuid.toString().toLowerCase() == "9900") {
          _writeCharacteristic = characteristic;
          print("Write ditemukan: ${characteristic.uuid}");
        }
        if (characteristic.uuid.toString().toLowerCase() == "9800") {
          _rfidCharacteristic = characteristic;
          await _rfidCharacteristic!.setNotifyValue(true);

          // Mendengarkan perubahan data dari karakteristik 9800
          _rfidCharacteristic!.onValueReceived.listen((value) {
            _rfidData = value.map((e) => e.toRadixString(16)).join(' ');
            print("Data 9800: $_rfidData");
            notifyListeners();
          });
          print("RFID 9800 ditemukan: ${characteristic.uuid}");
        }
      }
    }
    notifyListeners();
  }

  Future<void> writeData(List<int> data) async {
    if (_writeCharacteristic != null) {
      await _writeCharacteristic!.write(data);
      print("Data ditulis: $data");
    }
  }

  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _isConnected = false;
      _connectedDevice = null;
      _services.clear();
      _notifyCharacteristic = null;
      _writeCharacteristic = null;
      _rfidCharacteristic = null;
      _notifyData = ""; // Reset data Notify saat disconnect
      _rfidData = ""; // Reset data 9800 saat disconnect
      notifyListeners();
    }
  }
}
