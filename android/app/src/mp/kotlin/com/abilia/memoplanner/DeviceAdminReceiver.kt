package com.abilia.memoplanner

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.UserManager
import android.util.Log

class DeviceAdminReceiver : android.app.admin.DeviceAdminReceiver() {
    companion object {
        fun getComponentName(context: Context): ComponentName {
            return ComponentName(context.getApplicationContext(), DeviceAdminReceiver::class.java)
        }

        fun allowedApps(pkg: String): Array<String> {
            return arrayOf("com.android.settings", pkg)
        }

        val TAG = "MEMOPLANNER"
    }

    val userRestrictions =
            arrayOf<String>(
                    // UserManager.DISALLOW_FACTORY_RESET,
                    // UserManager.DISALLOW_SAFE_BOOT,
                    // UserManager.DISALLOW_MOUNT_PHYSICAL_MEDIA,
                    // UserManager.DISALLOW_ADD_USER,
                    // UserManager.DISALLOW_INSTALL_APPS,
                    // UserManager.DISALLOW_OUTGOING_CALLS,
                    // UserManager.DISALLOW_SMS
                    )

    override fun onLockTaskModeEntering(context: Context, intent: Intent, pkg: String) {
        super.onLockTaskModeEntering(context, intent, pkg)
        Log.e(TAG, "onLockTaskModeEntering " + pkg)
        if (pkg == context.packageName) {
            try {
                addPersistentPreferredActivity(context)
                addUserRestriction(context)
                removeSystemUIFeatures(context)
                setKeyguardDisabled(context, true)
                setPermissions(context)
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            }
        }
    }

    override fun onLockTaskModeExiting(context: Context, intent: Intent) {
        super.onLockTaskModeExiting(context, intent)
        clearPackagePersistentPreferredActivities(context)
        clearUserRestriction(context)
        setKeyguardDisabled(context, false)
    }

    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        val bundle: Bundle = intent.getExtras()
        if (bundle != null) {
            bundle.keySet().forEach { Log.e(TAG, it + " : " + (bundle.get(it) ?: "NULL")) }
        } else {
            Log.e(TAG, "No extras")
        }
        getManager(context).setLockTaskPackages(getWho(context), allowedApps(context.packageName))
        startMain(context)
    }

    private fun startMain(context: Context) {
        val i = Intent(context, MainActivity::class.java)
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(i)
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
                .setLockTaskFeatures(
                        getWho(context),
                        DevicePolicyManager.LOCK_TASK_FEATURE_GLOBAL_ACTIONS or
                                DevicePolicyManager.LOCK_TASK_FEATURE_HOME or
                                DevicePolicyManager.LOCK_TASK_FEATURE_NOTIFICATIONS)
    }

    private fun setKeyguardDisabled(context: Context, disabled: Boolean) {
        getManager(context).setKeyguardDisabled(getWho(context), disabled)
    }

    private fun setPermissions(context: Context) {
        context.packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS)
                .requestedPermissions
                .forEach {
                    if (!getManager(context)
                            .setPermissionGrantState(
                                    getWho(context),
                                    context.packageName,
                                    it,
                                    DevicePolicyManager.PERMISSION_GRANT_STATE_GRANTED)) {
                        Log.e(TAG, "Failed to auto grant permission to self: $it")
                    }
                }
    }
}
