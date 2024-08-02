import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

bool verifyPassword(String password, String hashedPassword) {
  return hashPassword(password) == hashedPassword;
}

bool isValidEmail(String email) {
  String emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  RegExp regex = RegExp(emailPattern);
  return regex.hasMatch(email);
}

bool isValidPassword(String password) {
  String passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+=-]).{6,}$';
  RegExp regex = RegExp(passwordPattern);
  return regex.hasMatch(password);
}