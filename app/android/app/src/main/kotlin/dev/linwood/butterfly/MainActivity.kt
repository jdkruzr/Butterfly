package dev.linwood.butterfly

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import java.io.IOException
import java.io.InputStream

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

// Onyx SDK imports - temporarily commented out for build testing
// import com.onyx.android.sdk.api.device.EpdController
// import com.onyx.android.sdk.api.device.EpdDevice
// import com.onyx.android.sdk.pen.TouchHelper


class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "linwood.dev/butterfly"
        private const val TAG = "ButterflyMainActivity"
    }
    
    private var intentType: String? = null
    private var intentData: ByteArray? = null
    
    // Onyx SDK related properties
    private var isOnyxDevice = false
    private var onyxInitialized = false

    @Override
    override fun onCreate(@Nullable savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle file intents
        handleFileIntent(intent)
        
        // Initialize Onyx SDK if available
        initializeOnyxSdk()
    }
    
    private fun handleFileIntent(intent: Intent) {
        val action = intent.action
        val type = intent.type

        if ((Intent.ACTION_VIEW == action || Intent.ACTION_EDIT == action) && type != null) {
            intentType = type
            val uri = intent.data
            if (uri != null) {
                try {
                    val inputStream: InputStream? = contentResolver.openInputStream(uri)
                    inputStream?.let {
                        intentData = it.readBytes()
                        it.close()
                    }
                } catch (e: IOException) {
                    Log.e(TAG, "Error reading intent data", e)
                    intentData = null
                    intentType = null
                }
            }
        }
    }
    
    private fun initializeOnyxSdk() {
        try {
            // Temporarily disabled for build testing - will detect using reflection
            // Check if we're running on an Onyx device
            // isOnyxDevice = EpdDevice.isEpdDevice()
            
            // For testing, detect Onyx devices by checking model, brand, and manufacturer
            val deviceModel = android.os.Build.MODEL
            val deviceBrand = android.os.Build.BRAND
            val deviceManufacturer = android.os.Build.MANUFACTURER
            
            isOnyxDevice = deviceModel.contains("ONYX", ignoreCase = true) || 
                          deviceModel.contains("Boox", ignoreCase = true) ||
                          deviceModel.contains("Tab", ignoreCase = true) ||
                          deviceBrand.contains("Onyx", ignoreCase = true) ||
                          deviceManufacturer.contains("Onyx", ignoreCase = true)
            
            if (isOnyxDevice) {
                Log.i(TAG, "Onyx device detected (model: $deviceModel, brand: $deviceBrand, manufacturer: $deviceManufacturer), SDK would be initialized here")
                
                // Initialize EPD controller - commented out for build testing
                // EpdController.invalidateGlobal()
                
                // Initialize TouchHelper for pen optimization - commented out for build testing
                // touchHelper = TouchHelper.create(this) { view ->
                //     Log.d(TAG, "Touch helper callback triggered")
                // }
                
                onyxInitialized = true
                Log.i(TAG, "Onyx integration initialized successfully (test mode)")
            } else {
                Log.i(TAG, "Not an Onyx device (model: $deviceModel, brand: $deviceBrand, manufacturer: $deviceManufacturer), skipping SDK initialization")
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to initialize Onyx SDK (graceful fallback)", e)
            isOnyxDevice = false
            onyxInitialized = false
        }
    }
    
    private fun setEInkRefreshMode(mode: String): Boolean {
        if (!onyxInitialized) return false
        
        try {
            // Temporarily commented out for build testing
            when (mode.lowercase()) {
                "du" -> {
                    // EpdController.setEpdMode(EpdController.EPD_FULL_GLD16, EpdController.EPD_NORMAL, false)
                    Log.d(TAG, "Would set EPD mode to DU")
                    return true
                }
                "a2" -> {
                    // EpdController.setEpdMode(EpdController.EPD_A2, EpdController.EPD_NORMAL, false)
                    Log.d(TAG, "Would set EPD mode to A2")
                    return true
                }
                "full" -> {
                    // EpdController.setEpdMode(EpdController.EPD_FULL, EpdController.EPD_NORMAL, false)
                    Log.d(TAG, "Would set EPD mode to FULL")
                    return true
                }
                else -> return false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error setting EPD mode", e)
            return false
        }
    }
    
    private fun optimizeForDrawing(enabled: Boolean): Boolean {
        if (!onyxInitialized) return false
        
        try {
            if (enabled) {
                // Use A2 mode for fast drawing - commented out for build testing
                // EpdController.setEpdMode(EpdController.EPD_A2, EpdController.EPD_NORMAL, false)
                // Enable pen optimization - commented out for build testing
                Log.d(TAG, "Drawing optimization enabled (test mode)")
            } else {
                // Return to normal mode - commented out for build testing
                // EpdController.setEpdMode(EpdController.EPD_FULL_GLD16, EpdController.EPD_NORMAL, false)
                Log.d(TAG, "Drawing optimization disabled (test mode)")
            }
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error setting drawing optimization", e)
            return false
        }
    }

    @Override
    override fun configureFlutterEngine(@NonNull flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getIntentType" -> {
                    result.success(intentType)
                }
                "getIntentData" -> {
                    result.success(intentData)
                    intentType = null
                    intentData = null
                }
                // Onyx SDK methods
                "isOnyxDevice" -> {
                    result.success(isOnyxDevice)
                }
                "isOnyxInitialized" -> {
                    result.success(onyxInitialized)
                }
                "setEInkRefreshMode" -> {
                    val mode = call.argument<String>("mode") ?: "full"
                    result.success(setEInkRefreshMode(mode))
                }
                "optimizeForDrawing" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(optimizeForDrawing(enabled))
                }
                "refreshScreen" -> {
                    if (onyxInitialized) {
                        try {
                            // EpdController.invalidateGlobal() - commented out for build testing
                            Log.d(TAG, "Would refresh screen now (test mode)")
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error refreshing screen", e)
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    @Override
    override fun onDestroy() {
        super.onDestroy()
        
        // Clean up - commented out for build testing
        try {
            Log.d(TAG, "Cleaning up Onyx integration")
        } catch (e: Exception) {
            Log.e(TAG, "Error cleaning up Onyx integration", e)
        }
    }
}
