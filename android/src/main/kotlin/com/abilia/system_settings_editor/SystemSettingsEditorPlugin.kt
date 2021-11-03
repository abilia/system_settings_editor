package com.abilia.system_settings_editor

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class SystemSettingsEditorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private var activity : Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "system_settings_editor")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (!Settings.System.canWrite(context)) {
      openAndroidPermissionsMenu()
      result.error("ACCESS", "Cannot write to system settings. Permission needed.", null)
    } else {
      when (call.method) {
        "getBrightness" -> result.success(getBrightness())
        "setBrightness" -> setBrightnessHandler(call, result)
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

  private fun getBrightness(): Double {
    val cResolver: ContentResolver = context.contentResolver
    try {
      Settings.System.putInt(cResolver,
        Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL)
      val brightness = Settings.System.getInt(cResolver, Settings.System.SCREEN_BRIGHTNESS)
      val max = getBrightnessMax()
      return brightness.toDouble() / max
    } catch (e: Settings.SettingNotFoundException) {
      Log.e("Error", "Cannot access system brightness")
    }
    return 1.0
  }

  private fun setBrightnessHandler(call: MethodCall, result: Result) {
    val brightness: Double? = call.argument("brightness")
    brightness?.let {
      setBrightness(it)
      result.success(true)
    } ?: run {
      result.error("ARGUMENT", "No argument brightness of type double provided", null)
    }
  }

  private fun setBrightness(brightness: Double) {
    activity?.let {
      val lp = it.window.attributes
      lp.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
      it.window.attributes = lp
    }
    val cResolver: ContentResolver = context.contentResolver
    Settings.System.putInt(
      cResolver, Settings.System.SCREEN_BRIGHTNESS_MODE,
      Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
    )
    Settings.System.putInt(
      cResolver, Settings.System.SCREEN_BRIGHTNESS,
      (brightness * getBrightnessMax()).toInt()
    )
  }

  private fun getBrightnessMax(): Int {
    try {
      val system: Resources = Resources.getSystem()
      val resId: Int = system.getIdentifier("config_screenBrightnessSettingMaximum", "integer", "android")
      if (resId != 0) {
        return system.getInteger(resId)
      }
    } catch (ignore: Exception) {
      Log.e("Error", "Cannot access max brightness")
    }
    return 255
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
