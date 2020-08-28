import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String url;

  ProductCard(this.title, this.url);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _channel = const MethodChannel('playerChannel');
  bool _isDownloading = false;
  double _downloadValue = 0.0;
  bool _isDownloaded = false;
  String _location;

  @override
  void initState() {
    super.initState();

    _getData();
    _getDataFromNative();
  }

  void _getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _location = sharedPreferences.getString(widget.title);

    if (_location != null) {
      _isDownloaded = true;
    } else {
      _isDownloaded = false;
    }
    setState(() {});
  }

  void _getDataFromNative() {
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'offlineDownloadLocation':
          {
            try {
              _saveLocation(call.arguments);
            } catch (e) {
              print(e.toString());
            }
            break;
          }
        case 'downloadProgress':
          {
            try {
              setState(() {
                _isDownloading = true;
                _downloadValue = call.arguments;
              });
            } catch (e) {
              print(e.toString());
            }
            break;
          }
        case 'videoDeleted':
          {
            try {
              _deltLocation();
            } catch (e) {
              print(e.toString());
            }
            break;
          }
      }
      return;
    });
  }

  void _saveLocation(String loc) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(widget.title, loc);

    setState(() {
      _isDownloaded = true;
      _isDownloading = false;
      _downloadValue = 0.0;
      _location = loc;
    });
  }

  void _deltLocation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(widget.title, null);
    setState(() {
      _isDownloaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.5),
          color: CupertinoColors.lightBackgroundGray),
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Text(widget.title),
          IconButton(
              onPressed: () async {
                try {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  var location = sharedPreferences.getString(widget.title);
                  if (location != null) {
                    await _channel
                        .invokeMethod('playOffline', {"location": location});
                  } else {
                    await _channel.invokeMethod('play', {"url": widget.url});
                  }
                } on PlatformException catch (e) {
                  print("Failed: '${e.message}'.");
                }
              },
              icon: Icon(Icons.play_arrow)),
          !_isDownloaded
              ? _isDownloading
                  ? CircularProgressIndicator(
                      value: _downloadValue,
                    )
                  : IconButton(
                      onPressed: () async {
                        try {
                          await _channel.invokeMethod('download',
                              {"url": widget.url, "name": widget.title});
                          _getDataFromNative();
                        } on PlatformException catch (e) {
                          print("Failed: '${e.message}'.");
                        }
                      },
                      icon: Icon(Icons.file_download),
                    )
              : Container(),
          _isDownloaded
              ? IconButton(
                  onPressed: () async {
                    try {
                      await _channel
                          .invokeMethod('delete', {"location": _location});
                      _getDataFromNative();
                    } on PlatformException catch (e) {
                      print("Failed: '${e.message}'.");
                    }
                  },
                  icon: Icon(Icons.delete))
              : Container(),
        ],
      ),
    );
  }
}
