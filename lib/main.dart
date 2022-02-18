import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';
import 'package:pdf/widgets.dart' as pw;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showSignature = false;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  Uint8List? signatureData;
  @override
  Widget build(BuildContext context) {
    final doc = pw.Document(title: 'Deneme', author: 'Deneme');

    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: showSignature
            ? signatureView()
            : Stack(
                children: [
                  Positioned.fill(
                    child: PdfPreview(
                      maxPageWidth: 700,
                      build: (format) => generateResume(format, signatureData),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 85.0),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSignature = true;
                            });
                          },
                          child: Text('İmzala')),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget signatureView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Signature(
            controller: _controller,
            backgroundColor: Color.fromARGB(94, 0, 0, 0),
          ),
        ),
        //OK AND CLEAR BUTTONS
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                icon: const Icon(Icons.check),
                color: Colors.blue,
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    signatureData = await _controller.toPngBytes();
                    setState(() {
                      showSignature = false;
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.undo());
                },
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.redo());
                },
              ),
              //CLEAR CANVAS
              IconButton(
                icon: const Icon(Icons.clear),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.clear());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Uint8List> generateResume(PdfPageFormat format, Uint8List? signature) async {
    final doc = pw.Document(title: 'Deneme', author: 'Deneme');

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Partitions(
            children: [
              pw.Partition(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Container(
                      padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text('Deneme ' * 100),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    if (signature != null)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: 50,
                            width: 150,
                            child: pw.Image(pw.MemoryImage(signature)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }
}
