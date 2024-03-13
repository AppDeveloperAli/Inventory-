import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/main.dart';

class SpecialOffers extends StatefulWidget {
  const SpecialOffers({super.key});

  @override
  State<SpecialOffers> createState() => _SpecialOffersState();
}

class _SpecialOffersState extends State<SpecialOffers> {
  List<File> _images = [];
  final picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      isLoading = true;
    });
    final storage = FirebaseStorage.instance;
    final docId = "UYmil6gQ34PgL51cLxcS";
    final folderName = "special/$docId";
    final slideImages = [];

    for (var i = 0; i < _images.length; i++) {
      final imageFile = _images[i];
      final fileName = '$folderName/image_$i.jpg';
      await storage.ref(fileName).putFile(imageFile);
      final downloadUrl = await storage.ref(fileName).getDownloadURL();
      slideImages.add(downloadUrl);
    }

    await FirebaseFirestore.instance.collection('special').doc(docId).update({
      'slideImages': slideImages,
    });

    setState(() {
      _images.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Images uploaded successfully'),
    ));
    setState(() {
      isLoading = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => const MainScreen(),
      ),
      (route) => false,
    );
  }

  TextEditingController discountController = TextEditingController();
  TextEditingController shippingController = TextEditingController();
  TextEditingController packingChargesController = TextEditingController();
  TextEditingController deliveryTaxController = TextEditingController();

  @override
  void dispose() {
    discountController.dispose();
    shippingController.dispose();
    packingChargesController.dispose();
    deliveryTaxController.dispose();
    super.dispose();
  }

  Future<void> _updateSettings() async {
    String discount = discountController.text;
    String shipping = shippingController.text;
    String packingCharges = packingChargesController.text;
    String deliveryCharges = deliveryTaxController.text;

    // Perform Firebase update here
    FirebaseFirestore.instance
        .collection('special')
        .doc('UYmil6gQ34PgL51cLxcS')
        .update({
      'discount': discount,
      'shiping': shipping,
      'deliveryTax': deliveryCharges,
      'packingCharges': packingCharges,
    });

    // Clear text field values after update
    discountController.clear();
    shippingController.clear();
    packingChargesController.clear();
    deliveryTaxController.clear();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Discount and Shipping updated successfully'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Special Banner Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.file(_images[index]);
              },
            ),
          ),
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text('Pick Images'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImages,
                    child: const Text('Upload Images'),
                  ),
          ),
          // here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Discount',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: shippingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Shipping',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: packingChargesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Packing Charges',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: deliveryTaxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Delivery Tax',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _updateSettings,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
