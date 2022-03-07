import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class User extends Equatable {
  User({required this.id, required this.name});
  final String name;
  final String id;

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['display_name'];
    final id = json['id'];
    return User(name: name, id: id);
  }

  Map<String, dynamic> toJson() => {
    'display_name': name,

    'id': id
  };

  @override
  List<Object> get props => [name, id];
}
