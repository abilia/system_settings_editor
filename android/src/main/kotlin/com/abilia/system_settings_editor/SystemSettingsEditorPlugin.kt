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
        "getBrightness" -> result.success(systemSettingsHandler.getBrightness())
        "setBrightness" -> systemSettingsHandler.setBrightnessHandler(activity, call, result)
        "getSoundEffectsEnabled" -> result.success(systemSettingsHandler.getSoundEffectsEnabled())
        "setSoundEffectsEnabled" -> systemSettingsHandler.setSoundEffectsHandler(call, result)
        "getAlarmVolume" -> result.success(volumeSettingsHandler.getAlarmVolume())
        "getMediaVolume" -> result.success(volumeSettingsHandler.getMediaVolume())
        "setAlarmVolume" -> volumeSettingsHandler.setAlarmVolumeHandler(call, result)
        "setMediaVolume" -> volumeSettingsHandler.setMediaVolumeHandler(call, result)
        "getAlarmMaxVolume" -> result.success(volumeSettingsHandler.getAlarmMaxVolume())
        "getMediaMaxVolume" -> result.success(volumeSettingsHandler.getMediaMaxVolume())
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
}
