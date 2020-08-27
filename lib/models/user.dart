import 'package:meta/meta.dart';

class User {
  String username;
  String jwt;
  String cartId;

  User({@required this.username, @required this.jwt, @required this.cartId});

  factory User.fromJson(json) {
    print("enter");
    print(json['user']);
    print(json['jwt']);
    print(json['cartId']);
    print('jwt: ');
    return User(
        username: json['user'], jwt: json['jwt'], cartId: json['cartId']);
  }
}
