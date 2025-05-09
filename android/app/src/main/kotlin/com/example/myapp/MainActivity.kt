package com.example.myapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.hardware.usb.UsbManager
import android.hardware.usb.UsbDevice
import android.content.Context
import android.content.BroadcastReceiver
import android.content.Intent
import android.content.IntentFilter

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.myapp/usb"
    private lateinit var usbManager: UsbManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize the USB Manager
        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        // Notify USB status on app startup
        notifyUsbStatus(isSmartCardReaderConnected())
    }

    // Override configureFlutterEngine with correct signature
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel to communicate with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbStatus" -> {
                    val usbDeviceConnected = isSmartCardReaderConnected()
                    result.success(usbDeviceConnected)
                }
                else -> result.notImplemented()
            }
        }

        // Register BroadcastReceiver to listen for USB events
        val filter = IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED)
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        registerReceiver(usbReceiver, filter)
    }

    // USB detection logic
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (UsbManager.ACTION_USB_DEVICE_ATTACHED == intent?.action) {
                // USB connected, notify Flutter
                notifyUsbStatus(isSmartCardReaderConnected())
            } else if (UsbManager.ACTION_USB_DEVICE_DETACHED == intent?.action) {
                // USB disconnected, notify Flutter
                notifyUsbStatus(false)
            }
        }
    }

    // Notify Flutter about USB connection status
    private fun notifyUsbStatus(isConnected: Boolean) {
        val method = if (isConnected) "onUsbConnected" else "onUsbDisconnected"
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod(method, null)
        }
    }

    // Check if the specific USB device (smart card reader) is connected
    private fun isSmartCardReaderConnected(): Boolean {
        val deviceList = usbManager.deviceList
        for (device in deviceList.values) {
            if (isSmartCardReader(device)) {
                return true
            }
        }
        return false
    }

    // Identify the specific USB device by vendor and product ID
    private fun isSmartCardReader(device: UsbDevice): Boolean {
        val vendorId = 10381
        val productId = 64
        return device.vendorId == vendorId && device.productId == productId
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(usbReceiver)
    }
}
