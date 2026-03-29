package dev.fluttercommunity.device_security_kit

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.MessageDigest
import java.io.File
import android.os.Environment

/// DeviceSecurityKitPlugin - Native implementation for device security checks on Android
class DeviceSecurityKitPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_security_kit")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkRoot" -> {
                val isRooted = checkRootAccess()
                result.success(isRooted)
            }
            "checkEmulator" -> {
                val isEmulator = checkIsEmulator()
                result.success(isEmulator)
            }
            "checkDebugger" -> {
                val isDebuggable = checkIsDebuggable()
                result.success(isDebuggable)
            }
            "checkProxy" -> {
                val hasProxy = checkProxySettings()
                result.success(hasProxy)
            }
            "checkVPN" -> {
                val hasVPN = checkVPNConnection()
                result.success(hasVPN)
            }
            "getSecurityInfo" -> {
                val securityInfo = getSecurityInfo()
                result.success(securityInfo)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /// Root detection - check for common root indicators
    private fun checkRootAccess(): Boolean {
        val rootPaths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )

        for (path in rootPaths) {
            if (File(path).exists()) {
                return true
            }
        }

        // Check for root management apps
        val rootApps = arrayOf(
            "com.noshufou.android.su",
            "com.thirdparty.superuser",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.topjohnwu.magisk"
        )

        try {
            val packageManager = context.packageManager
            for (app in rootApps) {
                try {
                    packageManager.getPackageInfo(app, 0)
                    return true
                } catch (e: Exception) {
                    // Package not found, continue
                }
            }
        } catch (e: Exception) {
            // Error accessing package manager
        }

        return false
    }

    /// Emulator detection
    private fun checkIsEmulator(): Boolean {
        val emulatorIndicators = arrayOf(
            "generic",
            "unknown",
            "goldfish",
            "vbox",
            "nox",
            "genymotion",
            "bluestacks",
            "andy",
            "android sdk built for x86"
        )

        val brand = android.os.Build.BRAND.lowercase()
        val model = android.os.Build.MODEL.lowercase()
        val product = android.os.Build.PRODUCT.lowercase()
        val hardware = android.os.Build.HARDWARE.lowercase()

        for (indicator in emulatorIndicators) {
            if (brand.contains(indicator) || 
                model.contains(indicator) || 
                product.contains(indicator) || 
                hardware.contains(indicator)) {
                return true
            }
        }

        return false
    }

    /// Debugger detection
    private fun checkIsDebuggable(): Boolean {
        return (context.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    /// Proxy detection
    private fun checkProxySettings(): Boolean {
        return android.net.Proxy.getDefaultHost() != null || 
               android.net.Proxy.getDefaultPort() > 0
    }

    /// VPN detection - check for active VPN interfaces
    private fun checkVPNConnection(): Boolean {
        try {
            val networkInterfaces = java.net.NetworkInterface.getNetworkInterfaces()
            for (networkInterface in networkInterfaces) {
                val interfaceName = networkInterface.name.lowercase()
                if (interfaceName.contains("tun") || interfaceName.contains("ppp")) {
                    return true
                }
            }
            return false
        } catch (e: Exception) {
            return false
        }
    }

    /// Get comprehensive security information
    private fun getSecurityInfo(): Map<String, Any> {
        val isRooted = checkRootAccess()
        val isEmulator = checkIsEmulator()
        val isDebuggable = checkIsDebuggable()
        val hasProxy = checkProxySettings()
        val hasVPN = checkVPNConnection()
        
        // Calculate security score (0-100)
        var securityScore = 100
        if (isRooted) securityScore -= 40
        if (isEmulator) securityScore -= 30
        if (isDebuggable) securityScore -= 20
        if (hasProxy) securityScore -= 5
        if (hasVPN) securityScore -= 10
        
        // Ensure score doesn't go below 0
        securityScore = maxOf(0, securityScore)

        return mapOf(
            "isSecure" to !isRooted && !isEmulator,
            "securityScore" to securityScore,
            "isRooted" to isRooted,
            "isEmulator" to isEmulator,
            "isDebuggable" to isDebuggable,
            "hasProxy" to hasProxy,
            "hasVPN" to hasVPN,
            "riskLevel" to when {
                isRooted -> 4
                isEmulator -> 3
                isDebuggable -> 2
                hasVPN || hasProxy -> 1
                else -> 0
            }
        )
    }
}