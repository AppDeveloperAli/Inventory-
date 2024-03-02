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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Special Banner Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
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
          ),
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Pick Images'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImages,
                    child: Text('Upload Images'),
                  ),
          ),
        ],
      ),
    );
  }
}
