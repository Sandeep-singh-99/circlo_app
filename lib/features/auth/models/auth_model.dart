import 'dart:io';

import 'package:circlo_app/features/bio/models/bio_model.dart';

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
  final BioModel? bio;

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
    this.bio,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String?,
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageUrlID: json['imageUrlID'] as String?,
      // 'image' is a local File for uploads only — never comes from JSON
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      bio: json['bio'] != null
          ? BioModel.fromJson(json['bio'] as Map<String, dynamic>)
          : null,
    );
  }
}
