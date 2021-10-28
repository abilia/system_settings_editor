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
  private lateinit var activity : Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "system_settings_editor")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity;
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getBrightness") {
      if (Settings.System.canWrite(context)) {
        result.success(getBrightness())
      } else {
        openAndroidPermissionsMenu()
        result.success(getBrightness())
      }
    } else if (call.method == "setBrightness") {
      if (Settings.System.canWrite(context)) {
        val brightness: Double = call.argument("brightness")!!
        setBrightness(brightness)
        result.success(true)
      } else {
        openAndroidPermissionsMenu()
        val brightness: Double = call.argument("brightness")!!
        setBrightness(brightness)
        result.success(true)
      }
    }
  }

  @RequiresApi(Build.VERSION_CODES.M)
  private fun openAndroidPermissionsMenu() {
    val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.data = Uri.parse("package:" + activity.packageName)
    startActivity(context, intent, null)
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

  private fun setBrightness(brightness: Double) {
    val lp = activity.window.attributes
    lp.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
    activity.window.attributes = lp
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

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }
}
