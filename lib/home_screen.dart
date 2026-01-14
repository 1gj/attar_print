import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:screenshot/screenshot.dart';
import 'print_page.dart'; // استدعاء صفحة الطباعة

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // المتحكمات
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController itemsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة فاتورة - بيت العطار'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "بيانات الطلب:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // الحقول
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الزبون',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: itemsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'المواد',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر الكلي',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              onChanged: (val) => setState(() {}),
            ),

            const Divider(height: 40, thickness: 2),

            // --- المعاينة (سيتم تحويلها لصورة) ---
            const Center(
              child: Text(
                "معاينة الفاتورة",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 5),

            Screenshot(
              controller: screenshotController,
              child: Container(
                width: 380, // عرض الورقة
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "عطارة بيت العطار",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "ناصرية - سوق سيد سعد",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      "07726860085",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(thickness: 2, color: Colors.black),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "الزبون: ${nameController.text}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("الهاتف: ${phoneController.text}"),
                          Text("العنوان: ${addressController.text}"),
                          Text(
                            "التاريخ: ${intl.DateFormat('yyyy-MM-dd h:mm a').format(DateTime.now())}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "المواد:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        itemsController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const Divider(thickness: 2, color: Colors.black),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "المجموع:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${priceController.text} د.ع",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- زر الانتقال للطباعة ---
            ElevatedButton.icon(
              onPressed: () async {
                // 1. التقاط الصورة
                // pixelRatio: 2.5 تعني مضاعفة الدقة مرتين ونصف لتكون واضحة جداً كالكريستال
                final image = await screenshotController.capture(
                  pixelRatio: 2.5,
                );

                if (image != null && context.mounted) {
                  // 2. الانتقال لصفحة الطباعة مع الصورة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrintPage(imageBytes: image),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.print),
              label: const Text(
                "متابعة للطباعة",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
