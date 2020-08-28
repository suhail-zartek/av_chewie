import 'package:av_player/productlist_view.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text('Click me'),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProductListView()));
          },
        ),
      ),
    );
  }
}
