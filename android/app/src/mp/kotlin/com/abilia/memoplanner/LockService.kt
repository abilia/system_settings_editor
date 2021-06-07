package com.abilia.memoplanner

import android.app.Service
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.util.Log

class LockService : Service() {

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val devicePolicyManager =
                getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponentName = DeviceAdminReceiver.Companion.getComponentName(this)
        val isDeviceOwner = devicePolicyManager.isDeviceOwnerApp(packageName)
        val isLocked = devicePolicyManager.isLockTaskPermitted(packageName)

        if (isDeviceOwner) {

            if (!isLocked) {

                devicePolicyManager.setLockTaskPackages(
                        adminComponentName,
                        com.abilia.memoplanner.DeviceAdminReceiver.allowedApps(packageName))
            } else {

                devicePolicyManager.setLockTaskPackages(adminComponentName, arrayOf<String>())
            }
        } else Log.i("flutter", "not device owner")

        startMain()
        stopSelf()

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    private fun startMain() {
        val i = Intent(this, MainActivity::class.java)
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(i)
    }
}
