import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert' show utf8;

bool isNfcAvalible = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isNfcAvalible = await NfcManager.instance.isAvailable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(title: "NFC"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  String title;

  HomePage({required this.title, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _NfcState();
}

class _NfcState extends State<HomePage> {
  late TextEditingController _controller;
  var _nfcData = null;
  var isActive = null;

  Future<void> _readNFCTag() async {
    try {
      setState(() {
        isActive = true;
      });

      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Ndef? ndef = Ndef.from(tag);
        // print(tag);
        if (ndef == null) {
          setState(() {
            _nfcData = "NFC Tag is Empty";
          });
          print("gelesen");
          return;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      await NfcManager.instance.stopSession();
      setState(() {
        isActive = false;
      });
    }
  }

  Future<void> _writeNfc() async {
    var tagVal = _controller.text;
    try {
      setState(() {
        isActive = false;
      });

      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        (NdefMessage tagVal) {
          print("$tagVal");
        };

        return;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    isActive = false;

    _controller = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: isNfcAvalible
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _nfcData != null
                      ? Text(
                          "$isActive - $_nfcData",
                        )
                      : Text(_controller.text),
                  const Text("Gelesenes / Geschriebenes NFC unten: "),
                  Text(_controller.text),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: "Nfc Eingeben",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.red,
                            style: BorderStyle.solid,
                          )),
                          contentPadding: EdgeInsets.only(
                              right: 10, left: 10, bottom: 5, top: 5),
                          constraints: BoxConstraints(maxWidth: 250)),
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.2),
                      textAlign: TextAlign.center,
                      readOnly: false,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.only(left: 20, right: 20),
                        ),
                        onPressed: () {
                          _writeNfc();
                        },
                        child: const Text("Schreiben"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.only(left: 20, right: 20),
                        ),
                        onPressed: () {
                          _readNFCTag();
                        },
                        child: const Text("Lesen"),
                      ),
                    ],
                  )
                ],
              )
            : const Text("NFC ist nicht verfügbar"),
      ),
    );
  }
}
