package com.rajada1_docscan_kit.doc_scan_kit;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning;
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions;
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Objects;


public class DocumentScanner implements MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    private static final String START = "scanKit#startDocumentScanner";
    private static final String CLOSE = "scanKit#closeDocumentScanner";
    private static final String TAG = "DocumentScanner";
    private final Map<String, GmsDocumentScanner> instance = new HashMap<>();
    private final ActivityPluginBinding binding;
    private MethodChannel.Result pendingResult = null;
    private Map<String, Object> extractedOptions;
    final private int START_DOCUMENT_ACTIVITY = 0x362738;

    public DocumentScanner(ActivityPluginBinding binding){
        this.binding = binding;
        binding.addActivityResultListener(this);

    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;

        switch (method){
            case START:
                extractedOptions = call.argument("androidOptions");
                startScanner(call, result);
                break;
            case CLOSE:
                closeScanner(call);
                break;
            default:
                result.notImplemented();
                break;
        }

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if(requestCode == START_DOCUMENT_ACTIVITY){
            if(resultCode == Activity.RESULT_OK){
                GmsDocumentScanningResult result = GmsDocumentScanningResult.fromActivityResultIntent(data);
                if(result != null){
                    handleScannerResult(result);
                }
            }else if(resultCode == Activity.RESULT_CANCELED){
                pendingResult.error(TAG, "Operation canceled", null);
            }else{
                pendingResult.error(TAG, "Unknown Error", null);
            }
            return true;
        }
        return false;
    }


    private void startScanner(MethodCall call, final MethodChannel.Result result){
        String id = call.argument("id");
        GmsDocumentScanner scanner = instance.get(id);
        pendingResult = result;

        if (scanner == null) {
            Map<String, Object> options = call.argument("androidOptions");
            if(options == null){
                result.error(TAG, "Invalid options", null);
                return;
            }
            GmsDocumentScannerOptions scannerOptions =makeOptions(options);
            scanner = GmsDocumentScanning.getClient(scannerOptions);
            instance.put(id, scanner);

        }

        Activity activity = binding.getActivity();
        scanner.getStartScanIntent(activity).addOnSuccessListener(new OnSuccessListener<IntentSender>() {
            @Override
            public void onSuccess(IntentSender intentSender) {
                try {
                    activity.startIntentSenderForResult(intentSender, START_DOCUMENT_ACTIVITY, null, 0, 0, 0);
                } catch (IntentSender.SendIntentException e) {
                    result.error(TAG, "Failed Start document Scanner", e);
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                result.error(TAG, "Failed to Start document Scanner", e);
            }
        });

    }


    private GmsDocumentScannerOptions makeOptions(Map<String, Object> options){
        boolean isGalleryImport = Boolean.TRUE.equals(options.get("isGalleryImport"));
        Object npage = options.get("pageLimit");
        int pageLimit = (npage instanceof  Number) ? ((Number) npage).intValue() : 1;
        int scannerMode;
        switch ((String) Objects.requireNonNull(options.get("scannerMode"))){
            case "base":
                scannerMode = GmsDocumentScannerOptions.SCANNER_MODE_BASE;
                break;
            case "filter":
                scannerMode = GmsDocumentScannerOptions.SCANNER_MODE_BASE_WITH_FILTER;
                break;
            default:
            case "full":
                scannerMode = GmsDocumentScannerOptions.SCANNER_MODE_FULL;
                break;

        }
        GmsDocumentScannerOptions.Builder builder = new GmsDocumentScannerOptions.Builder()
                .setGalleryImportAllowed(isGalleryImport)
                .setPageLimit(pageLimit)
                .setResultFormats(GmsDocumentScannerOptions.RESULT_FORMAT_JPEG)
                .setScannerMode(scannerMode);
    return builder.build();

    }

    private void closeScanner(MethodCall call ){
        String id = call.argument("id");
        GmsDocumentScanner scanner = instance.get(id);
        if(scanner == null) return ;
        instance.remove(id);
    }

    private void handleScannerResult(GmsDocumentScanningResult result){
        List<Map<String, Object>> resultMap = new ArrayList<>();

        //Check if the result has a list of pages
        List<GmsDocumentScanningResult.Page> pages = result.getPages();
        if(pages != null && !pages.isEmpty()){
            for (GmsDocumentScanningResult.Page page : pages){
                Map<String, Object> imageData = new HashMap<>();
             Uri imageUri = page.getImageUri();
                Context context = binding.getActivity().getApplicationContext();
                byte[]  imageBytes = getBytesFromUri(context, imageUri);
                imageData.put("bytes", imageBytes);
                boolean saveImage = Boolean.TRUE.equals(extractedOptions.get("saveImage"));
                if(!saveImage ){

                    File file = new File(Objects.requireNonNull(imageUri.getPath()));
                    file.deleteOnExit();
                }else{
                    imageData.put("path", imageUri.getPath());
                }
                resultMap.add( imageData);
            }
        }else{
            resultMap.add( null);
        }
        pendingResult.success(resultMap);
        pendingResult = null;
    }


    private byte[] getBytesFromUri(Context context, Uri uri) {
        try (InputStream inputStream = context.getContentResolver().openInputStream(uri);
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while (true) {
                assert inputStream != null;
                if ((bytesRead = inputStream.read(buffer)) == -1) break;
                outputStream.write(buffer, 0, bytesRead);
            }
            return outputStream.toByteArray();
        } catch (IOException e) {

            e.printStackTrace();
            return null;
        }
    }

}
