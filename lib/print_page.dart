import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart'; // المكتبة الجديدة
import 'package:permission_handler/permission_handler.dart';

class PrintPage extends StatefulWidget {
  final Uint8List imageBytes;

  const PrintPage({super.key, required this.imageBytes});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  String tips = 'جاري البحث عن الطابعة...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Future<void> initBluetooth() async {
    // طلب الصلاحيات
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool? isOn = await bluetooth.isOn;
    if (isOn == true) {
      try {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
        setState(() {
          _devices = devices;
          tips = devices.isEmpty
              ? "لا توجد طابعات مقترنة. اذهب لإعدادات البلوتوث واقترن بالطابعة أولاً."
              : "اختر الطابعة للاتصال:";
        });
      } catch (e) {
        setState(() => tips = "خطأ: $e");
      }
    } else {
      setState(() => tips = "البلوتوث مغلق");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            tips = "تم الاتصال";
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = "تم قطع الاتصال";
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
          title: const Text('طباعة الفاتورة'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(tips,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(_devices[index].name ?? "غير معروف"),
                  subtitle: Text(_devices[index].address ?? ""),
                  trailing:
                      _device?.address == _devices[index].address && _connected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                  onTap: () async {
                    if (_connected) await bluetooth.disconnect();
                    setState(() {
                      _device = _devices[index];
                      tips = "جاري الاتصال...";
                    });
                    await bluetooth.connect(_devices[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text("طباعة الآن"),
              onPressed: _connected ? _printImage : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _connected ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _printImage() async {
    if (_device == null) return;
    if ((await bluetooth.isConnected) == true) {
      // طباعة الصورة
      await bluetooth.printImageBytes(widget.imageBytes);
      // قص الورقة
      await bluetooth.printNewLine();
      await bluetooth.printNewLine();
    }
  }
}
