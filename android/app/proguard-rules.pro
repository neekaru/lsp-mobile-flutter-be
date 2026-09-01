# Flutter Wrapper & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Generated Plugins
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# App-specific classes
-keep class id.lspdigital.mobile.** { *; }

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Maps / Location
-keep class com.google.android.geo.** { *; }
-dontwarn com.google.android.geo.**

# OkHttp / Okio / Network
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# General Attributes
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Suppress generic warnings
-dontwarn io.flutter.**
-dontwarn androidx.**
