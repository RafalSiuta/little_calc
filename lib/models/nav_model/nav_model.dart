import 'package:flutter/material.dart';

class NavModel {
  const NavModel({
    this.title = '',
    this.icon = Icons.circle,
  });

  final String title;
  final IconData icon;
}
