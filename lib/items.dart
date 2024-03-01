import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:inventory/uploadItem.dart';

class ItemsScreen extends StatefulWidget {
  String? title, docID;
  ItemsScreen({Key? key, required this.title, this.docID}) : super(key: key);

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  Future<void> deleteItem(String documentId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.docID)
          .collection(widget.title.toString())
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs[index].reference.delete();
        } else {}
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting item'),
        ),
      );
    }
  }

  final TextEditingController _editedNameController = TextEditingController();
  // final TextEditingController _editedDescriptionController =
  //     TextEditingController();
  final TextEditingController _editedPriceController = TextEditingController();
  // TextEditingController _editedOldPriceController = TextEditingController();
  final TextEditingController _editedRateController = TextEditingController();

  Future<void> editItem(
      String documentId, int index, Map<String, dynamic> data) async {
    // Add your edit functionality here
    // Update the Firestore document with the new data
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docID)
        .collection(widget.title.toString())
        .doc(documentId)
        .update(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item edited successfully'),
      ),
    );
  }

  Future<void> _showEditDialog(
      String documentId, int index, Map<String, dynamic> item) async {
    _editedNameController.text = item['productName'];
    // _editedDescriptionController.text = item['productDescription'];
    _editedPriceController.text = item['productPrice'].toString();
    // _editedOldPriceController.text = item['productOldPrice'].toString();
    _editedRateController.text = item['productRate'].toString();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _editedNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                // TextField(
                //   controller: _editedDescriptionController,
                //   decoration: InputDecoration(labelText: 'Description'),
                // ),
                TextField(
                  controller: _editedPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                // TextField(
                //   controller: _editedOldPriceController,
                //   decoration: InputDecoration(labelText: 'Old Price'),
                // ),
                TextField(
                  controller: _editedRateController,
                  decoration: InputDecoration(labelText: 'Rate'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the edited data from the text controllers
                Map<String, dynamic> editedData = {
                  'productName': _editedNameController.text,
                  // 'productDescription': _editedDescriptionController.text,
                  'productPrice': double.parse(_editedPriceController.text),
                  // 'productOldPrice':
                  //     double.parse(_editedOldPriceController.text),
                  'productRate': double.parse(_editedRateController.text),
                };

                // Call the editItem method to update the Firestore document
                editItem(documentId, index, editedData);

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => UploadItemsScreen(
                      title: widget.title.toString(),
                    )),
          );
        },
      ),
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collectionGroup(widget.title.toString())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items available'));
          }

          Future<List<String>> _getImages(List<dynamic> imageUrls) async {
            List<String> images = [];
            for (String imageUrl in imageUrls) {
              // Fetch image from network
              images.add(imageUrl);
            }
            return images;
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var item = snapshot.data!.docs[index];
              var itemName = item['productName'];
              var itemImage = item['images'];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Container(
                      // height: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // SizedBox(
                                  //   width: 100,
                                  //   height: 100,
                                  //   child: Image.network(itemImage),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text('Name : '),
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                itemName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Row(
                                        //   children: [
                                        //     const Text('Description : '),
                                        //     Text(
                                        //       item['productDescription'],
                                        //       overflow: TextOverflow.ellipsis,
                                        //       maxLines: 1,
                                        //     ),
                                        //   ],
                                        // ),
                                        // Row(
                                        //   children: [
                                        //     const Text('Units : '),
                                        //     Text(
                                        //         '₹ ${item['productUnits']..toString()}'),
                                        //   ],
                                        // ),
                                        Row(
                                          children: [
                                            const Text('Price : '),
                                            Text(
                                                '₹ ${item['productPrice'].toString()}'),
                                          ],
                                        ),
                                        // Row(
                                        //   children: [
                                        //     const Text('Old Price : '),
                                        //     Text(
                                        //         '₹ ${item['productOldPrice'].toString()}'),
                                        //   ],
                                        // ),
                                        Row(
                                          children: [
                                            const Text('Rate : '),
                                            Text(
                                                '₹ ${item['productRate'].toString()}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        _showEditDialog(
                                            item.id,
                                            index,
                                            (item.data()
                                                as Map<String, dynamic>));
                                      },
                                      child: const Icon(Icons.edit)),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete Item ?'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      'You really want to delete this item ?')
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('No')),
                                                TextButton(
                                                    onPressed: () {
                                                      deleteItem(
                                                          item.id, index);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Yes'))
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          FutureBuilder(
                            future: _getImages(itemImage),
                            builder: (context,
                                AsyncSnapshot<List<String>> imageSnapshot) {
                              if (imageSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (imageSnapshot.hasError ||
                                  !imageSnapshot.hasData ||
                                  imageSnapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No images available'));
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: imageSnapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    imageSnapshot.data![index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
