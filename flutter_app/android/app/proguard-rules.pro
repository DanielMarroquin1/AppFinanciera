# Flutter ProGuard & R8 Rules for QUIVO

# Flutter engine and plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep common annotations and reflection signatures
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# Java Desugaring & Synthetic warnings
-dontwarn java.lang.invoke.**
-dontwarn **$$ExternalSyntheticLambda**

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Mobile Ads
-keep public class com.google.android.gms.ads.** { public *; }

# RevenueCat (purchases_flutter)
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# Biometrics / Local Auth
-keep class androidx.biometric.** { *; }

# Speech to Text
-keep class com.csdcorp.speech_to_text.** { *; }

# Notification Listener Service & Local Notifications
-keep class notification.listener.service.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Printing / PDF
-keep class net.nfet.flutter.printing.** { *; }

# Prevent warnings for network libraries
-dontwarn okio.**
-dontwarn okhttp3.**

# Play Core (Deferred components / SplitCompat optional classes in Flutter engine)
-dontwarn com.google.android.play.core.**

