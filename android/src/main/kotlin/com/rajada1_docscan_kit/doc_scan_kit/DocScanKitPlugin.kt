//package com.rajada1_docscan_kit.doc_scan_kit
//import io.flutter.embedding.engine.plugins.FlutterPlugin
//import io.flutter.embedding.engine.plugins.activity.ActivityAware
//import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
//import io.flutter.plugin.common.MethodChannel
//
///** DocScanKitPlugin */
//class DocScanKitPlugin: FlutterPlugin, ActivityAware {
//  private lateinit var handler: DocumentScanKit
//  private lateinit var channel : MethodChannel
//  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    handler = DocumentScanKit()
//    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "doc_scan_kit")
//    channel.setMethodCallHandler(handler)
//  }
//  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//    channel.setMethodCallHandler(null)
//  }
//
//  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//    handler.setActivityPluginBinding(binding)
//  }
//
//  override fun onDetachedFromActivityForConfigChanges() {}
//
//  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
//
//  override fun onDetachedFromActivity() {}
//}
