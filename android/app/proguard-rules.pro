# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep all native methods
-keepclassmembers class * {
    native <methods>;
}

# Video Player
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Audio Players
-keep class xyz.luan.audioplayers.** { *; }

# Stripe
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.** { *; }

# Keep native libraries
-keep class **.R$* { *; }

# Preserve all classes with native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter Secure Storage - CRÍTICO para evitar crash
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# SQLite
-keep class com.tekartik.sqflite.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Device Info
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Notifications
-keep class com.dexterous.** { *; }

# Preserva anotações e assinaturas
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception
-keepattributes InnerClasses
-keepattributes EnclosingMethod
