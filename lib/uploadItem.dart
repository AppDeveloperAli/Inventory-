import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/main.dart';
import 'package:inventory/widget/textfield.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadItemsScreen extends StatefulWidget {
  String title;
  // String? image;
  final File? imag;

  UploadItemsScreen({super.key, required this.title, this.imag});

  @override
  State<UploadItemsScreen> createState() => _UploadItemsScreenState();
}

class _UploadItemsScreenState extends State<UploadItemsScreen> {
  final TextEditingController productCategoryController =
      TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productImageController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productOldPriceController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productRateController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? documentId;

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child("product_images");

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadTask =
          storageRef.child("product_$timestamp.jpg").putFile(imageFile);

      // Wait for the upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
      final downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("Error uploading image to Firebase Storage: $e");
      return null;
    }
  }

  File? _imageProd;

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageProd = File(pickedFile.path);
      });
    }
  }

  void uploadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if widget.imag is not null before proceeding with image upload
      final downloadURL = widget.imag != null
          ? await _uploadImageToFirebase(widget.imag!)
          : null;

      // Check if downloadURL is not null before proceeding
      if (downloadURL != null) {
        final downloadURLProd = await _uploadImageToFirebase(_imageProd!);

        // Query the collection based on categoryName
        QuerySnapshot querySnapshot = await firestore
            .collection('categories')
            .where('categoryName', isEqualTo: widget.title)
            .get();

        // Use the first document ID found (assuming categoryName is unique)
        String? documentId =
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs[0].id : null;

        if (documentId != null) {
          Map<String, dynamic> productData = {
            'productCategory': widget.title,
            'productDescription': productDescriptionController.text,
            'productId': null,
            'productImage': downloadURLProd,
            'productName': productNameController.text,
            'productOldPrice': _parseDouble(productOldPriceController.text),
            'productPrice': _parseDouble(productPriceController.text),
            'productRate': _parseInt(productRateController.text),
          };

          // Upload data to Firestore and get the DocumentReference
          DocumentReference docRef = await firestore
              .collection('categories')
              .doc(documentId)
              .collection(widget.title)
              .add(productData);

          // Update the 'productId' field in your productData map with the sub-collection document ID
          String subDocId = docRef.id;
          productData['productId'] = subDocId;

          // Update the data in Firestore with the correct 'productId'
          await firestore
              .collection('categories')
              .doc(documentId)
              .collection(widget.title)
              .doc(subDocId)
              .update({'productId': subDocId});

          // Clear text fields after successful upload
          productDescriptionController.clear();
          productIdController.clear();
          productImageController.clear();
          productNameController.clear();
          productOldPriceController.clear();
          productPriceController.clear();
          productRateController.clear();

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data uploaded successfully'),
            ),
          );
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        } else {
          CollectionReference categoriesCollection =
              FirebaseFirestore.instance.collection('categories');

          Map<String, dynamic> mainCollectionData = {
            'categoryImage': downloadURL,
            'categoryName': widget.title,
            'subcollectionData': null,
          };

          // Add data to the main parent collection
          DocumentReference mainCollectionRef =
              await categoriesCollection.add(mainCollectionData);

          // Reference to the subcollection within each category
          CollectionReference subcollectionRef =
              mainCollectionRef.collection(widget.title);

          Map<String, dynamic> subcollectionData = {
            'productCategory': widget.title,
            'productDescription': productDescriptionController.text,
            'productId': null,
            'productImage': downloadURLProd,
            'productName': productNameController.text,
            'productOldPrice': _parseDouble(productOldPriceController.text),
            'productPrice': _parseDouble(productPriceController.text),
            'productRate': _parseInt(productRateController.text),
          };

          // Update the main document with the subcollection data
          await mainCollectionRef
              .update({'subcollectionData': subcollectionData});

          // Upload data to the subcollection
          DocumentReference docRef =
              await subcollectionRef.add(subcollectionData);

          // Update the 'productId' field in your productData map with the sub-collection document ID
          String subDocId = docRef.id;
          subcollectionData['productId'] = subDocId;

          // Update the data in Firestore with the correct 'productId'
          await subcollectionRef.doc(subDocId).update({'productId': subDocId});

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
      } else {
        final downloadURLProd = await _uploadImageToFirebase(_imageProd!);

        // Query the collection based on categoryName
        QuerySnapshot querySnapshot = await firestore
            .collection('categories')
            .where('categoryName', isEqualTo: widget.title)
            .get();

        // Use the first document ID found (assuming categoryName is unique)
        String? documentId =
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs[0].id : null;

        if (documentId != null) {
          Map<String, dynamic> productData = {
            'productCategory': widget.title,
            'productDescription': productDescriptionController.text,
            'productId': null,
            'productImage': downloadURLProd,
            'productName': productNameController.text,
            'productOldPrice': _parseDouble(productOldPriceController.text),
            'productPrice': _parseDouble(productPriceController.text),
            'productRate': _parseInt(productRateController.text),
          };

          // Upload data to Firestore and get the DocumentReference
          DocumentReference docRef = await firestore
              .collection('categories')
              .doc(documentId)
              .collection(widget.title)
              .add(productData);

          // Update the 'productId' field in your productData map with the sub-collection document ID
          String subDocId = docRef.id;
          productData['productId'] = subDocId;

          // Update the data in Firestore with the correct 'productId'
          await firestore
              .collection('categories')
              .doc(documentId)
              .collection(widget.title)
              .doc(subDocId)
              .update({'productId': subDocId});

          // Clear text fields after successful upload
          productDescriptionController.clear();
          productIdController.clear();
          productImageController.clear();
          productNameController.clear();
          productOldPriceController.clear();
          productPriceController.clear();
          productRateController.clear();

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data uploaded successfully'),
            ),
          );
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        } else {
          CollectionReference categoriesCollection =
              FirebaseFirestore.instance.collection('categories');

          Map<String, dynamic> mainCollectionData = {
            'categoryImage': downloadURL,
            'categoryName': widget.title,
            'subcollectionData': null,
          };

          // Add data to the main parent collection
          DocumentReference mainCollectionRef =
              await categoriesCollection.add(mainCollectionData);

          // Reference to the subcollection within each category
          CollectionReference subcollectionRef =
              mainCollectionRef.collection(widget.title);

          Map<String, dynamic> subcollectionData = {
            'productCategory': widget.title,
            'productDescription': productDescriptionController.text,
            'productId': null,
            'productImage': downloadURLProd,
            'productName': productNameController.text,
            'productOldPrice': _parseDouble(productOldPriceController.text),
            'productPrice': _parseDouble(productPriceController.text),
            'productRate': _parseInt(productRateController.text),
          };

          // Update the main document with the subcollection data
          await mainCollectionRef
              .update({'subcollectionData': subcollectionData});

          // Upload data to the subcollection
          DocumentReference docRef =
              await subcollectionRef.add(subcollectionData);

          // Update the 'productId' field in your productData map with the sub-collection document ID
          String subDocId = docRef.id;
          subcollectionData['productId'] = subDocId;

          // Update the data in Firestore with the correct 'productId'
          await subcollectionRef.doc(subDocId).update({'productId': subDocId});

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
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (_imageProd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please Pick a Product Image'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data: $error'),
          ),
        );
      }
      // Handle error as needed
    }
  }

  double _parseDouble(String value) {
    try {
      return value.isEmpty ? 0.0 : double.parse(value);
    } catch (e) {
      // Handle the exception, e.g., return a default value or show an error message.
      return 0.0;
    }
  }

  int _parseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      // Handle the exception, e.g., return a default value or show an error message.
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyTextFieldFormWidget(
                  hintText: 'Product Name',
                  controller: productNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Name';
                    }
                    return null;
                  },
                ),
                MyTextFieldFormWidget(
                  controller: productDescriptionController,
                  hintText: 'Product Description',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Description';
                    }
                    return null;
                  },
                ),
                MyTextFieldFormWidget(
                  hintText: 'Product Image URL',
                  controller: productImageController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Image URL';
                    }
                    return null;
                  },
                ),
                MyTextFieldFormWidget(
                  keyboardType: TextInputType.number,
                  hintText: 'Product Old Price',
                  controller: productOldPriceController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Old Price';
                    }
                    return null;
                  },
                ),
                MyTextFieldFormWidget(
                  keyboardType: TextInputType.number,
                  controller: productPriceController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Price';
                    }
                    return null;
                  },
                  hintText: 'Product Price',
                ),
                MyTextFieldFormWidget(
                  keyboardType: TextInputType.number,
                  controller: productRateController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Product Rate';
                    }
                    return null;
                  },
                  hintText: 'Product Rate',
                ),
                _imageProd != null
                    ? Image.file(
                        _imageProd!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _getImage,
                    child: const Text(
                      'Pick Image',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: uploadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upload Item',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
