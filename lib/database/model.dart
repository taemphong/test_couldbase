class Product {
  String name;
  double price;
  String description;
  int favorite;
  String? referenceId;
  //
  // *** Edit #1 *** => add referenceId
  //

  //
  // *** Edit #2 *** => add collectionName
  //
  static const collectionName = 'products' ;
  static const colName = 'name';
  static const colDescription = 'description';
  static const colPrice = 'price';
  static const colFavorite = 'favorite';

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.favorite,
    this.referenceId});
    //
    // *** Edit #3 *** => add new properties to constructor
    //
  

  Map<String, dynamic> toMap() {
    var mapData = <String, dynamic>{
      colName: name,
      colDescription: description,
      colPrice: price,
      colFavorite: favorite
    };
    return mapData;
  }


  //
  // *** Edit #4 *** => add new method to convert into Json format
  //
  Map<String, dynamic> toJson() {
    var jsonData = <String, dynamic>{
    colName: name,
    colDescription: description,
    colPrice: price,
    colFavorite: favorite
  };
  return jsonData;
}
}
