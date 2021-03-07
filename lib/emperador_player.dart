import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

enum PlayerState { STATE_IDLE, STATE_BUFFERING, STATE_READY, STATE_ERROR, STATE_PLAYING }

abstract class OnPlayerStateListener {
  onStateChange(PlayerState state);

  onMetadataChange(Map metaData);
}

class AudioPlayer {
  final _channel = const MethodChannel('com.emperador.player/channel');
  PlayerState _state = PlayerState.STATE_IDLE;
  OnPlayerStateListener _eventListener;

  listenEvents(OnPlayerStateListener eventListener) {
    _channel.setMethodCallHandler(this._onEventListener);
    this._eventListener = eventListener;
  }

  syncState() async {
    if (_eventListener != null) {
      await _channel.invokeMethod('sync-state');
    }
  }

  Future<void> _onEventListener(MethodCall call) async {
    final String arguments = call.arguments;
    switch (call.method) {
      case "playing":
        _state = PlayerState.STATE_PLAYING;
        break;
      case "ready":
        _state = PlayerState.STATE_READY;
        break;
      case "idle":
        _state = PlayerState.STATE_IDLE;
        break;
      case "error":
        _state = PlayerState.STATE_ERROR;
        break;
      case "metadata":
        this._eventListener.onMetadataChange(jsonDecode(arguments));
        break;
    }

    print(_state);
    this._eventListener.onStateChange(_state);
  }

  Future<Null> config(String url, String metaDivider) async {
    var parameters = {'url': url, 'metaDivider': '-'};
    await _channel.invokeMethod('config', new Map.from(parameters));
  }

  Future<Null> play() async {
    if (_state != PlayerState.STATE_READY) {
      print("Cannot play if not ready state!");
      return;
    }
    await _channel.invokeMethod('play');
  }

  Future<Null> pause() async {
    await _channel.invokeMethod('pause');
  }

  Future<Null> stop() async {
    await _channel.invokeMethod('stop');
  }

  Future<Null> close() async {
    await _channel.invokeMethod('close');
  }
}
