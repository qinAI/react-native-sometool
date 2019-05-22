package com.sometooldome;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;
import android.net.Uri;
import android.nfc.Tag;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.OrientationHelper;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.ArrayMap;
import android.util.Log;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.lang.reflect.Array;
import java.util.Map;

import jp.co.cyberagent.android.gpuimage.GPUImage;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageBoxBlurFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageBrightnessFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageExposureFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageHazeFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageRGBFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageSaturationFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageSepiaToneFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageSketchFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageSmoothToonFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageVibranceFilter;
import jp.co.cyberagent.android.gpuimage.filter.GPUImageVignetteFilter;

import static android.content.ContentValues.TAG;
public class KmaFilterActivity extends AppCompatActivity {

    public static final int Activity_Filter_REQUEST_CODE = 3011;
    public static final int Activity_Filter_RESULT_ERROR_CODE = 3012;

    private RecyclerView mRecyclerView;

//    private jp.co.cyberagent.android.gpuimage.GPUImageView gpuImageView;

    private ImageView imageView;



    private SparseArray<Bitmap> images = new SparseArray<>();
    private SparseArray<String> titles = new SparseArray<>();



    private int currentIndex = 0;
    private String imageURL;


    private Handler handler;


    private Bitmap srcBm;
    private BottomAdapter adapter;

    /**
     * 官方建议的静态内部类
     */
    private final Handler mainHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {

            adapter.setImages(images);
            adapter.setTitles(titles);
            adapter.notifyDataSetChanged();

            Log.i("曹尼玛","接收事件："+Thread.currentThread().getName() + "图片个数：" + images.size());
            return true;
        }
    });



    private void processingPictures(){
        /**
         * 创建一个线程
         */
        HandlerThread ht = new HandlerThread("ProcessingFilterImage");
        ht.start();


        handler = new Handler(ht.getLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i < 12; i++){
                    filterImage(srcBm,i);
                }

                Log.i("曹尼玛","发送事件："+Thread.currentThread().getName() + "图片个数：" + images.size());
                mainHandler.sendEmptyMessage(0);
            }
        });
    }



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_frame_filter);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle("滤镜");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mRecyclerView = findViewById(R.id.rv);
        imageView = findViewById(R.id.pff_image_view);

        Intent intent = getIntent();
        String imageURL = intent.getStringExtra("imageURL");
        this.imageURL = imageURL;




        Bitmap bm = ImageUtils.getImageFromePath(imageURL);

        if (bm != null){
            imageView.setImageBitmap(bm);
            this.srcBm = bm;

            this.processingPictures();
        }else {
            intent.putExtra("msg","imageURL出错");
            setResult(Activity_Filter_RESULT_ERROR_CODE,intent);
            finish();
        }




        LinearLayoutManager manager = new LinearLayoutManager(this);
        adapter = new BottomAdapter();
        adapter.setImages(images);
        adapter.setTitles(titles);

        adapter.setOnItemClickedListener(new BottomAdapter.OnItemClickedListener() {
            @Override
            public void onClicked(View view, int position) {
                Log.i("曹尼玛","打印事件---"+position);
                currentIndex = position;
                imageView.setImageBitmap(images.valueAt(position));
            }
        });

        mRecyclerView.setLayoutManager(manager);
        manager.setOrientation(OrientationHelper.HORIZONTAL);
        mRecyclerView.setAdapter(adapter);


    }


    /**
     * 滤镜处理
     * @param bm
     * @param index
     */
    private void filterImage(Bitmap bm, int index){

        if (index == 0){
            images.put(index,bm);
            titles.put(index,"经典");
        }else {
            GPUImage gpuImage =  new GPUImage(getApplicationContext());


            if (index == 1){   //怀旧
                gpuImage.setFilter(new GPUImageSepiaToneFilter());
                titles.put(index,"怀旧");

            }else if (index == 2){ //中间突出 四周暗
                GPUImageVignetteFilter filter = new GPUImageVignetteFilter(new PointF(0.5f,0.5f),new float[]{0.0f, 0.0f, 0.0f},0.5f,0.75f);
                gpuImage.setFilter(filter);
                titles.put(index,"视窗");

            }else if (index == 3){ //朦胧加暗
                gpuImage.setFilter(new GPUImageHazeFilter());
                titles.put(index,"朦胧");

            }else if (index == 4){ //饱和
                GPUImageSaturationFilter filter = new GPUImageSaturationFilter();
                filter.setSaturation(1.5f);
                gpuImage.setFilter(filter);
                titles.put(index,"饱和度");

            }else if (index == 5){ //亮度
                GPUImageBrightnessFilter filter = new GPUImageBrightnessFilter();
                filter.setBrightness(0.2f);
                gpuImage.setFilter(filter);
                titles.put(index,"亮度");

            }else if (index == 6){ //曝光度
                GPUImageExposureFilter filter = new GPUImageExposureFilter();
                filter.setExposure(0.2f);
                gpuImage.setFilter(filter);
                titles.put(index,"曝光度");

            }else if (index == 7){ //素描
                gpuImage.setFilter(new GPUImageSketchFilter());
                titles.put(index,"素描");

            }else if (index == 8){ //卡通
                gpuImage.setFilter(new GPUImageSmoothToonFilter());
                titles.put(index,"卡通");

            }else if (index == 9){ // RGB

                GPUImageRGBFilter filter = new GPUImageRGBFilter();
                //蓝
                filter.setRed(0.8f);
                filter.setGreen(0.8f);
                filter.setBlue(0.9f);
                gpuImage.setFilter(filter);
                titles.put(index,"RGB蓝");

            }else if (index == 10){ // RGB

                GPUImageRGBFilter filter = new GPUImageRGBFilter();
                //绿
                filter.setRed(0.8f);
                filter.setGreen(0.9f);
                filter.setBlue(0.8f);
                gpuImage.setFilter(filter);
                titles.put(index,"RGB绿");

            }else if (index == 11){ // RGB

                GPUImageRGBFilter filter = new GPUImageRGBFilter();
                //红
                filter.setRed(0.9f);
                filter.setGreen(0.8f);
                filter.setBlue(0.8f);
                gpuImage.setFilter(filter);
                titles.put(index,"RGB红");

            }

            Bitmap newBm = gpuImage.getBitmapWithFilterApplied(bm);
            images.put(index,newBm);
        }

    }


    /**
     * 安卓导航栏最右边添加按钮
     *
     */

    @Override
    public boolean onCreateOptionsMenu(Menu menu){
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.nav_itme, menu);
        return true;
    }


    /**
     * 导航栏按钮的点击事件
     * @param item
     * @return
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item){

        if (item.getItemId() == R.id.action_cart){
            saveImageFinish();
            return true;
        }

        /**
         * 导航栏上的返回按钮
         */
        if (item.getItemId() == android.R.id.home) {
            setResultCancel();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    /**
     * 物理返回按钮
     */
    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setResultCancel();
    }

    private void setResultCancel(){
        Intent intent = getIntent();
        intent.putExtra("msg",this.imageURL);
        setResult(RESULT_OK,intent);
        finish();
    }


    /**
     * 保存图片传递
     */
    private void saveImageFinish(){

        if (this.currentIndex == 0){
            setResultCancel();
        }

        String newPath = AppUtils.getFileNameNoEx(this.imageURL) + "_AndroidFilter" + "." +AppUtils.getExtensionName(this.imageURL);
        Bitmap newBm = this.images.valueAt(this.currentIndex);

        //写入文件
        try {
            File file = new File(newPath);
            FileOutputStream fos = new FileOutputStream(file);
            newBm.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();

            Intent intent = getIntent();
            intent.putExtra("msg",newPath);
            setResult(RESULT_OK,intent);
            finish();

        }catch (Exception e){

            Intent intent = getIntent();
            intent.putExtra("msg","imageURL出错");
            setResult(Activity_Filter_RESULT_ERROR_CODE,intent);
            finish();
        }



    }
}
