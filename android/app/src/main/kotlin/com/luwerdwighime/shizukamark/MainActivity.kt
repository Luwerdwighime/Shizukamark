package com.luwerdwighime.shizukamark

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.OutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.luwerdwighime.shizukamark/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNativeLibraryDir" -> {
                    try {
                        val libDir = applicationInfo.nativeLibraryDir
                        result.success(libDir)
                    } catch (e: Exception) {
                        result.error("NATIVE_DIR_ERROR", e.localizedMessage, null)
                    }
                }
                "saveAudioToMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType") ?: "audio/*"

                    if (filePath == null || fileName == null) {
                        result.error("INVALID_ARGS", "filePath and fileName are required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = saveAudioFile(filePath, fileName, mimeType)
                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveAudioFile(sourceFilePath: String, targetFileName: String, mimeType: String): String {
        val sourceFile = File(sourceFilePath)
        if (!sourceFile.exists()) {
            throw IllegalArgumentException("Source file does not exist: $sourceFilePath")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, targetFileName)
                put(MediaStore.Audio.Media.MIME_TYPE, mimeType)
                put(MediaStore.Audio.Media.RELATIVE_PATH, "Music/Shizukamark")
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }

            val resolver = contentResolver
            val uri: Uri = resolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, contentValues)
                ?: throw IllegalStateException("Failed to create MediaStore entry")

            try {
                resolver.openOutputStream(uri)?.use { outStream ->
                    FileInputStream(sourceFile).use { inStream ->
                        inStream.copyTo(outStream)
                    }
                } ?: throw IllegalStateException("Failed to open output stream")

                contentValues.clear()
                contentValues.put(MediaStore.Audio.Media.IS_PENDING, 0)
                resolver.update(uri, contentValues, null, null)

                return "Music/Shizukamark/$targetFileName"
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
        } else {
            val musicDir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC), "Shizukamark")
            if (!musicDir.exists()) {
                musicDir.mkdirs()
            }
            val targetFile = File(musicDir, targetFileName)
            FileInputStream(sourceFile).use { inStream ->
                FileOutputStream(targetFile).use { outStream ->
                    inStream.copyTo(outStream)
                }
            }
            MediaScannerConnection.scanFile(this, arrayOf(targetFile.absolutePath), arrayOf(mimeType), null)
            return targetFile.absolutePath
        }
    }
}
