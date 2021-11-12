package com.abilia.system_settings_editor

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.res.Resources
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SystemSettingsHandler(private val context: Context) {

  internal fun getBrightness(): Double {
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

  internal fun setBrightnessHandler(activity: Activity?, call: MethodCall, result: MethodChannel.Result) {
    val brightness: Double? = call.argument("brightness")
    brightness?.let {
      setBrightness(activity, it)
      result.success(true)
    } ?: run {
      result.error("ARGUMENT", "No argument brightness of type double provided", null)
    }
  }

  internal fun getSoundEffectsEnabled(): Boolean {
    val cResolver: ContentResolver = context.contentResolver
    try {
      val enabled = Settings.System.getInt(cResolver, Settings.System.SOUND_EFFECTS_ENABLED)
      return enabled == 1
    } catch (e: Settings.SettingNotFoundException) {
      Log.e("Error", "Cannot access sound settings")
    }
    return true
  }

  internal fun setSoundEffectsHandler(call: MethodCall, result: MethodChannel.Result) {
    val enabled: Boolean? = call.argument("soundEffectsEnabled")
    enabled?.let {
      setSoundEffectsEnabled(it)
      result.success(true)
    } ?: run {
      result.error("ARGUMENT", "No argument sound_effects_enabled of type int provided", null)
    }
  }

  private fun setBrightness(activity: Activity?, brightness: Double) {
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

  private fun setSoundEffectsEnabled(on: Boolean) {
    val cResolver: ContentResolver = context.contentResolver
    Settings.System.putInt(
      cResolver, Settings.System.SOUND_EFFECTS_ENABLED,
      if (on) 1 else 0
    )
  }
}