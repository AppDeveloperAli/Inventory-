import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory/uploadItem.dart';
import 'package:inventory/widget/textfield.dart';

class MakeCategoryScreen extends StatefulWidget {
  const MakeCategoryScreen({Key? key});

  @override
  _MakeCategoryScreenState createState() => _MakeCategoryScreenState();
}

class _MakeCategoryScreenState extends State<MakeCategoryScreen> {
  TextEditingController _categoryNameController = TextEditingController();
  TextEditingController _categoryImageController = TextEditingController();
  // File? _image;

  // Future<void> _getImage() async {
  //   final imagePicker = ImagePicker();
  //   final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // _image != null
              //     ? Image.file(
              //         _image!,
              //         height: 300,
              //         width: double.infinity,
              //         fit: BoxFit.cover,
              //       )
              //     : Container(),
              // Padding(
              //   padding: const EdgeInsets.only(top: 20),
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue[600],
              //       elevation: 5,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     onPressed: _getImage,
              //     child: const Text(
              //       'Pick Image',
              //       style: TextStyle(color: Colors.white, fontSize: 18),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
              MyTextFieldFormWidget(
                hintText: 'Category Image',
                controller: _categoryImageController,
              ),
              MyTextFieldFormWidget(
                hintText: 'Category Name',
                controller: _categoryNameController,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_categoryNameController.text.isNotEmpty &&
                      _categoryImageController.text.isNotEmpty) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => UploadItemsScreen(
                            title: _categoryNameController.text,
                            image: _categoryImageController.text,
                          ),
                        ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Please Put your Image and Title of Category'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Create Category',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
