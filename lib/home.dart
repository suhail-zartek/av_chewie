import 'package:av_player/productlist_view.dart';
import 'package:flutter/material.dart';

import 'ios_video_player.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              child: Text('Click me'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductListView()));
              },
            ),
            FlatButton(
              child: Text('Play'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IosVideoPlayer()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
