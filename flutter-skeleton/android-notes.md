# یادداشت اندروید

بعد از `flutter create` این‌ها را در `android/app/src/main/AndroidManifest.xml` اعمال کن:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:usesCleartextTraffic="true"
        ...>
```

بدون این دو، اتصال HTTP به بک‌اند روی گوشی/امولاتور قطع می‌شود.
