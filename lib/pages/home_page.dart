import 'package:flutter/material.dart';
import 'bluetooth_scan_page.dart';
import 'read_or_write_page.dart';
import 'package:provider/provider.dart';
import '/provider/bluetooth_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Image.asset('assets/logo.png', fit: BoxFit.contain, height: 150,),
          centerTitle: true,
          toolbarHeight: 70,
        ),
        body:
        Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.fromLTRB(18, 50, 0, 0),
                  padding: const EdgeInsets.all(3),
                  child: const Text(
                    "CS108 RFID Reader!",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Color.fromRGBO(60, 180, 170, 10.0),
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold
                    ),)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromRGBO(190, 202, 218, 100.00)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              blurRadius: 1,
                              offset: Offset(0, 1)
                          )
                        ]
                    ),
                    width: screenWidth * 0.411,
                    height: screenHeight * 0.14375,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReadOrWritePage()),
                        );
                      },
                      child: const Text(
                        "Read / Write",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromRGBO(190, 202, 218, 100.00)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              blurRadius: 1,
                              offset: Offset(0, 1)
                          )
                        ]
                    ),
                    width: screenWidth * 0.411,
                    height: screenHeight * 0.14375,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Inventory",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                  ),
                ],               ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                        border: Border.all(
                            color: Color.fromRGBO(190, 202, 218, 100.00)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              blurRadius: 1,
                              offset: Offset(0, 1)
                          )
                        ]
                    ),
                    width: screenWidth * 0.411,
                    height: screenHeight * 0.14375,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Register Tag",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    width: screenWidth * 0.411,
                    height: screenHeight * 0.14375,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                  ),
                ],
              ),

              const Spacer(),
              Container(
                width: screenWidth,
                height: screenHeight * 0.1125,
                margin: EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(104, 104, 108, 150),
                          spreadRadius: 0.1,
                          blurRadius: 15,
                          offset: Offset(0, -0.2)
                      )
                    ]
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (bluetoothProvider.isConnected) {
                        await bluetoothProvider.disconnectDevice();
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BluetoothScanPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(screenWidth * 0.5, screenHeight * 0.0875),
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.grey,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Color.fromRGBO(190, 202, 218, 100.00))
                      ),
                    ),
                    child: Text(
                      bluetoothProvider.isConnected
                          ? 'Connected to ${bluetoothProvider.connectedDevice?.advName ?? "unknown device"}'
                          : "Scan / Connect",
                      style: TextStyle(
                          fontSize: bluetoothProvider.isConnected ? 15.0 : 20.0,
                          color: bluetoothProvider.isConnected ? Color.fromRGBO(60, 180, 179, 1.0) : Color.fromRGBO(242, 112, 98, 1.0),
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.bold
                      ),),
                  )
                ),
              ),
            ])
    );
  }
}
