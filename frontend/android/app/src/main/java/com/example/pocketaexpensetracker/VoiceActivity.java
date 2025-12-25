package com.example.pocketaexpensetracker;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;

public class VoiceActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Handle voice input from Google Assistant
        Intent intent = getIntent();
        if (intent != null && intent.getAction() != null) {
            // Process voice input and communicate with Flutter
            // This would use platform channels to send data to Flutter
        }
    }
}
