import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'fddevicesbt.dart';

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isBluetoothAvailable = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        if (state.isEnabled) {
          _isBluetoothAvailable = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arduino Bluetooth',
      //tema del dispositivo
      theme: ThemeData(
        primarySwatch: Colors.blue, //color de la barra de estado
      ),
      home: _isBluetoothAvailable
          ? DevicesScreen()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.bluetooth_disabled,
                      size: 200.0,
                      color: Colors.white54,
                    ),
                    Text(_isBluetoothAvailable ? "Bluetooth Activado" : "Bluetooth Desactivado",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20.0,
                        )),
                    ElevatedButton(
                      child: const Text('Habilitar Bluetooth'),
                      onPressed: () {
                        FlutterBluetoothSerial.instance
                            .requestEnable()
                            .whenComplete(() => FlutterBluetoothSerial
                                    .instance.state
                                    .then((state) {
                                  setState(() {
                                    if (state.isEnabled) {
                                      _isBluetoothAvailable = true;
                                    }
                                  });
                                }));
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
