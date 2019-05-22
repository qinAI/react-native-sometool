package com.sometooldome;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.OrientationHelper;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;

import java.io.File;
import java.io.FileOutputStream;

public class KmaPhotoFrameActivity extends AppCompatActivity {


    public static final int Activity_PhotoFrame_REQUEST_CODE = 2011;
    public static final int Activity_PhotoFrame_RESULT_ERROR_CODE = 2012;


    private RecyclerView mRecyclerView;
    private ImageView imageView;

    private String imageURL;
    private Bitmap srcImage;

    private Bitmap currrnetImage;

    private SparseArray<Bitmap> images = new SparseArray<>();
    private SparseArray<String> titles = new SparseArray<>();



    private int maxWH;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_kma_filter);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setTitle("相框");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mRecyclerView = findViewById(R.id.filter_rv);
        imageView = findViewById(R.id.filter_image_view);


        Intent intent = getIntent();
        final String imageURL = intent.getStringExtra("imageURL");
        final int maxWH = intent.getIntExtra("maxWH",800);

        this.imageURL = imageURL;
        this.maxWH = maxWH;
        this.srcImage = AppUtils.getImageFromePath(imageURL);


        imageView.setImageBitmap(this.srcImage);


        if (mRecyclerView != null){

            LinearLayoutManager manager = new LinearLayoutManager(this);
            BottomAdapter adapter = new BottomAdapter();

            Bitmap bmpf = BitmapFactory.decodeResource(getResources(),R.drawable.pf_big_002);
            images.put(0,bmpf);
            titles.put(0,"相框1");

            adapter.setImages(images);
            adapter.setTitles(titles);

            adapter.setOnItemClickedListener(new BottomAdapter.OnItemClickedListener() {
                @Override
                public void onClicked(View view, int position) {
                    Log.i("曹尼玛","添加相框打印事件---"+position);


                    Bitmap src = srcImage;
                    Bitmap wte = images.valueAt(position);

                    Bitmap scaledImage = ImageUtils.scaledPicture(src,maxWH,true);

                    //统一限定
                    Bitmap newb = ImageUtils.addFrameToImage(scaledImage,wte);

                    currrnetImage = newb;

                    imageView.setImageBitmap(currrnetImage);
                }
            });

            mRecyclerView.setLayoutManager(manager);
            manager.setOrientation(OrientationHelper.HORIZONTAL);
            mRecyclerView.setAdapter(adapter);
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





    private void  saveImageFinish(){


        String newPath = AppUtils.getFileNameNoEx(this.imageURL) + "_AndroidPhotoFrame" + "." +AppUtils.getExtensionName(this.imageURL);
        Bitmap newBm = this.currrnetImage;

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
            setResult(Activity_PhotoFrame_RESULT_ERROR_CODE,intent);
            finish();
        }
    }

}
