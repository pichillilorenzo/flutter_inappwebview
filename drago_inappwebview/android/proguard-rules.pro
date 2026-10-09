# WebView
-keepattributes *JavascriptInterface*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class com.pichillilorenzo.drago_inappwebview.webview.JavaScriptBridgeInterface {
     <fields>;
     <methods>;
     public *;
     private *;
}
-keep class com.pichillilorenzo.drago_inappwebview.** { *; }

-dontwarn android.window.BackEvent
# Note: AGP 9.1.0 changed R8's default to repackage classes into the unnamed
# package. -dontrepackage would opt out of that, but it's a global option and
# AGP 9 now rejects global options set from a library's *consumer* proguard
# file ("mergeDebugConsumerProguardFiles" fails with "should not be used in a
# consumer configuration file"). If a consuming app is minifying and needs to
# opt out of repackaging, add -dontrepackage to that app's own
# android/app/proguard-rules.pro instead — it can't be shipped from here.
-keep class android.print.DragoPdfPrinter { *; }
-keep class android.print.DragoPdfPrinter$* { *; }
