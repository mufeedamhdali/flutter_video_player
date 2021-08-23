import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Future<void> _future;
  bool netEnabled = true;
  bool downloading = false;
  var progressString = "";
  bool isLoading = true;

  // function to load video file from assets
  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return null;
    }
  }

  // to initialize video player controllers and load data
  Future<void> initVideoPlayer() async {
    //await new Future.delayed(const Duration(seconds: 2));
    //https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8

    await check();
    String url =
        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4';
    String filePath =
        '/data/user/0/com.machine.machine_test_mufeeda/app_flutter/videos/' +
            url.split('/').last;
    File videoFile = File(filePath);
    var video = myLoadAsset(filePath);

    // if network is not available video from local storage will load as controller
    if (!netEnabled && video != null) {
      _videoPlayerController = VideoPlayerController.file(videoFile);
      await _videoPlayerController.initialize();
    } else {
      _videoPlayerController = VideoPlayerController.network(
          'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4');
      await _videoPlayerController.initialize();
    }
    setState(() {
      print("hehe"+ _videoPlayerController.value.aspectRatio.toString());
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
      isLoading = false;
    });
    await new Future.delayed(const Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _future = initVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Target Learning"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.comment),
            tooltip: 'Comment Icon',
            onPressed: () {},
          ), //IconButton
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Setting Icon',
            onPressed: () {},
          ), //IconButton
        ],
        //<Widget>[]
        backgroundColor: Colors.blue,
        elevation: 50.0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Menu Icon',
          onPressed: () {},
        ),
        //IconButton
        brightness: Brightness.dark,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    new FutureBuilder(
                      future: _future,
                      builder: (context, snapshot) {
                        return new Align(
                          alignment: Alignment.topCenter,
                          child: _videoPlayerController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController.value.aspectRatio,
                                  child: Chewie(
                                    controller: _chewieController,
                                  ),
                                )
                              : new Padding(
                                  padding: EdgeInsets.all(100),
                                  child: CircularProgressIndicator(),
                                ),
                        );
                      },
                    ),
                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        padding: EdgeInsets.only(left: 15, top: 20),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Video Tutorial | Sample project",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildButtonColumn(
                            Icons.thumb_up,
                            "500",
                          ),
                          _buildButtonColumn(
                            Icons.thumb_down,
                            "0",
                          ),
                          _buildButtonColumn(
                            Icons.share,
                            "Share",
                          ),
                          _buildButtonColumn(
                            Icons.cloud_download,
                            "Download",
                          ),
                        ],
                      ),
                    ),
                    downloading
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: Card(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    "Downloading $progressString",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Text(""),
                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        padding:
                            EdgeInsets.only(left: 15, right: 15, bottom: 20),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                    Container(
                        decoration: BoxDecoration(color: Colors.white),
                        padding: EdgeInsets.only(left: 15, top: 20),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "All comments",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'Write your comment here',
                                ),
                                onChanged: (text) {},
                              )),
                          _buildCommentBox("Anusree",
                              "The passage experienced a surge in popularity during the 1960s when Letraset used it on their dry-transfer sheets, and again during the 90s as desktop publishers bundled the text with their software. Today it's seen all around the web"),
                          _buildCommentBox("Megha",
                              "again during the 90s as desktop publishers bundled the text with their software. Today it's seen all around the web"),
                          Padding(padding: EdgeInsets.all(20)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // widget for like, dislike, share and download
  Widget _buildButtonColumn(IconData icon, String text) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            icon: Icon(icon),
            onPressed: () {
              if (text == "Download") {
                downloadFile();
              }
            },
          ),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  // comment box widget
  Widget _buildCommentBox(String name, String comment) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      margin: EdgeInsets.only(top: 10, left: 15, right: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(2, 2),
              spreadRadius: 2,
              blurRadius: 3.0,
            ),
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(padding: EdgeInsets.all(10)),
          Text(comment),
        ],
      ),
    );
  }

  // function to download video to assets from static url
  Future<void> downloadFile() async {
    Dio dio = Dio();
    String videoUrl = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4";
    String fileName = videoUrl.split('/').last;

    try {
      var dir = await getApplicationDocumentsDirectory();
      print("path ${dir.path}");
      await dio.download(videoUrl, "${dir.path}" + "/videos/" + fileName,
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
        setState(() {
          downloading = true;
          progressString = "...";
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    print("Download completed");
  }

  // function to check network connectivity
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    //bool netEnabled;
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        netEnabled = true;
      });
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        netEnabled = true;
      });
      return true;
    }
    setState(() {
      netEnabled = false;
    });
    return false;
  }
}
