package com.rajada1_docscan_kit.doc_scan_kit;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.common.InputImage;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class DocScanBarcodeScanner {
    
    private final com.google.mlkit.vision.barcode.BarcodeScanner scanner;
    private final Executor executor;
    
    public interface BarcodeScannerCallback {
        void onSuccess(String barcodeContent);
        void onFailure(Exception e);
    }
    
    public DocScanBarcodeScanner() {
        scanner = BarcodeScanning.getClient();
        executor = Executors.newSingleThreadExecutor();
    }
    
    public void scanBarcodes(InputImage image, final BarcodeScannerCallback callback) {
        Task<List<Barcode>> result = scanner.process(image)
            .addOnSuccessListener(executor, new OnSuccessListener<List<Barcode>>() {
                @Override
                public void onSuccess(List<Barcode> barcodes) {
                    if (barcodes.isEmpty()) {
                        callback.onSuccess(""); // Nenhum código de barras encontrado
                        return;
                    }
                    
                    StringBuilder resultContent = new StringBuilder();
                    for (Barcode barcode : barcodes) {
                        String rawValue = barcode.getRawValue();
                        if (rawValue != null) {
                            if (resultContent.length() > 0) {
                                resultContent.append(", ");
                            }
                            resultContent.append(rawValue);
                        }
                    }
                    
                    callback.onSuccess(resultContent.toString());
                }
            })
            .addOnFailureListener(executor, new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    callback.onFailure(e);
                }
            });
    }
    
    public void close() {
        scanner.close();
    }
}
