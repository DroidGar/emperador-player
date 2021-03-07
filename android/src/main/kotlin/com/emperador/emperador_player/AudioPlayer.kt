package com.emperador.emperador_player

import android.content.Context
import android.util.Log
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.metadata.Metadata
import com.google.android.exoplayer2.metadata.MetadataOutput
import com.google.android.exoplayer2.metadata.icy.IcyHeaders
import com.google.android.exoplayer2.metadata.icy.IcyInfo
import com.google.android.exoplayer2.source.DefaultMediaSourceFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class AudioPlayer(var context: Context, binaryMessenger: BinaryMessenger) {
    var methodChannel = MethodChannel(binaryMessenger, "com.emperador.player/channel")
    lateinit var player: SimpleExoPlayer
    var isConfigured = false;


    fun config(url: String?, metaDivider: String?) {
        methodChannel.invokeMethod("idle", null)

        if (url == null) return

        player = SimpleExoPlayer.Builder(context)
                .setMediaSourceFactory(DefaultMediaSourceFactory(context).setLiveTargetOffsetMs(5000))
                .build()

        val mediaItem: MediaItem = MediaItem.Builder()
                .setUri(url)
                .setLiveMaxPlaybackSpeed(1.02f)
                .build()


        val eventListener = object : Player.EventListener {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                if (playbackState == Player.STATE_IDLE) methodChannel.invokeMethod("idle", null)
                if (playbackState == Player.STATE_BUFFERING) methodChannel.invokeMethod("loading", null)
                if (playbackState == Player.STATE_READY) methodChannel.invokeMethod("ready", null)
                if (playbackState == Player.STATE_ENDED) methodChannel.invokeMethod("idle", null)
                if (isPlaying()) methodChannel.invokeMethod("playing", null)
            }

            override fun onPlayerError(error: ExoPlaybackException) {
                methodChannel.invokeMethod("error", error)
            }
        }

        val metadataListener = MetadataOutput {
            val length: Int = it.length()
            var artist = ""
            var song = ""
            var genre = ""

            if (length > 0) {
                for (i in 0 until length) {
                    val entry: Metadata.Entry = it.get(i)
                    if (entry is IcyInfo) {
                        val icyInfo = entry as IcyInfo
                        var divider = "-"
                        if (metaDivider != null) divider = metaDivider
                        val splitted = icyInfo.title?.split(divider)!!
                        artist = splitted[0].trim()
                        song = splitted[1].trim()
                    } else if (entry is IcyHeaders) {
                        val icyHeaders = entry as IcyHeaders
                        genre = if (icyHeaders.genre != null) icyHeaders.genre!! else ""
                    }
                }
                methodChannel.invokeMethod("metadata", "{\"artist\":\"$artist\",\"song\":\"$song\",\"genre\":\"$genre\"}")
            }
        }

        player.addListener(eventListener)
        player.addMetadataOutput(metadataListener)
        player.setMediaItem(mediaItem)
        player.prepare()

        methodChannel.invokeMethod("ready", null)
        isConfigured = true;
    }

    fun syncState() {
        if (isConfigured) methodChannel.invokeMethod("ready", null)
        if (isPlaying()) methodChannel.invokeMethod("playing", null)
    }

    fun isPlaying(): Boolean {
        return player.playbackState == Player.STATE_READY && player.playWhenReady
    }

    fun play() {
        player.play()
    }

    fun close() {

    }

    fun stop() {
        player.stop()
    }

    fun pause() {
        player.pause()
    }


}


