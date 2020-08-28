import 'package:av_player/productcard_widget.dart';
import 'package:flutter/material.dart';

class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ProductListLayout(),
    );
  }
}

class ProductListLayout extends StatefulWidget {
  @override
  _ProductListLayoutState createState() => _ProductListLayoutState();
}

class _ProductListLayoutState extends State<ProductListLayout> {
  List<String> _videos = [
    'https://player.vimeo.com/external/445882756.m3u8?s=dfdff31e6806bc616cafa02f36753f45c3c07589',
    'https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8'
    // 'https://player.vimeo.com/external/435095590.m3u8?s=fe02358da38af71d20ba2262cf1cdd84265119d3',
  ];
  List<String> _title = ['Video_1', 'Video_2', 'Video_3'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return ProductCard(_title[index], _videos[index]);
      },
    );
  }
}
