import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Artist extends Equatable {
  Artist({required this.name, required this.href});
  final String name;
  final String href;

  factory Artist.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final href = json['href'];
    return Artist(name: name, href: href);
  }

  @override
  List<Object> get props => [name, href];
}
