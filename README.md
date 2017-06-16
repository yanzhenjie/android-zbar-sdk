Zbar and libiconv are based on `LGPL-2.1` open source, based on `LGPL-2.1`, I organized the Android platform for the ZBar, to facilitate the use of developers.

[中文文档](./README-CN.md)

Most Android developers are relatively unfamiliar to jni, especially in the compilation of Zbar need to compile libiconv, so I have sorted out the full jni code.

I have the Zbar available, the following you can choose to use:

1. **can be directly ndk-build compiled JNI source**
2. **Jar packages and so files that can be used alone**
3. **can be remotely dependent on the native Zbar**
4. **Encapsulated Zbar can directly scan the camera**

I used the `libiconv` is released at 2017-02-02 the latest version 1.15.

zbar: [https://github.com/ZBar/ZBar](https://github.com/ZBar/ZBar)  
libiconv: [https://www.gnu.org/software/libiconv](https://www.gnu.org/software/libiconv)  

# Usage

## Only core function of ZBar
If you only want to identify the barcode/QRCode data in `byte[]`, then you only need to rely on native ZBar.

Add dependencies:

* jar file and so file
 jar file in the `android-zbar-sdk/jar` folder, so files in the `android-zbar-sdk\zbar\src\main\jniLibs` folder.

* Gradle
```groovy
compile 'com.yanzhenjie.zbar:zbar:1.0.0'
```
* Maven
```groovy
<dependency>
  <groupId>com.yanzhenjie.zbar</groupId>
  <artifactId>zbar</artifactId>
  <version>1.0.0</version>
  <type>pom</type>
</dependency>
```

**Note**: The use of remote dependencies will load all the files so the platform, if you just want to rely on some of these platforms, then you need to add the compilation configuration:    
```
defaultConfig {
    applicationId ...
    ...

    ndk {
        abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a', 'mips', 'mips64', 'x86', 'x86_64'
    }
}
```

For example, you only need `armeabi` and` armeabi-v7a`:  
```
ndk {
    abiFilters 'armeabi', 'armeabi-v7a'
}
```

Zbar's core recognition barcode/QRCode code is as follows.
```java
byte[] imageData = ...;

Image barcode = new Image(size.width, size.height, "Y800");
barcode.setData(imageData);
// Set the image capture area.
// barcode.setCrop(startX, startY, width, height);

String qrCodeString = null;

int result = mImageScanner.scanImage(barcode);
if (result != 0) {
    SymbolSet symSet = mImageScanner.getResults();
    for (Symbol sym : symSet)
        qrCodeString = sym.getData();
}

if (!TextUtils.isEmpty(resultStr)) {
    // Successfully.
}
```

Not only that, you can also use the camera to combine this code to identify barcode/QRCode.   

There are examples of camera scans in Demo.

## Package of Camera and ZBar
If you are not familiar with the camera, you can also use my camera and ZBar package, will be very simple to use the camera to complete the two-dimensional code scan.

Add dependencies:

* Gradle
```groovy
compile 'com.yanzhenjie.zbar:camera:1.0.0'
```
* Maven
```groovy
<dependency>
  <groupId>com.yanzhenjie.zbar</groupId>
  <artifactId>camera</artifactId>
  <version>1.0.0</version>
  <type>pom</type>
</dependency>
```

This is a simple example in Activity:

`activity_scan.xml`
```xml
<RelativeLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <com.yanzhenjie.zbar.camera.CameraPreview
        android:id="@+id/capture_preview"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>
<RelativeLayout/>
```

`ScanActivity.java`
```java
private CameraPreview mPreview;

@Override
protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_scan);
    
    mPreview = (CameraPreview) findViewById(R.id.capture_preview);
    mPreview.setScanCallback(callback);
}

/**
 * Start camera.
 */
private void startScan() {
    mPreview.start();
}

/**
 * Stop camera.
 */
private void stopScan() {
    mPreview.stop();
}

/**
 * Result.
 */
private ScanCallback callback = new ScanCallback() {
    @Override
    public void onScanResult(String content) {
        // Successfully.
    }
};

@Override
protected void onPause() {
    // Must be called here, otherwise the camera should not be released properly.
    stopScan();
    super.onPause();
}
```

The actual development you need to pay attention to the `RunTime Permission`, the camera is occupied and so on.  

For RunTime-Permission, I recommend you use AndPermission:  
[https://github.com/yanzhenjie/AndPermission](https://github.com/yanzhenjie/AndPermission)

Such as whether the camera started successfully:
```java
/**
 * Start camera.
 */
private void startScan() {
    if(mPreview.start()) {
        // The camera starts successfully and you can start a scan animation.
    } else {
        // The camera starts failing and you can tell the user.
    }
}
```

For more examples please refer to sample.

# Proguard-rules
If you already have this rule, then you do not have to add.
```text
-keepclassmembers class * {
    native <methods>;
}

-keepclasseswithmembernames class * {
    native <methods>;
}
```