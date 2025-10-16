package com.rajada1_docscan_kit.doc_scan_kit

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class DocumentScanner(
    private val binding: ActivityPluginBinding
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "DocumentScanner"
        private const val START = "scanKit#startDocumentScanner"
        private const val CLOSE = "scanKit#closeDocumentScanner"
        private const val RECOGNIZE_TEXT = "scanKit#recognizeText"
        private const val SCAN_QR_CODE = "scanKit#scanQrCode"
        private const val START_DOCUMENT_ACTIVITY = 0x362738
    }

    private val instances = mutableMapOf<String, GmsDocumentScanner>()
    private val instancesBarCode = mutableMapOf<String, DocScanBarcodeScanner>()
    private val instancesTextRecognizer = mutableMapOf<String, TextRecognizer>()
    private var extractedOptions: Map<String, Any>? = null
    private var pendingResult: MethodChannel.Result? = null
    private val scope = CoroutineScope(Dispatchers.Main + Job())
    private var currentJob: Job? = null

    init {
        binding.addActivityResultListener { requestCode, resultCode, data ->
            if (requestCode == START_DOCUMENT_ACTIVITY) {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        val result = GmsDocumentScanningResult.fromActivityResultIntent(data)
                        if (result != null) {
                            scope.launch {
                                handleScannerResult(result)
                            }
                        }
                    }
                    Activity.RESULT_CANCELED -> {
                        pendingResult?.error(TAG, "Operation canceled", null)
                    }
                    else -> {
                        pendingResult?.error(TAG, "Unknown Error", null)
                    }
                }
                true
            } else {
                false
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        currentJob?.cancel()
        currentJob = scope.launch {
            try {
                when (call.method) {
                    START -> startScanner(call, result)
                    CLOSE -> closeScanner(call)
                    RECOGNIZE_TEXT -> startRecognizeText(call, result)
                    SCAN_QR_CODE -> startScanQrCode(call, result)
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in ${call.method}", e)
                result.error(TAG, "Error in ${call.method}: ${e.message}", null)
            }
        }
    }

    private suspend fun startScanner(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id") ?: run {
            result.error(TAG, "Missing id parameter", null)
            return
        }

        extractedOptions = call.argument("androidOptions") ?: run {
            result.error(TAG, "Missing androidOptions parameter", null)
            return
        }

        val scanner = instances.getOrPut(id) {
            val options = makeOptions(extractedOptions!!)
            GmsDocumentScanning.getClient(options)
        }

        pendingResult = result

        try {
            val intentSender = scanner.getStartScanIntent(binding.activity).await()
            binding.activity.startIntentSenderForResult(
                intentSender,
                START_DOCUMENT_ACTIVITY,
                null, 0, 0, 0
            )
        } catch (e: Exception) {
            result.error(TAG, "Failed to start document scanner: ${e.message}", null)
            pendingResult = null
        }
    }

    private fun makeOptions(options: Map<String, Any>): GmsDocumentScannerOptions {
        val isGalleryImport = options["isGalleryImport"] as? Boolean ?: true
        val pageLimit = (options["pageLimit"] as? Number)?.toInt() ?: 1
        val scannerMode = when (options["scannerMode"] as? String ?: "full") {
            "base" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE
            "filter" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE_WITH_FILTER
            else -> GmsDocumentScannerOptions.SCANNER_MODE_FULL
        }

        return GmsDocumentScannerOptions.Builder()
            .setGalleryImportAllowed(isGalleryImport)
            .setPageLimit(pageLimit)
            .setResultFormats(GmsDocumentScannerOptions.RESULT_FORMAT_JPEG)
            .setScannerMode(scannerMode)
            .build()
    }

    private fun closeScanner(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        
        instances.remove(id) // GmsDocumentScanner doesn't have a close method
        
        instancesTextRecognizer[id]?.let {
            it.closedTextRecognizer()
            instancesTextRecognizer.remove(id)
        }
        
        instancesBarCode[id]?.let {
            it.close()
            instancesBarCode.remove(id)
        }
    }

    private suspend fun handleScannerResult(result: GmsDocumentScanningResult) {
        val pages = result.pages ?: run {
            pendingResult?.success(listOf<Map<String, Any>>(emptyMap()))
            pendingResult = null
            return
        }

        val resultMap = pages.mapNotNull { page ->
            try {
                val imageUri = page.imageUri ?: return@mapNotNull null
                val context = binding.activity.applicationContext
                val imageBytes = getBytesFromUri(context, imageUri) ?: return@mapNotNull null

                val imageData = mutableMapOf<String, Any>("bytes" to imageBytes)

                val saveImage = extractedOptions?.get("saveImage") as? Boolean ?: true
                if (!saveImage) {
                    File(imageUri.path ?: "").deleteOnExit()
                } else {
                    imageData["path"] = imageUri.path ?: ""
                }

                imageData
            } catch (e: Exception) {
                Log.e(TAG, "Error processing page", e)
                null
            }
        }
        
        pendingResult?.success(resultMap)
        pendingResult = null
    }

    @Throws(IOException::class)
    private fun getBytesFromUri(context: Context, uri: Uri): ByteArray? {
        return context.contentResolver.openInputStream(uri)?.use { inputStream ->
            ByteArrayOutputStream().use { outputStream ->
                val buffer = ByteArray(4096)
                var bytesRead: Int
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                }
                outputStream.toByteArray()
            }
        }
    }

    private suspend fun startRecognizeText(call: MethodCall, result: MethodChannel.Result) {
        try {
            val id = call.argument<String>("id") ?: throw IllegalArgumentException("Missing id parameter")
            val imageBytes = call.argument<ByteArray>("imageBytes") ?: 
                throw IllegalArgumentException("Missing imageBytes parameter")

            val textRecognizer = instancesTextRecognizer.getOrPut(id) { TextRecognizer() }
            val inputImage = getInputImageByByteArray(imageBytes)
            val text = textRecognizer.handleDetection2(inputImage)
            
            result.success(text)
        } catch (e: Exception) {
            Log.e(TAG, "Error in text recognition", e)
            result.error(TAG, "Failed to recognize text: ${e.message}", null)
        }
    }

    private suspend fun startScanQrCode(call: MethodCall, result: MethodChannel.Result) {
        try {
            val id = call.argument<String>("id") ?: throw IllegalArgumentException("Missing id parameter")
            val imageBytes = call.argument<ByteArray>("imageBytes") ?:
                throw IllegalArgumentException("Missing imageBytes parameter")

            val barcodeScanner = instancesBarCode.getOrPut(id) { DocScanBarcodeScanner() }
            val inputImage = getInputImageByByteArray(imageBytes)

            val barcodeContent = barcodeScanner.scanBarcodesSuspend(inputImage)
            result.success(barcodeContent)
        } catch (e: Exception) {
            Log.e(TAG, "Error in QR code scanning", e)
            result.error(TAG, "Failed to scan QR code: ${e.message}", null)
        }
    }

    @Throws(Exception::class)
    private fun getInputImageByByteArray(imageBytes: ByteArray): InputImage {
        val tempFile = File.createTempFile("temp_image", ".jpeg", binding.activity.cacheDir)
        try {
            FileOutputStream(tempFile).use { it.write(imageBytes) }
            return InputImage.fromFilePath(binding.activity.applicationContext, Uri.fromFile(tempFile))
        } finally {
            if (!tempFile.delete()) {
                Log.w(TAG, "Failed to delete temporary file")
            }
        }
    }

    private suspend fun <T> Task<T>.await(): T = suspendCoroutine { continuation ->
        addOnCompleteListener { task ->
            if (task.isSuccessful) {
                continuation.resume(task.result!!)
            } else {
                continuation.resumeWithException(task.exception!!)
            }
        }
    }
}
