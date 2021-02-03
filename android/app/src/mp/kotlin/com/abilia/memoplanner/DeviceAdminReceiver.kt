package com.abilia.memoplannergo

import android.content.ComponentName
import android.content.Context

class DeviceAdminReceiver : android.app.admin.DeviceAdminReceiver() {
    val TAG = "DeviceAdminReceiver"
    companion object {
        fun getComponentName(context : Context): ComponentName {
            return ComponentName(context.getApplicationContext(), DeviceAdminReceiver::class.java);
        }
    }
}