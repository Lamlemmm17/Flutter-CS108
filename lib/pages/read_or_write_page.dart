import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ReadOrWritePage extends StatefulWidget {
  const ReadOrWritePage({Key? key}) : super(key: key);

  @override
  State<ReadOrWritePage> createState() => _ReadOrWritePageState();
}

class _ReadOrWritePageState extends State<ReadOrWritePage> {
  final TextEditingController _eidController = TextEditingController();
  final TextEditingController _vidController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();

  BluetoothDevice? _device;
  bool deviceConnected = false;
  final String _serviceUuid = 'SERVICE_UUID';
  final String _characteristicUuid = 'CHARACTERISTIC_UUID';

  @override
  void initState() {
    super.initState();
    _checkDeviceConnection();
  }

  void _checkDeviceConnection() {
    setState(() {
      deviceConnected = FlutterBluePlus.connectedDevices.isNotEmpty;
      if (deviceConnected) {
        _device = FlutterBluePlus.connectedDevices.first;
      }
    });
  }

  Future<void> _readRFIDData() async {
    try {
      if (!deviceConnected || _device == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device belum terkoneksi!')),
        );
        return;
      }

      var services = await _device!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == _serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _characteristicUuid) {
              var value = await characteristic.read();
              String data = String.fromCharCodes(value);
              List<String> parts = data.split(',');
              setState(() {
                _eidController.text = parts.isNotEmpty ? parts[0] : '';
                _vidController.text = parts.length > 1 ? parts[1] : '';
                _nikController.text = parts.length > 2 ? parts[2] : '';
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membaca data: $e')),
      );
    }
  }

  Future<void> _writeRFIDData() async {
    try {
      if (!deviceConnected || _device == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device belum terkoneksi!')),
        );
        return;
      }

      var services = await _device!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == _serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _characteristicUuid) {
              String data = '${_eidController.text},${_vidController.text},${_nikController.text}';
              await characteristic.write(data.codeUnits);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data disimpan: $data')),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('assets/logo.png', fit: BoxFit.contain, height: 150,),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Device Connected: ${deviceConnected ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _eidController,
              decoration: const InputDecoration(labelText: 'EID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _vidController,
              decoration: const InputDecoration(labelText: 'VID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nikController,
              decoration: const InputDecoration(labelText: 'NIK/KK'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _readRFIDData,
              child: const Text('Read RFID'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _writeRFIDData,
              child: const Text('Write RFID'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eidController.dispose();
    _vidController.dispose();
    _nikController.dispose();
    super.dispose();
  }
}
