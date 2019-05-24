
package com.sometooldome;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Handler;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;
import com.shahenlibrary.Trimmer.Trimmer;
import com.theartofdev.edmodo.cropper.CropImage;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import wseemann.media.FFmpegMediaMetadataRetriever;

import static android.app.Activity.RESULT_OK;

public class RNSometoolModule extends ReactContextBaseJavaModule {


  static final String REACT_PACKAGE = "RNSometoolModule";


  private Callback mPickerCallback;     // 保存回调
  private Callback editImageCallBack;   //编辑图片



  private ReactApplicationContext reactContext;


  public RNSometoolModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;

    /**
     * 添加控制器返回监听
     */
    reactContext.addActivityEventListener(activityEventListener);


    Trimmer.loadFfmpeg(reactContext);

  }

  @Override
  public String getName() {
    return "RNSometool";
  }







  /***
   * 跳转设置
   * @param type
   */
  @ReactMethod
  public void goToSetting(String type) {
    if (type.equals("0")){     /**跳转设置界面*/
      final Activity activity = getCurrentActivity();

      try {
        Intent intent = new Intent();
        intent.setAction(Settings.ACTION_APP_NOTIFICATION_SETTINGS);

        //这种方案适用于 API 26, 即8.0（含8.0）以上可以用
        intent.putExtra(Settings.EXTRA_APP_PACKAGE, getReactApplicationContext().getPackageName());
        intent.putExtra(Settings.EXTRA_CHANNEL_ID, getReactApplicationContext().getApplicationInfo().uid);

        //这种方案适用于 API21——25，即 5.0——7.1 之间的版本可以使用
        intent.putExtra("app_package", getReactApplicationContext().getPackageName());
        intent.putExtra("app_uid", getReactApplicationContext().getApplicationInfo().uid);
        activity.startActivity(intent);

      }catch (Exception e){
        e.printStackTrace();
        // 出现异常则跳转到应用设置界面：锤子坚果3——OC105 API25
        Intent intent = new Intent();

        //下面这种方案是直接跳转到当前应用的设置界面。
        //https://blog.csdn.net/ysy950803/article/details/71910806
        intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", getReactApplicationContext().getPackageName(), null);
        intent.setData(uri);
        activity.startActivity(intent);

      }

    }
  }







  /**
   * 添加回调
   */
  private final ActivityEventListener activityEventListener = new BaseActivityEventListener(){
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode,final Intent data) {
      super.onActivityResult(activity, requestCode, resultCode, data);

      Log.i("tamamade","onActivityResult.requestCode---："+requestCode + "" + resultCode + "" + data);


      if (requestCode == PictureConfig.CHOOSE_REQUEST){

        if (resultCode == RESULT_OK){onGetResult(data);}

      }else if (requestCode == CropImage.CROP_IMAGE_ACTIVITY_REQUEST_CODE) {

        CropImage.ActivityResult result = CropImage.getActivityResult(data);
        if (resultCode == RESULT_OK) {

          Uri resultUri = result.getUri();
          onGetCropImageUrl(resultUri.getPath());

        } else if (resultCode == CropImage.CROP_IMAGE_ACTIVITY_RESULT_ERROR_CODE) {
          onGetCropErrorImageUrl();
        }
      }else if (requestCode == KmaFilterActivity.Activity_Filter_REQUEST_CODE ||
                requestCode == KmaPhotoFrameActivity.Activity_PhotoFrame_REQUEST_CODE){   //请求滤镜界面
        String value = data.getStringExtra("msg");  //返回消息

        if (resultCode == RESULT_OK){
          onGetCropImageUrl(value);
        }else {
          onGetCropErrorImageUrl();
        }
      }
    }
  };


  private void onGetCropImageUrl(String imagePath){   //点击了返回键


    if (this.editImageCallBack != null && imagePath.length() > 5){

      Bitmap bitmap = BitmapFactory.decodeFile(imagePath);

      WritableMap nativeMap = new WritableNativeMap();
      nativeMap.putString("path", "file://" + imagePath);
      nativeMap.putDouble("width", bitmap.getWidth());
      nativeMap.putDouble("height", bitmap.getHeight());

      this.editImageCallBack.invoke(200,nativeMap);
      this.editImageCallBack = null;
    }else {
      onGetCropErrorImageUrl();
    }

  }
  private void onGetCropErrorImageUrl(){

    if (this.editImageCallBack != null){
      this.editImageCallBack.invoke(202,"");
      this.editImageCallBack = null;
    }

  }


  /**
   * 图片库相关回调
   * @param data
   */
  private void onGetResult(Intent data){



    List<LocalMedia> tmpSelectList = PictureSelector.obtainMultipleResult(data);

    WritableArray list = new WritableNativeArray();

    for (LocalMedia media : tmpSelectList) {

      // 1.media.getPath(); 为原图path
      // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true
      // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true

      Log.i("onGetResult",":" + media.getPath() +":" + media.getCutPath() +":"+ media.getCompressPath() + ":"+media.getMimeType() + ":"+media.getWidth() +":"+media.getHeight());

      WritableMap map = new WritableNativeMap();

      map.putString("path","file://"+media.getPath());
      map.putString("type",media.getMimeType() == 1 ? "image" : "video");

      if (media.isCut()) {
        map.putString("cutPath","file://"+media.getCutPath());
      }

      if (media.isCompressed()){
        map.putString("compressPath","file://"+media.getCompressPath());
      }


      map.putString("duration", media.getDuration() + "");
      map.putDouble("width",media.getWidth());
      map.putDouble("height",media.getHeight());

      if (media.getWidth() == 0 && media.getMimeType() == 1){
        Bitmap bitmap = BitmapFactory.decodeFile(media.getPath());
        map.putDouble("width",bitmap.getWidth());
        map.putDouble("height",bitmap.getHeight());
      }else if(media.getWidth() == 0 && media.getMimeType() == 2){   //拍摄视频信息的获取没有

      }



      list.pushMap(map);

    }

    if (tmpSelectList.isEmpty()) {
      if (this.mPickerCallback != null) {
        this.mPickerCallback.invoke(202,list);
        this.mPickerCallback = null;
      }
    } else {
      if (this.mPickerCallback != null) {
        this.mPickerCallback.invoke(200, list);
        this.mPickerCallback = null;
      }
    }

  }



  @ReactMethod
  public void showPictureSelector(Callback callback){
    this.mPickerCallback =  callback;

    /**
     * 打开图片选择多选
     */
    PictureSelector.create(getCurrentActivity())
            .openGallery(PictureMimeType.ofImage())
            .theme(R.style.picture_QQ_style)
            .isCamera(false)
//                .maxSelectNum(maxSelectNum)
//                .enableCrop(maxSelectNum == 1)
//                .rotateEnabled(false)
            .forResult(PictureConfig.CHOOSE_REQUEST);
  }

  @ReactMethod
  public void showCameraTakePicture(Callback callback){
    this.mPickerCallback =  callback;

    /**
     * 打开相机拍照
     */
    PictureSelector.create(getCurrentActivity())
            .openCamera(PictureMimeType.ofImage())
            .theme(R.style.picture_QQ_style)
            .imageFormat(PictureMimeType.JPEG)
//                .enableCrop(true)
//                .rotateEnabled(false)
            .forResult(PictureConfig.CHOOSE_REQUEST);
  }


  @ReactMethod
  public void showVideosSelectorType(boolean isSingle, Callback callback){
    this.mPickerCallback =  callback;

    /**
     * 打开单选视频
     */
    PictureSelector.create(getCurrentActivity())
            .openGallery(PictureMimeType.ofVideo())
            .theme(R.style.picture_QQ_style)
            .isCamera(false)
            .maxSelectNum(isSingle ? 1 : 9)
            .videoMaxSecond(30)
            .videoMinSecond(10)
            .forResult(PictureConfig.CHOOSE_REQUEST);
  }

  @ReactMethod
  public void showCameraTakeVideo(Callback callback){
    this.mPickerCallback =  callback;

    /**
     * 打开相机录制
     */
    PictureSelector.create(getCurrentActivity())
            .openCamera(PictureMimeType.ofVideo())
            .theme(R.style.picture_QQ_style)
            .videoQuality(1)            //视频录制质量 0 or 1 int
            .recordVideoSecond(10)      //视频秒数录制 默认60s int
            .forResult(PictureConfig.CHOOSE_REQUEST);
  }


  @ReactMethod
  public void showSingleCrop(Callback callback){
    this.mPickerCallback =  callback;

    /**
     * 打开图片选择多选
     */
    PictureSelector.create(getCurrentActivity())
            .openGallery(PictureMimeType.ofImage())
            .theme(R.style.picture_QQ_style)
            .isCamera(false)
            .maxSelectNum(1)
            .enableCrop(true)
            .rotateEnabled(false)
            .freeStyleCropEnabled(false)      // 裁剪框是否可拖拽 true or false
            .withAspectRatio(1, 1)         // int 裁剪比例 如16:9 3:2 3:4 1:1 可自定义。
            .hideBottomControls(true)
            .circleDimmedLayer(false)       // 是否圆形裁剪 true or false
            .showCropFrame(true)          // 是否显示裁剪矩形边框 圆形裁剪时建议设为false   true or false
            .showCropGrid(false)           // 是否显示裁剪矩形网格 圆形裁剪时建议设为false    true or false
            .forResult(PictureConfig.CHOOSE_REQUEST);
  }



  /**
   * 编辑图片的两个方法
   * @param imagePath
   * @param maxWH
   * @param callback
   */
  @ReactMethod
  public void showPhotoFrameImageVc(String imagePath,  int maxWH, Callback callback){

    if (imagePath == null || imagePath.length() == 0){
        callback.invoke(202,new WritableNativeArray());
        return;
    }

    this.editImageCallBack = callback;

    String path = AppUtils.removeFilePathHeader(imagePath);

    Intent intent = new Intent(getReactApplicationContext(),KmaPhotoFrameActivity.class);
    intent.putExtra("imageURL",path);
    intent.putExtra("maxWH",maxWH);
    getCurrentActivity().startActivityForResult(intent, KmaPhotoFrameActivity.Activity_PhotoFrame_REQUEST_CODE);


  }


  @ReactMethod
  public void showCropFilterImageVc(String imagePath, int type, Callback callback){


    if (imagePath == null || imagePath.length() == 0){
      callback.invoke(202,new WritableNativeArray());
      return;
    }


    this.editImageCallBack = callback;

    if (type == 0){           //裁剪

      CropImage.activity(Uri.parse(imagePath))
              .setAllowFlipping(false)
              .setAllowRotation(false)
              .start(getCurrentActivity());

    }else if (type == 1){     //滤镜

      String path = AppUtils.removeFilePathHeader(imagePath);

      Intent intent = new Intent(getReactApplicationContext(),KmaFilterActivity.class);
      intent.putExtra("imageURL",path);
      getCurrentActivity().startActivityForResult(intent, KmaFilterActivity.Activity_Filter_REQUEST_CODE);

    }else if (type == 2) {                   //相框


    }

  }




  @ReactMethod
  public void showVideoPlayer(String url){

    /**
     * 系统自带播放视频
     */
    Uri uri = Uri.parse(AppUtils.removeFilePathHeader(url));
    //调用系统自带的播放器
    Intent intent = new Intent(Intent.ACTION_VIEW);
    intent.setDataAndType(uri, "video/*");
    getCurrentActivity().startActivity(intent);


//    VideoView
//    MediaPlayer

  }


  /**
   *
   * @param path
   * @param promise
   */


  @ReactMethod
  public void videoTrimmerPreviewImages(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "getPreviewImages: " + path);
    Trimmer.getPreviewImages(path, promise, reactContext);
  }

  @ReactMethod
  public void getVideoInfo(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "getVideoInfo: " + path);
    Trimmer.getVideoInfo(path, promise, reactContext);
  }

  @ReactMethod
  public void videoTrimmerTrim(ReadableMap options, Promise promise) {
    Log.d(REACT_PACKAGE, options.toString());
    Trimmer.trim(options, promise, reactContext);
  }

  @ReactMethod
  public void videoTrimmerCompress(String path, ReadableMap options, Promise promise) {
    Log.d(REACT_PACKAGE, "compress video: " + options.toString());
    Trimmer.compress(path, options, promise, null, null, reactContext);
  }

  @ReactMethod
  public void videoTrimmerPreviewImage(ReadableMap options, Promise promise) {
    String source = options.getString("source");
    double sec = options.hasKey("second") ? options.getDouble("second") : 0;
    String format = options.hasKey("format") ? options.getString("format") : null;
    Trimmer.getPreviewImageAtPosition(source, sec, format, promise, reactContext);
  }

  @ReactMethod
  public void videoTrimmerCrop(String path, ReadableMap options, Promise promise) {
    Trimmer.crop(path, options, promise, reactContext);
  }

  @ReactMethod
  public void videoTrimmerboomerang(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "boomerang video: " + path);
    Trimmer.boomerang(path, promise, reactContext);
  }

  @ReactMethod
  public void videoTrimmerReverse(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "reverse video: " + path);
    Trimmer.reverse(path, promise, reactContext);
  }

}