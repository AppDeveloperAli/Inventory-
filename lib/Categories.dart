import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/items.dart';
import 'package:inventory/makeCategory.dart';
import 'package:inventory/uploadItem.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const MakeCategoryScreen(),
              ));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 25),
      ),
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: const CircularProgressIndicator());
          }

          var categories = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index].data();
                var categoryName = category['categoryName'];
                var categoryImage = category['categoryImage'];
                var categoryId = categories[index].id;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ItemsScreen(
                                title: categoryName,
                                docID: categoryId,
                              )),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(categoryImage),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    categoryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      editCategoryDialog(context, categoryName,
                                          categoryImage, categoryId);
                                    },
                                    child: const Icon(Icons.edit)),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete Category'),
                                              content: const Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      'Are you really want to delete this Category ?')
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    // Update the data in Firestore with new values
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'categories')
                                                        .doc(categoryId)
                                                        .delete();
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'categories')
                                                        .doc(categoryId)
                                                        .collection(
                                                            categoryName)
                                                        .get()
                                                        .then(
                                                      (QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          querySnapshot) {
                                                        querySnapshot.docs
                                                            .forEach(
                                                          (QueryDocumentSnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              document) {
                                                            document.reference
                                                                .delete();
                                                          },
                                                        );
                                                      },
                                                    );

                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the dialog without saving
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // return ListTile(
                //   title: Text(categoryName),
                //   subtitle: Image.network(categoryImage),
                // );
              },
            ),
          );
        },
      ),
    );
  }

  editCategoryDialog(
    BuildContext context,
    String currentCategoryName,
    String currentCategoryImage,
    String categoryId,
  ) {
    TextEditingController nameController =
        TextEditingController(text: currentCategoryName);
    TextEditingController imageController =
        TextEditingController(text: currentCategoryImage);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: imageController,
                decoration:
                    const InputDecoration(labelText: 'Category Image URL'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(categoryId)
                    .update({
                  'categoryName': nameController.text,
                  'categoryImage': imageController.text,
                });

                // Fetch the documents from the old subcollection
                QuerySnapshot<Map<String, dynamic>> documents =
                    await FirebaseFirestore.instance
                        .collection('categories')
                        .doc(categoryId)
                        .collection(currentCategoryName)
                        .get();

                // Choose a new subcollection name
                String newSubcollectionName = nameController.text;

                // Copy data from the old subcollection to the new subcollection
                for (QueryDocumentSnapshot<Map<String, dynamic>> document
                    in documents.docs) {
                  await FirebaseFirestore.instance
                      .collection('categories')
                      .doc(categoryId)
                      .collection(newSubcollectionName)
                      .doc(document.id)
                      .set(document.data()!);
                }

                // Delete the old subcollection
                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(categoryId)
                    .collection(currentCategoryName)
                    .get()
                    .then(
                  (QuerySnapshot<Map<String, dynamic>> querySnapshot) {
                    querySnapshot.docs.forEach(
                      (QueryDocumentSnapshot<Map<String, dynamic>> document) {
                        document.reference.delete();
                      },
                    );
                  },
                );

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
