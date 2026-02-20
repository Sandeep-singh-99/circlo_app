import 'dart:io';

final class AuthModel {
  final String? token;
  final String? id;
  final String name;
  final String email;
  final String? imageUrl;
  final String? imageUrlID;
  final File? image;
  final String? createdAt;
  final String? updatedAt;


  AuthModel({
    this.token,
    this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.imageUrlID,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      id: json['id'],
      name: json['name'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      imageUrlID: json['imageUrlID'],
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
