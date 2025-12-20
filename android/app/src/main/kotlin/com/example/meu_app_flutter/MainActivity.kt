package com.example.meu_app_flutter

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            super.onCreate(savedInstanceState)
            Log.d(TAG, "MainActivity criada com sucesso")
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao criar MainActivity", e)
            // Não propaga exceção - evita crash
        }
    }

    override fun onResume() {
        try {
            super.onResume()
        } catch (e: Exception) {
            Log.e(TAG, "Erro no onResume", e)
        }
    }
}
