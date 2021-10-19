package com.abilia.memoplanner

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.res.Resources
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.util.Log

import android.provider.Settings.SettingNotFoundException
import androidx.annotation.RequiresApi

open class MainActivity : FlutterActivity() {
    private val CHANNEL = "abilia.com/screen"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        screenOn()
    }

    private fun screenOn() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setTurnScreenOn(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getBrightness") {
                if (Settings.System.canWrite(applicationContext)) {
                    Log.v("TAG", "CAN WRITE")
                    val b = getBrightness()
                    result.success(getBrightness())
                } else {
                    Log.v("TAG", "CAN NOT WRITE")
                    openAndroidPermissionsMenu()
                    result.success(getBrightness())
                }
            } else if (call.method == "setBrightness") {
                if (Settings.System.canWrite(applicationContext)) {
                    Log.v("TAG", "CAN SET")
                    val brightness: Double = call.argument("brightness")!!
                    setBrightness(brightness)
                    result.success(null)
                } else {
                    Log.v("TAG", "CAN not SET but will soon")
                    openAndroidPermissionsMenu()
                    val brightness: Double = call.argument("brightness")!!
                    setBrightness(brightness)
                    result.success(null)
                }
            }
        }
    }

    private fun openAndroidPermissionsMenu() {
        val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
        intent.data = Uri.parse("package:" + activity.packageName)
        startActivity(intent)
    }

    private fun getBrightness(): Double {
        val cResolver: ContentResolver = contentResolver
        try {
            // To handle the auto
            Settings.System.putInt(cResolver,
                    Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL)
            //Get the current system brightness
            val brightness = Settings.System.getInt(cResolver, Settings.System.SCREEN_BRIGHTNESS)
            Log.v("TAG", "Brightness is: $brightness")
            val max = getBrightnessMax()
            return brightness.toDouble() / max
        } catch (e: SettingNotFoundException) {
            //Throw an error case it couldn't be retrieved
            Log.e("Error", "Cannot access system brightness")
            e.printStackTrace()
        }
        return 1.0
    }

    private fun setBrightness(brightness: Double) {
        val lp = window.attributes
        lp.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        window.attributes = lp
        val cResolver: ContentResolver = applicationContext.contentResolver
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
}
