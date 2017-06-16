`Zbar`和`libiconv`都是基于`LGPL-2.1`协议开源的，基于`LGPL-2.1`协议，我为`Android`平台整理了`Zbar`和`libiconv`，方便`Android`开发者使用`Zbar`。

大多数的`Android`开发者不熟悉JNI，并且在编译原生`Zbar`时需要先编译`libiconv`，而且会遇到很多错误和难点，大多数人在网上七拼八凑的找到了别人编译好的 **so** 文件，但是很多人都遇到了错误导致没法修改，现在我把`Zbar`和`libiconv`的源码整理好了，并且修复了在编译时的错误和**中文识别时乱码**的问题。

已经我编译后封装过的`Zbar`：

1. **可以直接ndk-build编译的JNI源码**
2. **可以单独使用的Jar包和so文件**
3. **可以远程依赖的原生Zbar**
4. **封装了Zbar可以直接扫描的相机**

我用的`libiconv`是在2017-02-02发布的1.15版本。

Zbar开源地址: [https://github.com/ZBar/ZBar](https://github.com/ZBar/ZBar)  
libiconv下载: [https://www.gnu.org/software/libiconv](https://www.gnu.org/software/libiconv)  

我的主页：[www.yanzhenjie.com](http://www.yanzhenjie.com)  
我的博客：[blog.yanzhenjie.com](http://blog.yanzhenjie.com)  

技术交流群：[547839514](https://jq.qq.com/?_wv=1027&k=48Yg8H1)  

# 使用

## 仅仅使用核心Zbar
如果你仅仅想使用原生的Zbar，可以结合相机使用，也可以单独直接识别二维码。

首先需要添加依赖，支持以下三种方式：  

* so文件和jar文件
 下载源码后`android-zbar-sdk/jar`文件夹的`zbar-1.0.0.jar`就是`Zbar`核心`jar`包，`android-zbar-sdk\zbar\src\main\jniLibs`下是各个平台的`so`文件，选择自己需要的即可。

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

**注意**：使用远程依赖方式会加载所有平台的so文件，如果你只想依赖其中某几个平台(例如某第三方地图只提供了`armeabi`和`armeabi-v7a`的so，当app运行在x86的手机上时，就会出现加载x86平台某地图so文件失败造成app崩溃的情况)，那么你需要添加编译配置：  
```
defaultConfig {
    applicationId ...
    ...

    ndk {
        abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a', 'mips', 'mips64', 'x86', 'x86_64'
    }
}
```

在`ndk{}`的`{}`中写上你需要的平台即可只加载你需要的平台的so文件，比如你只需要`armeabi`和`armeabi-v7a`：  
```
ndk {
    abiFilters 'armeabi', 'armeabi-v7a'
}
```

Zbar核心识别条码/二维码的代码如下：
```java
byte[] imageData = ...;

Image barcode = new Image(size.width, size.height, "Y800");
barcode.setData(imageData);
// 设置截取区域，也就是你的扫描框在图片上的区域.
// barcode.setCrop(startX, startY, width, height);

String qrCodeString = null;

int result = mImageScanner.scanImage(barcode);
if (result != 0) {
    SymbolSet symSet = mImageScanner.getResults();
    for (Symbol sym : symSet)
        qrCodeString = sym.getData();
}

if (!TextUtils.isEmpty(qrCodeString)) {
    // 非空表示识别出结果了。
}
```

不仅如此，你也可以结合相机和上述代码做扫码识别条码/二维码。在sample中有结合相机扫码的例子。

## 使用相机和Zbar的封装
如果你对相机的使用不太熟悉，那么你可以使用我封装的相机和Zbar的结合，这将非常方便的完成扫码：

添加依赖：

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

这是一个在Activity中的简单的例子：

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
 * 打开相机并开始扫描。
 */
private void startScan() {
    mPreview.start();
}

/**
 * 停止扫描并关闭相机。
 */
private void stopScan() {
    mPreview.stop();
}

/**
 * 监听结果。
 */
private ScanCallback callback = new ScanCallback() {
    @Override
    public void onScanResult(String content) {
        // Successfully.
    }
};

@Override
protected void onPause() {
    // 必须在这里停止扫描释放相机。
    stopScan();
    super.onPause();
}
```

在正式开发中，你还需要注意`运行时权限`和相机是否被占用等异常情况。  

对于权限管理，我推荐你使用AndPermission：[https://github.com/yanzhenjie/AndPermission](https://github.com/yanzhenjie/AndPermission)

比如相机是否正常打开/是否被其它应用占用：
```java
/**
 * Start camera.
 */
private void startScan() {
    if(mPreview.start()) {
        // 相机被成功打开并开始扫描，你可以展示一个扫描的动画了。
    } else {
        // 相机被占用或者打开失败。
    }
}
```

更多的例子请参考sample。

# 混淆规则
如果你已经有以下两个规则，那么就不用添加了。
```text
-keepclassmembers class * {
    native <methods>;
}

-keepclasseswithmembernames class * {
    native <methods>;
}
```

**关注我的微信公众号**
或者微信公众号搜索**严振杰**  

![wechat](./image/wechat.jpg)