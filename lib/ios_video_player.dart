import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class IosVideoPlayer extends StatefulWidget{
  @override
  _IosVideoPlayerState createState() => _IosVideoPlayerState();
}

class _IosVideoPlayerState extends State<IosVideoPlayer> with WidgetsBindingObserver {
  String mediaUrl;
  bool isLoading=true;
  ChewieController chewieController;
  VideoPlayerController _vController;
  Future _switchOrientation() async {

    SharedPreferences _shared=await SharedPreferences.getInstance();
        if(await File(_shared.getString("Video_2")).exists()){
          print("dkfjisdf");
        }else{
          print("dsfjhjsd");
        }
        _vController=VideoPlayerController.file(File(_shared.getString("Video_2")));
         chewieController = ChewieController(
          videoPlayerController: _vController,
          aspectRatio: 3 / 2,
          autoPlay: true,
          looping: true,
          allowFullScreen: false,
           showControlsOnInitialize: true,
           showControls: true,
        );
        setState(() {
          mediaUrl=_shared.getString("Video_2");
          isLoading=false;
        });

//    await SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight
//    ]).then((_) async {
//      await SystemChrome.setEnabledSystemUIOverlays([]);
//      Screen.keepOn(true);
//    });

  }
  @override
  void initState() {
    super.initState();
//    print("xcgfdhdghdf ");
    WidgetsBinding.instance.addObserver(this);
    _switchOrientation();
  }

  @override
  void dispose() {
    super.dispose();
    //print("xcgfdhdghdf ");
    _vController.dispose();
    chewieController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          mediaUrl!=null?
          Chewie(
            controller: chewieController,
          )
              :Container(),
          isLoading?Center(child: Container(color: Colors.white),):Container(),
          isLoading?Container():Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 25,left:  25),
              child: GestureDetector(
                child:Icon(Icons.close, size: 30, color: Colors.white,) ,
                onTap: () async {
//                  SystemChrome.setPreferredOrientations(
//                      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
//                      .then((_) async {
//                    Screen.keepOn(false);
//                    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                    Navigator.pop(context);
//                  });
                },
              ),
            ),
          ) ,

        ],
      ),
    );
    throw UnimplementedError();
  }
}