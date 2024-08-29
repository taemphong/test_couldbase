import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couldbase_boat/database/database_helper.dart';
import 'package:couldbase_boat/database/model.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class SearchProduct extends StatefulWidget {
  SearchProduct({Key? key, required this.dbHelper}) : super(key: key);
  DatabaseHelper dbHelper;

  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  String _searchValue = '';
  List<Product> resultProducts = [];
  // String name = '', description = '';
  // double price = 0.00;
  bool found = false;

  void _showResponse(QuerySnapshot response) {
    setState(() {
      if (response.docs.isNotEmpty) {
        found = true;
        resultProducts.clear();
        for (var element in response.docs) {
          resultProducts.add(Product(
              name: element.get('name'),
              description: element.get('description'),
              price: element.get('price'),
              favorite: element.get('favorite')));
        }
      } else {
        found = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              onChanged: (value) => _searchValue = value,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.play_circle),
                    onPressed: () async {
                      await widget.dbHelper
                          .searchProduct(_searchValue)
                          .then((res) {
                        _showResponse(res);
                      });
                    },
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: found
          ? buildFoundList()
          : const Center(
              child: Text("Search Result (Not Found)"),
            ),
    );
  }

  Widget buildFoundList() {
    return ListView.builder(
        itemCount: resultProducts.length,
        itemBuilder: (context, index) {
          return Card(
              child: ListTile(
            title: Text('Name: ${resultProducts[index].name}'),
            subtitle: Text(
                'Description:  ${resultProducts[index].description}/ Price: ${resultProducts[index].price}'),
          ));
        });
  }
}
