package com.abilia.system_settings_editor

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class SystemSettingsEditorPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private lateinit var systemSettingsHandler: SystemSettingsHandler
  private lateinit var volumeSettingsHandler: VolumeSettingsHandler

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "system_settings_editor")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    systemSettingsHandler = SystemSettingsHandler(context)
    volumeSettingsHandler = VolumeSettingsHandler(context)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (!Settings.System.canWrite(context)) {
      openAndroidPermissionsMenu()
      result.error("ACCESS", "Cannot write to system settings. Permission needed.", null)
    } else {
      when (call.method) {
        METHOD_GET_BRIGHTNESS -> result.success(systemSettingsHandler.getBrightness())
        METHOD_SET_BRIGHTNESS -> systemSettingsHandler.setBrightnessHandler(activity, call, result)
        METHOD_GET_SOUND_EFFECTS -> result.success(systemSettingsHandler.getSoundEffectsEnabled())
        METHOD_SET_SOUND_EFFECTS -> systemSettingsHandler.setSoundEffectsHandler(call, result)
        METHOD_GET_ALARM_VOLUME -> result.success(volumeSettingsHandler.getAlarmVolume())
        METHOD_GET_MEDIA_VOLUME -> result.success(volumeSettingsHandler.getMediaVolume())
        METHOD_SET_ALARM_VOLUME -> volumeSettingsHandler.setAlarmVolumeHandler(call,result)
        METHOD_SET_MEDIA_VOLUME -> volumeSettingsHandler.setMediaVolumeHandler(call,result)
        METHOD_GET_ALARM_MAX_VOLUME -> result.success(volumeSettingsHandler.getAlarmMaxVolume())
        METHOD_GET_MEDIA_MAX_VOLUME -> result.success(volumeSettingsHandler.getMediaMaxVolume())
        else -> result.notImplemented()
      }
    }
  }

  @RequiresApi(Build.VERSION_CODES.M)
  private fun openAndroidPermissionsMenu() {
    activity?.let {
      val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      intent.data = Uri.parse("package:" + it.packageName)
      startActivity(context, intent, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // ActivityAware
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }

  companion object{

    const val METHOD_GET_BRIGHTNESS = "getBrightness"
    const val METHOD_SET_BRIGHTNESS = "setBrightness"
    const val METHOD_GET_SOUND_EFFECTS = "getSoundEffectsEnabled"
    const val METHOD_SET_SOUND_EFFECTS = "setSoundEffectsEnabled"
    const val METHOD_GET_ALARM_VOLUME = "getAlarmVolume"
    const val METHOD_GET_MEDIA_VOLUME = "getMediaVolume"
    const val METHOD_SET_ALARM_VOLUME = "setAlarmVolume"
    const val METHOD_SET_MEDIA_VOLUME = "setMediaVolume"
    const val METHOD_GET_ALARM_MAX_VOLUME = "getAlarmMaxVolume"
    const val METHOD_GET_MEDIA_MAX_VOLUME = "getMediaMaxVolume"

  }
}
