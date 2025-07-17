import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DrawerHeader(
            child: Row(children: [Icon(Icons.description), Text('Docket')]),
          ),
          Column(
            children: [
              ListTile(leading: Icon(Icons.home), title: Text('H O M E')),
              ListTile(leading: Icon(Icons.logout), title: Text('L O G O U T')),
            ],
          ),
        ],
      ),
    );
  }
}
