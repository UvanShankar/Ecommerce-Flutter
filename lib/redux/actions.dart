import 'dart:convert';
import 'dart:io';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ecommerce/models/app_state.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* User Actions */
ThunkAction<AppState> getUserAction = (Store<AppState> store) async {
  print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq  getuseraction");
  final prefs = await SharedPreferences.getInstance();
  final myString = prefs.getString('user'); //?? '';
  final user = myString != null ? User.fromJson(json.decode(myString)) : null;
  store.dispatch(GetUserAction(user));
};

ThunkAction<AppState> logoutUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user');
  User user;
  store.dispatch(LogoutUserAction(user));
};

class GetUserAction {
  final User _user;

  User get user => this._user;

  GetUserAction(this._user);
}

class LogoutUserAction {
  final User _user;

  User get user => this._user;

  LogoutUserAction(this._user);
}

/* Products Actions */
ThunkAction<AppState> getProductsAction = (Store<AppState> store) async {
  print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq  getprodaction");
  http.Response response = await http.get(
    'https://ecommerce-app-flutter-mongo.herokuapp.com/product/',
  );
  print(response.body);
  var abc = json.decode(response.body);
  print("jfhgfj222");
  print(abc);
  final List<dynamic> responseData = abc['result'];
  List<Product> products = [];
  responseData.forEach((productData) {
    final Product product = Product.fromJson(productData);
    products.add(product);
  });
  print("jfhgfj");
  print(responseData);
  print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq  getprodaction  over");
  store.dispatch(getCartProductsAction);
  store.dispatch(GetProductsAction(products));
};

class GetProductsAction {
  final List<Product> _products;

  List<Product> get products => this._products;

  GetProductsAction(this._products);
}

/* Cart Products Actions */
ThunkAction<AppState> toggleCartProductAction(Product cartProduct) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = store.state.cartProducts;
    final User user = store.state.user;
    final int index =
        cartProducts.indexWhere((product) => product.id == cartProduct.id);
    bool isInCart = index > -1 == true;
    List<Product> updatedCartProducts = List.from(cartProducts);
    if (isInCart) {
      updatedCartProducts.removeAt(index);
    } else {
      updatedCartProducts.add(cartProduct);
    }
    //////
    final List<String> cartProductsIds = updatedCartProducts
        //.map((product) => "\"" + product.id.toString() + "\"")
        .map((product) => product.id.toString())
        .toList();
    print("cartProductsIds");
    print(cartProductsIds);
    String url =
        'https://ecommerce-app-flutter-mongo.herokuapp.com/cart/${user.cartId}';
    Map map = {"products": json.encode(cartProductsIds)};
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.putUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(map)));
    HttpClientResponse response = await request.close();
    //var responseData, contentss;

    response.transform(utf8.decoder).listen((contents) async {
      print(json.decode(contents));
      //  responseData = json.decode(contents);
      // contentss = contents;
      print(response.statusCode);
    });
    store.dispatch(ToggleCartProductAction(updatedCartProducts));
  };
}

ThunkAction<AppState> getCartProductsAction = (Store<AppState> store) async {
  print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq  getcartaction");

  final prefs = await SharedPreferences.getInstance();
  final String storedUser = prefs.getString('user');
  if (storedUser == null) {
    return;
  }
  final User user = User.fromJson(json.decode(storedUser));
  http.Response response = await http.get(
      'https://ecommerce-app-flutter-mongo.herokuapp.com/cart/${user.cartId}',
      headers: {'Authorization': 'Bearer ${user.jwt}'});
  final responseData = json.decode(response.body)['result']['products'];
  print('responseData');
  print(responseData);
  var sas = store.state.products;
  print('sas');
  print(sas);
  List<Product> cartProducts = [];
  responseData.forEach((productData) {
    print('productData');
    print(productData);
    sas.forEach((element) {
      print('element');
      print(element);
      if (element.id == productData) {
        print('element.description');
        print(element.description);
        cartProducts.add(element);
      }
    });
    //  final Product product = Product.fromJson(productData);
  });
  sas = store.state.products;
  print('sas');
  print(sas);

  store.dispatch(GetCartProductsAction(cartProducts));
};

class ToggleCartProductAction {
  final List<Product> _cartProducts;

  List<Product> get cartProducts => this._cartProducts;

  ToggleCartProductAction(this._cartProducts);
}

class GetCartProductsAction {
  final List<Product> _cartProducts;

  List<Product> get cartProducts => this._cartProducts;

  GetCartProductsAction(this._cartProducts);
}
