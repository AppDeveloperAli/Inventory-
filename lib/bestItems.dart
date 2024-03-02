import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class BestItems extends StatefulWidget {
  const BestItems({Key? key}) : super(key: key);

  @override
  State<BestItems> createState() => _BestItemsState();
}

class _BestItemsState extends State<BestItems> {
  bool isLoading = false;
  late TextEditingController _productNameController;
  late TextEditingController _productPriceController;
  late TextEditingController _productRateController;
  List<File> _images = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _productPriceController = TextEditingController();
    _productRateController = TextEditingController();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productRateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadProduct() async {
    setState(() {
      isLoading = true;
    });
    final productImages = <String>[];
    final storage = firebase_storage.FirebaseStorage.instance;
    final folderName = "bestProducts";

    // Upload images to Firebase Storage
    for (var i = 0; i < _images.length; i++) {
      final imageFile = _images[i];
      final fileName =
          '$folderName/image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      await storage.ref(fileName).putFile(imageFile);
      final downloadUrl = await storage.ref(fileName).getDownloadURL();
      productImages.add(downloadUrl);
    }

    // Upload product details to Firestore
    final productData = {
      'productName': _productNameController.text,
      'productPrice': _productPriceController.text,
      'productRate': _productRateController.text,
      'productImage': productImages,
      'productId': ''
      // Add other fields as needed
    };

    await FirebaseFirestore.instance
        .collection('bestProducts')
        .add(productData);

    // Clear form fields and selected images
    _productNameController.clear();
    _productPriceController.clear();
    _productRateController.clear();
    setState(() {
      _images.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Product uploaded successfully'),
    ));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Best Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: 'Product Price'),
            ),
            TextField(
              controller: _productRateController,
              decoration: InputDecoration(labelText: 'Product Rate'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Pick Images'),
            ),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.file(_images[index]);
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadProduct,
                    child: Text('Upload Product'),
                  ),
          ],
        ),
      ),
    );
  }
}
