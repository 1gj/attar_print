import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';

// استيراد المكتبة الأصلية (وليس plus)
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class PrintPage extends StatefulWidget {
  final Uint8List imageBytes;

  const PrintPage({super.key, required this.imageBytes});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'جاري البحث عن الطابعة...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bluetoothPrint.scanResults.listen((val) {
      if (!mounted) return;
      setState(() {});
    });

    bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'تم الاتصال بنجاح - جاهز للطباعة';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'تم قطع الاتصال';
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتصال وطباعة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              tips,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: bluetoothPrint.scanResults,
              initialData: const [],
              builder: (c, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final d = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Icon(Icons.print, color: Colors.blue[800]),
                          title: Text(d.name ?? 'جهاز غير معروف'),
                          subtitle: Text(d.address ?? ''),
                          trailing: _device != null &&
                                  _device!.address == d.address
                              ? Icon(Icons.check_circle,
                                  color:
                                      _connected ? Colors.green : Colors.grey)
                              : null,
                          onTap: () async {
                            setState(() {
                              _device = d;
                              tips = "جاري الاتصال بـ ${d.name}...";
                            });
                            await bluetoothPrint.connect(d);
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text("جاري البحث... تأكد أن الطابعة تعمل"));
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _connected ? Colors.green[700] : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.print),
              label: const Text("طباعة الفاتورة الآن",
                  style: TextStyle(fontSize: 18)),
              onPressed: _connected ? _printNow : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printNow() async {
    Map<String, dynamic> config = {};
    config['width'] = 100;
    config['height'] = 150;
    config['gap'] = 2;

    List<LineText> list = [];
    String base64Image = base64Encode(widget.imageBytes);

    list.add(LineText(
      type: LineText.TYPE_IMAGE,
      content: base64Image,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
      width: 800,
    ));
    list.add(LineText(linefeed: 1));

    await bluetoothPrint.printReceipt(config, list);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إرسال الأمر للطابعة")));
    }
  }
}
