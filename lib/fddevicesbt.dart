import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:restart_app/restart_app.dart';

class DevicesScreen extends StatefulWidget {
  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {

  bool _walleTraked = false;
  BluetoothDevice? _device;
  BluetoothConnection? _pointConnection;
  final String _address = "00:22:03:01:92:71";
  final String _name = "HC-05";

  bool _ledStatus = false;
  bool _voiceStatus = false;

  void scanBluetooth() {
    try {
      FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        if (r.device.address == _address) {
          _device = r.device;
          if (_device!.name == _name) {
            connectToDevice();
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    content: Text("IMPOSIBLE DETECTAR A WALL-E"),
                  );
                });
          }
        }
      });
    } on PlatformException {
      print("Error");
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error al escanear'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  connectToDevice() async {
    try {
      _pointConnection = await BluetoothConnection.toAddress(_device!.address);
      setState(() {
        _walleTraked = true;
      });
    } on PlatformException {
      print('Error');
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error al conectar'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  void action(String key) async {
    try {
      key = key.trim();
      if (key.isEmpty) {
        print('Error: No se puede enviar datos vacíos');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                content: const Text('Error: No se puede enviar datos vacíos'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else {
        List<int> list1 = key.codeUnits;
        Uint8List bytes1 = Uint8List.fromList(list1);
        _pointConnection!.output.add(bytes1);
        await _pointConnection!.output.allSent;
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error al enviar datos'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanBluetooth();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scanBluetooth();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectando a Wall-E'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              //reiniciar el app
              Restart.restartApp();
            },
          )
        ],
      ),
      body: _buildScanningScreen(),
      floatingActionButton: FloatingActionButton(
        //color de fondo
        backgroundColor: _walleTraked ? Colors.green : Colors.orange,
        onPressed: () {
          if (_walleTraked == true) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => _buildConnectionScreen(context)));
          } else {
            scanBluetooth();
          }
          print(_walleTraked);
        },
        child: _walleTraked
            ? const Icon(Icons.play_arrow_rounded, color: Colors.white)
            : const Icon(Icons.replay_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildScanningScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Estado de la Conexión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Container(
            height: 100,
            child: _walleTraked
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text('Estado: ${_walleTraked ? 'Encontrado' : 'Buscando'}'),
          const SizedBox(height: 20),
          Text('Nombre: ${_walleTraked ? _name : 'Buscando'}'),
          const SizedBox(height: 20),
          Text('Direccion: ${_walleTraked ? _address : 'Buscando'}'),
          const Image(image: AssetImage('assets/Wall-E-icon.png')),
        ],
      ),
    );
  }

  Widget _buildConnectionScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wall-E'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text.rich(
                TextSpan(
                  text: 'Wall-E',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Image.asset('assets/Wall-E-icon.png', height: 200),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Control de Remoto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Image.asset('assets/led.png', width: 50, height: 50, color: _ledStatus ? Colors.green : Colors.black),
                    onPressed: () {
                      if(_ledStatus == false){
                        action('X');
                        action('Y');
                        setState(() {
                          _ledStatus = true;
                        });
                      }else{
                        action('X');
                        action('Y');
                        setState(() {
                          _ledStatus = false;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/voz.png', width: 50, height: 50, color: _voiceStatus ? Colors.green : Colors.black),
                    onPressed: () {
                      if(_voiceStatus == false){
                        action('Z');
                        action('W');
                        setState(() {
                          _voiceStatus = true;
                        });
                      }else{
                        action('Z');
                        action('W');
                        setState(() {
                          _voiceStatus = false;
                        });
                      }
                    }
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Icon(
                                  Icons.info,
                                  color: Colors.orange,
                                  size: 50,
                                ),
                                content: Text.rich(
                                  TextSpan(
                                    text: 'Wall-E\n',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Nombre: ${_device!.name}\n',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      TextSpan(
                                          text:
                                              'Direccion: ${_device!.address}\n',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: _device!.bondState.isBonded
                                              ? 'Estado: Conectado'
                                              : 'Estado: Desconectado',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Image.asset(
                        'assets/robot.png',
                      ),
                      iconSize: 50),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () {
                      action("L");
                      action("J");
                    },
                    onLongPressUp: () => action("O"),
                    child: Image.asset('assets/cabezaizquierda.png',
                        width: 50, height: 50),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      action("K");
                      action("M");
                    },
                    onLongPressUp: () => action("O"),
                    child: Image.asset('assets/cabezaderecha.png',
                        width: 50, height: 50),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () => action("H"),
                    onLongPressUp: () => action("I"),
                    child:
                        Image.asset('assets/arriba.png', width: 50, height: 50),
                  ),
                  GestureDetector(
                    onLongPress: () => action("G"),
                    onLongPressUp: () => action("I"),
                    child:
                        Image.asset('assets/abajo.png', width: 50, height: 50),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () => action("A"),
                    onLongPressUp: () => action("E"),
                    child: Image.asset('assets/adelante.png',
                        width: 50, height: 50),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () => action("D"),
                    onLongPressUp: () => action("E"),
                    child: Image.asset('assets/izquierda.png',
                        width: 50, height: 50),
                  ),
                  GestureDetector(
                    onLongPress: () => action("C"),
                    onLongPressUp: () => action("E"),
                    child: Image.asset('assets/derecha.png',
                        width: 50, height: 50),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onLongPress: () => action("B"),
                    onLongPressUp: () => action("E"),
                    child:
                        Image.asset('assets/atras.png', width: 50, height: 50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
