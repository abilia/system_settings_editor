package com.abilia.system_settings_editor

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SystemSettingsEditorPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private lateinit var systemSettingsHandler: SystemSettingsHandler
  private lateinit var volumeSettingsHandler: VolumeSettingsHandler

  override fun onAttachedToEngine(
      @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
  ) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "system_settings_editor")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    systemSettingsHandler = SystemSettingsHandler(context)
    volumeSettingsHandler = VolumeSettingsHandler(context)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "canWriteSettings" -> result.success(Settings.System.canWrite(context))
      "getSoundEffectsEnabled" -> result.success(systemSettingsHandler.getSoundEffectsEnabled())
      "getAlarmVolume" -> result.success(volumeSettingsHandler.getAlarmVolume())
      "getAlarmMaxVolume" -> result.success(volumeSettingsHandler.getAlarmMaxVolume())
      "getMediaVolume" -> result.success(volumeSettingsHandler.getMediaVolume())
      "getMediaMaxVolume" -> result.success(volumeSettingsHandler.getMediaMaxVolume())
      "getScreenOffTimeout" -> result.success(systemSettingsHandler.getScreenOffTimeout())
      "getHasBattery" -> result.success(systemSettingsHandler.getHasBattery())
      "setAlarmVolume" -> volumeSettingsHandler.setAlarmVolumeHandler(call, result)
      "setMediaVolume" -> volumeSettingsHandler.setMediaVolumeHandler(call, result)
      else ->
          if (!Settings.System.canWrite(context)) {
            openAndroidPermissionsMenu()
            result.error("ACCESS", "Cannot write to system settings. Permission needed.", null)
          } else {
            when (call.method) {
              "getBrightness" -> result.success(systemSettingsHandler.getBrightness())
              "setBrightness" -> systemSettingsHandler.setBrightnessHandler(activity, call, result)
              "setSoundEffectsEnabled" -> systemSettingsHandler.setSoundEffectsHandler(call, result)
              "setHapticFeedbackEnabled" -> systemSettingsHandler.setHapticFeedbackHandler(call, result)
              "setScreenOffTimeout" ->
                  systemSettingsHandler.setScreenOffTimeoutHandler(call, result)
              else -> result.notImplemented()
            }
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
