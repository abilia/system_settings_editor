package com.abilia.system_settings_editor

import android.content.Context
import android.media.AudioManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VolumeSettingsHandler(context: Context) {

  private val audioManager: AudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

  internal fun getAlarmVolume(): Double {
    return audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION) / getAlarmMaxVolume().toDouble()
  }

  internal fun getMediaVolume(): Double {
    return audioManager.getStreamVolume(AudioManager.STREAM_MUSIC) / getMediaMaxVolume().toDouble()
  }

  internal fun setAlarmVolumeHandler(call: MethodCall, result: MethodChannel.Result) {
    val volume: Double? = call.argument(ARG_VOLUME)
    volume?.let {
      setAlarmVolume(it)
      result.success(true)
    } ?: run {
      result.error("ARGUMENT", "No argument $ARG_VOLUME of type double provided", null)
    }
  }

  internal fun setMediaVolumeHandler(call: MethodCall, result: MethodChannel.Result) {
    val volume: Double? = call.argument(ARG_VOLUME)
    volume?.let {
      setMediaVolume(it)
      result.success(true)
    } ?: run {
      result.error("ARGUMENT", "No argument $ARG_VOLUME of type double provided", null)
    }
  }

  internal fun getAlarmMaxVolume(): Int {
    return audioManager.getStreamMaxVolume(AudioManager.STREAM_NOTIFICATION)
  }

  internal fun getMediaMaxVolume(): Int {
    return audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
  }


  private fun setAlarmVolume(volume: Double) {
    val max = getAlarmMaxVolume().toDouble();
    val add = 1.0 / (max + 1) * 0.5;
    audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, ((volume + add) * max).toInt(), 0)
  }

  private fun setMediaVolume(volume: Double) {
    val max = getMediaMaxVolume().toDouble();
    val add = 1.0 / (max + 1) * 0.5;
    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, ((volume + add) * max).toInt(), 0)
  }

  companion object {

    const val ARG_VOLUME = "volume"
  }

}