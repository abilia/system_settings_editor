package com.abilia.seagull

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService

class Application : FlutterApplication(), PluginRegistrantCallback {
    @Override
    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
    }

    @Override
    override fun registerWith(registry: PluginRegistry?) {
        if (registry != null) {
            // Need to register every plugin that is going to be used in Firebase background callback in this awkward way
            // because Flutter-Firebase do not support new plugin registration with flutters new Android plugins APIs
            io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
            io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"))
            com.tekartik.sqflite.SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"))
            com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
            io.flutter.plugins.pathprovider.PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"))
            com.whelksoft.flutter_native_timezone.FlutterNativeTimezonePlugin.registerWith(registry.registrarFor("com.whelksoft.flutter_native_timezone.FlutterNativeTimezonePlugin"))
        }
    }
}
