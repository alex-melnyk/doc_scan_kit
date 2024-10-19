package com.rajada1_docscan_kit.doc_scan_kit
import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.util.Log
import com.google.android.gms.common.internal.Objects
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.plugin.common.MethodCall


class DocumentScanKit : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener   {

    private lateinit var  binding : ActivityPluginBinding;
    private val scanRequestCode =1;
    private var pendingResult: MethodChannel.Result? = null

    fun setActivityPluginBinding(binding:ActivityPluginBinding){
        this.binding = binding
        binding.addActivityResultListener(this)
    }

        private fun makeScanMode(mode : String) : Int {
            val scanMode = when (mode){
                "base" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE
                "filter" -> GmsDocumentScannerOptions.SCANNER_MODE_BASE_WITH_FILTER
                "full" -> GmsDocumentScannerOptions.SCANNER_MODE_FULL
                else -> {
                    GmsDocumentScannerOptions.SCANNER_MODE_FULL
                }
            }
            return scanMode;
        }
        private fun scanner(result:MethodChannel.Result, optionsAndroid : Map<*, *>){
            this.pendingResult = result

            GmsDocumentScannerOptions.CAPTURE_MODE_AUTO
            val options = GmsDocumentScannerOptions.Builder()
                .setGalleryImportAllowed(optionsAndroid["isGalleryImport"] as Boolean)
                .setPageLimit(optionsAndroid["pageLimit"] as Int)
                .setResultFormats(GmsDocumentScannerOptions.RESULT_FORMAT_JPEG)
                .setScannerMode(makeScanMode(optionsAndroid["scannerMode"] as String))

                .build()

            val activity = binding.activity;
            try {
                val scan = GmsDocumentScanning.getClient(options)
                scan.getStartScanIntent(activity).addOnSuccessListener {
                    intentSender: IntentSender ->
                    try {
                        activity.startIntentSenderForResult(
                            intentSender, scanRequestCode,null,0,0,0

                        )
                    }catch (e: IntentSender.SendIntentException){
                        e.printStackTrace()
                        throw e;
                    }
                }
            } catch (e: Exception){
                Log.e("DocScanKit","Error $e")
                this.pendingResult?.error("Error", e.message,null)
            }

        }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if(requestCode == scanRequestCode){
            val result = GmsDocumentScanningResult.fromActivityResultIntent(data)
            if(result != null){
                val pages = result.pages
                if(!pages.isNullOrEmpty()){
                    val imgArray: ArrayList<ByteArray> = arrayListOf()
                    for (page in pages){
                        val inputStream = binding.activity.contentResolver.openInputStream(page.imageUri)
                        if (inputStream != null) {
                            val bytes = inputStream.readBytes()
                            imgArray.add(bytes)
                            inputStream.close()
                        } else {
                            Log.e("DocumentScannerKit", "Error opening input stream for page ${page.imageUri}")
                        }
                    }
                    this.pendingResult?.success(imgArray.toList())
                    return true
                }else{
                    this.pendingResult?.error("Error", "Page empty or null", null)
                }
            }else{
                this.pendingResult?.error("Error", "Result null", null)
            }
        }else if (resultCode == Activity.RESULT_CANCELED){
            this.pendingResult?.success(null)
            return true
        }else{
            Log.i("DocumentScanKit", "Activity end $resultCode")
        }
        return false;
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
            if(call.method == "scanner"){
                val options = call.arguments as? Map<*, *>
                val optionsAndroid = options!!["androidOptions"] as Map<*, *>


                scanner(result, optionsAndroid);
            }else{
                result.notImplemented()
            }
    }


}