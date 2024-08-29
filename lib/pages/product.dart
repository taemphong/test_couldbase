import 'package:couldbase_boat/database/database_helper.dart';
import 'package:flutter/material.dart';

import '../database/model.dart';
//
// *** Edit #1 *** => add new import for firebase
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'search.dart';

// ignore: must_be_immutable
class ProductScreen extends StatefulWidget {
  //
  // *** Edit #2 *** => add parameter of Product Screen
  //
  ProductScreen({Key? key, required this.dbHelper}) : super(key: key);

  DatabaseHelper dbHelper;
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // add List of Product variable for List creation
  List<Product> products = [];

  //
  // *** Edit #9 *** => Add confirmation dialog to confirm before delete item
  //
  Future<dynamic> _showConfirmDialog(BuildContext context, String action) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Do you want to $action this item?'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Yes')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                //
                // *** Edit #5 *** => add parameter of ModalProductForm
                //

                await ModalProductForm(
                  dbHelper: widget.dbHelper,
                ).showModalInputForm(context);
              },
              icon: const Icon(Icons.add_comment)),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchProduct(dbHelper: widget.dbHelper,),)
                  );
                },
                 icon: const Icon(Icons.search_outlined))
        ],
        title: const Text('Products'),
      ),
      //
      // *** Edit #7 *** => Add StreamBuilder for synchronize with Firebase cloud database
      //
       body: StreamBuilder<QuerySnapshot>(
        stream: widget.dbHelper.getStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        products.clear();
        for (var element in snapshot.data!.docs) {
          products.add(Product(
            name: element.get('name'),
            description: element.get('description'),
            price: element.get('price'),
            favorite: element.get('favorite'),
            referenceId: element.id));
          
        }
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          //
          // *** Edit #8 *** => Add swipe feature to delete item
          //
          return Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.blue),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_forever_outlined,
              color: Colors.white,size: 30)),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                widget.dbHelper.deleteProduct(products[index]);
              }
            },
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                return await _showConfirmDialog(context, 'Delete');
              }
              return false;
            },


            child: Card(
              child: ListTile(
                title: Text(products[index].name),
                subtitle: Text('Price: ${products[index].price.toString()}'),
                trailing: products[index].favorite == 1
                    ? const Icon(Icons.favorite_rounded, color: Colors.red)
                    : null,
                onTap: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(productdetail: products[index]),
                    ),
                  );
                  setState(() {
                    if (result != null) {
                      products[index].favorite = result;
                      //
                      // *** Edit #6 *** => update favorite flag to firebase
                      //
                      widget.dbHelper.updateProduct(products[index]);
                    }
                  });
                },
                //
                // *** Edit 11 *** => Add longPress event to edit product
                //
                onLongPress: () async {
                  await ModalEditProductForm(
                    dbHelper: widget.dbHelper,
                    editedProduct: products[index],
                     ).showModalInputForm(context);
                }
              ),
            ),
          );
        },
      );
        }
      ),
    );
  
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.productdetail}) : super(key: key);

  final Product productdetail;

  @override
  Widget build(BuildContext context) {
    var result = productdetail.favorite;
    return Scaffold(
      appBar: AppBar(
        title: Text(productdetail.name),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            child: Text(productdetail.description),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10, top: 20.0),
            child: Text('Price: ${productdetail.price.toString()}'),
          ),
          Container(
            padding: const EdgeInsets.only(top: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 40),
                      primary: productdetail.favorite == 1
                          ? Colors.blueGrey
                          : Colors.redAccent),
                  child: productdetail.favorite == 1
                      ? const Text('Unfavorite')
                      : const Text('Favorite'),
                  onPressed: () {
                    result = productdetail.favorite == 1 ? 0 : 1;
                    Navigator.pop(context, result);
                  },
                ),
                ElevatedButton(
                  child: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(120, 40),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModalProductForm {
  //
  // *** Edit #3 *** => parameter of ModalProductForm
  //
  ModalProductForm({Key? key, required this.dbHelper});

  DatabaseHelper dbHelper;

  String _name = '', _description = '';
  double _price = 0;
  final int _favorite = 0;

  Future<dynamic> showModalInputForm(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Center(
                    child: Text(
                      'Product input Form',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: '',
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          hintText: 'input your name of product',
                        ),
                        onChanged: (value) {
                          _name = value;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: '',
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'input description of product',
                        ),
                        onChanged: (value) {
                          _description = value;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: '0.00',
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: 'input price',
                        ),
                        onChanged: (value) {
                          _price = double.parse(value);
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          child: const Text('Add'),
                          onPressed: () async {
                            //
                            // *** Edit #4 *** => add product here
                            //
                            var newProduct = Product(
                              name: _name,
                              description: _description,
                              price: _price,
                              favorite: _favorite,
                              referenceId: null);
                            await dbHelper.insertProduct(newProduct).then(
                              (value) => newProduct.referenceId = value.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${newProduct.name} is inserted complete...'),
                           ),
                       );      
                            Navigator.pop(context);
                          }),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

//
// *** Edit #10 *** => Add new class modal form for updating
//

class ModalEditProductForm {
  //
  // *** Edit #3 *** => parameter of ModalProductForm
  //
  ModalEditProductForm({Key? key, required this.dbHelper, required this.editedProduct});

  DatabaseHelper dbHelper;
  Product editedProduct;

  String _name = '', _description = '';
  double _price = 0;
  int _favorite = 0;
  String? _referenceId;



  Future<dynamic> showModalInputForm(BuildContext context) {
    _name = editedProduct.name;
    _description = editedProduct.description;
    _price = editedProduct.price;
    _favorite = editedProduct.favorite;
    _referenceId = editedProduct.referenceId;

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Center(
                    child: Text(
                      'Product input Form',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: _name,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          hintText: 'input your name of product',
                        ),
                        onChanged: (value) {
                          _name = value;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'input description of product',
                        ),
                        onChanged: (value) {
                          _description = value;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: TextFormField(
                        initialValue: _price.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: 'input price',
                        ),
                        onChanged: (value) {
                          _price = double.parse(value);
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          child: const Text('Update'),
                          onPressed: () async {
                            //
                            // *** Edit #4 *** => add product here
                            //
                            var newProduct = Product(
                              name: _name,
                              description: _description,
                              price: _price,
                              favorite: _favorite,
                              referenceId: _referenceId);
                              dbHelper.updateProduct(newProduct);
                              Navigator.pop(context);
                          }),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
