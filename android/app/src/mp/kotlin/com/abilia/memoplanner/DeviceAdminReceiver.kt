package com.abilia.memoplanner

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.UserManager
import android.provider.Settings

class DeviceAdminReceiver : android.app.admin.DeviceAdminReceiver() {
    companion object {
        fun getComponentName(context: Context): ComponentName {
            return ComponentName(context.getApplicationContext(), DeviceAdminReceiver::class.java)
        }
    }

    val userRestrictions =
            arrayOf(
                    UserManager.DISALLOW_FACTORY_RESET,
                    UserManager.DISALLOW_SAFE_BOOT,
                    UserManager.DISALLOW_MOUNT_PHYSICAL_MEDIA,
                    UserManager.DISALLOW_ADD_USER,
                    UserManager.DISALLOW_INSTALL_APPS,
                    UserManager.DISALLOW_OUTGOING_CALLS,
                    UserManager.DISALLOW_SMS)

    override fun onLockTaskModeEntering(context: Context, intent: Intent, pkg: String) {
        super.onLockTaskModeEntering(context, intent, pkg)
        if (pkg == context.packageName) {
            addPersistentPreferredActivity(context)
            addUserRestriction(context)
            removeSystemUIFeatures(context)
            enableStayOnWhilePluggedIn(context)
            setKeyguardDisabled(context, true)
        }
    }

    override fun onLockTaskModeExiting(context: Context, intent: Intent) {
        super.onLockTaskModeExiting(context, intent)
        clearPackagePersistentPreferredActivities(context)
        clearUserRestriction(context)
        disableStayOnWhilePluggedIn(context)
        setKeyguardDisabled(context, false)
    }

    private fun addPersistentPreferredActivity(context: Context) {
        val filter = IntentFilter(Intent.ACTION_MAIN)
        filter.addCategory(Intent.CATEGORY_HOME)
        filter.addCategory(Intent.CATEGORY_DEFAULT)

        val activity = ComponentName(context, MainActivity::class.java)
        getManager(context).addPersistentPreferredActivity(getWho(context), filter, activity)
    }

    private fun clearPackagePersistentPreferredActivities(context: Context) {
        getManager(context)
                .clearPackagePersistentPreferredActivities(getWho(context), context.packageName)
    }

    private fun addUserRestriction(context: Context) {
        userRestrictions.forEach { getManager(context).addUserRestriction(getWho(context), it) }
    }

    private fun clearUserRestriction(context: Context) {
        userRestrictions.forEach { getManager(context).clearUserRestriction(getWho(context), it) }
    }

    private fun removeSystemUIFeatures(context: Context) {
        getManager(context)
                .setLockTaskFeatures(getWho(context), DevicePolicyManager.LOCK_TASK_FEATURE_NONE)
    }

    private fun enableStayOnWhilePluggedIn(context: Context) {
        getManager(context)
                .setGlobalSetting(
                        getWho(context),
                        Settings.Global.STAY_ON_WHILE_PLUGGED_IN,
                        Integer.toString(
                                BatteryManager.BATTERY_PLUGGED_AC or
                                        BatteryManager.BATTERY_PLUGGED_USB or
                                        BatteryManager.BATTERY_PLUGGED_WIRELESS))
    }

    private fun disableStayOnWhilePluggedIn(context: Context) {
        getManager(context)
                .setGlobalSetting(getWho(context), Settings.Global.STAY_ON_WHILE_PLUGGED_IN, "0")
    }
    private fun setKeyguardDisabled(context: Context, disabled: Boolean) {
        getManager(context).setKeyguardDisabled(getWho(context), disabled)
    }
}
