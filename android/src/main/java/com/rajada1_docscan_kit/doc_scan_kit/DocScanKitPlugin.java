package com.rajada1_docscan_kit.doc_scan_kit;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

public class DocScanKitPlugin implements FlutterPlugin, ActivityAware {
    private static final String channelName = "doc_scan_kit";
    private MethodChannel channel;
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), channelName);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        channel.setMethodCallHandler(new DocumentScanner(binding));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        channel.setMethodCallHandler(new DocumentScanner(binding));
    }

    @Override
    public void onDetachedFromActivity() {

    }
}
