import 'package:cloud_firestore/cloud_firestore.dart' ;
import 'model.dart';

class DatabaseHelper {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection(Product.collectionName);

      Future<DocumentReference> insertProduct(Product product) {
        return collection.add(product.toJson());
      }

      
      void updateProduct(Product product) async {
        await collection.doc(product.referenceId).update(product.toJson());
      }


      void deleteProduct(Product product) async {
        await collection.doc(product.referenceId).delete();
      }


      Stream<QuerySnapshot> getStream(){
        return collection.snapshots();
      }
      Future<QuerySnapshot> searchProduct(String keyValue) {
        return collection.where(Product.colName, isEqualTo: keyValue).get();
      }
}