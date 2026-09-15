# ML Kit Core & Text Recognition ProGuard / R8 rules
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

-keep class com.google_mlkit_text_recognition.** { *; }
-dontwarn com.google_mlkit_text_recognition.**

-keep class com.google_mlkit_commons.** { *; }
-dontwarn com.google_mlkit_commons.**

# Google Play Services & Firebase components for ML Kit DI
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep public class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Flutter engine and plugins
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
