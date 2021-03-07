import 'package:emperador_player/emperador_player.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements OnPlayerStateListener {
  AudioPlayer _player = new AudioPlayer();
  PlayerState _state = PlayerState.STATE_IDLE;
  String artist, song;

  @override
  void initState() {
    super.initState();
    _player.listenEvents(this);
    _player.syncState();
  }

  @override
  Widget build(BuildContext context) {
    var url = "https://22823.live.streamtheworld.com/ASPEN.mp3";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(artist ?? ""),
              Text(song ?? ''),
              _state == PlayerState.STATE_BUFFERING ? Text("cargando...") : Container(),
              _state == PlayerState.STATE_IDLE || _state == PlayerState.STATE_ERROR
                  ? ElevatedButton(onPressed: () => _player.config(url, "-"), child: Text("config"))
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _state == PlayerState.STATE_READY ? ElevatedButton(onPressed: () => _player.play(), child: Text("play")) : Container(),
                  _state == PlayerState.STATE_PLAYING ? ElevatedButton(onPressed: () => _player.pause(), child: Text("pause")) : Container(),
                  _state == PlayerState.STATE_READY || _state == PlayerState.STATE_PLAYING
                      ? ElevatedButton(onPressed: () => _player.stop(), child: Text("stop"))
                      : Container(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  onStateChange(PlayerState state) {
    setState(() => _state = state);
  }

  @override
  onMetadataChange(Map metaData) {
    setState(() {
      artist = metaData['artist'];
      song = metaData['song'];
    });
  }
}
