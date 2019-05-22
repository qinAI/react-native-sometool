package com.sometooldome;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.util.Log;

import java.io.FileInputStream;
import java.io.IOException;

public class ImageUtils {


    /**
     * 获取图片
     * @param url
     * @return
     */
    public static Bitmap getImageFromePath(String url){

        String imageURL = AppUtils.removeFilePathHeader(url);

        int degree = ImageUtils.getBitmapDegree(imageURL);


        FileInputStream fis = null;
        try {
            fis = new FileInputStream(imageURL);
        }catch (Exception e){
            Log.i("曹尼玛","getImageFromePath---"+e.getMessage());
            return null;
        }

        Bitmap bm = null;
        if (fis != null){
            bm = BitmapFactory.decodeStream(fis);
        }

        //矫正
        if (degree != 0 && bm != null){
            bm = ImageUtils.rotateBitmapByDegree(bm,degree);
        }

        return bm;
    }

    /**
     * 获取限定宽高之后的图像  如果小于最大宽高 isEnlarge  是否放大  当 小于最maxWH的时候需不需要放大处理
     * @param bm
     * @param maxWH
     * @return
     */
    public static Bitmap scaledPicture(Bitmap bm,float maxWH,boolean isEnlarge){

        double width = bm.getWidth();
        double height = bm.getHeight();


        double newWidth = 0;
        double newHeight = 0;


        if (isEnlarge == false){

            if (width > height && width > maxWH) {
                newWidth = (double)maxWH;
                newHeight = (height * maxWH / width);
            }else if (height > width && height > maxWH) {
                newWidth = (width * maxWH / height);
                newHeight = (double)maxWH;
            }else {
                newWidth = bm.getWidth();
                newHeight = bm.getHeight();
            }

        }else {                      //统一缩放到最大宽高

            if (width > height) {
                newWidth = (double)maxWH;
                newHeight = (height * maxWH / width);
            }else{
                newWidth = (width * maxWH / height);
                newHeight = (double)maxWH;
            }
        }



        return Bitmap.createScaledBitmap(bm, (int)newWidth, (int)newHeight, false);
    }


    /**
     * 添加相框 正确的绘制.9图像    在绘制前对图像进行了等比缩放到宽或者高不超过 800 宽度
     * @param src
     * @param wte
     * @returns
     */
    public static Bitmap addFrameToImage(Bitmap src,Bitmap wte) {


        int width = src.getWidth();
        int height = src.getHeight();


        //创建一个bitmap
        Bitmap newb = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);// 创建一个新的和SRC长度宽度一样的位图
        //将该图片作为画布
        Canvas canvas = new Canvas(newb);


        /**
         * 绘制底部原始图像
         */
        canvas.drawBitmap(src, 0, 0, null);

//        /**
//         * 正确绘制.9图像
//         */
//        //获取点9块
//        NinePatch np = new NinePatch(wte, wte.getNinePatchChunk(), null);
//        //开始绘制
//        np.draw(canvas, new Rect(0, 0, width, height));

        Bitmap bmwte = Bitmap.createScaledBitmap(wte,width,height,false);
        canvas.drawBitmap(bmwte,0,0,null);

        // 保存
        canvas.save(Canvas.ALL_SAVE_FLAG);
        // 存储
        canvas.restore();

        return newb;

//  缩放
//        int width = src.getWidth();
//        int height = src.getHeight();
//        int width_wte = wte.getWidth();
//        int height_wte = wte.getHeight();
//
//        float sx = width * 1.0f / width_wte;
//        float sy = height * 1.0f / height_wte;
//
//        //创建一个bitmap
//        Bitmap newb = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);// 创建一个新的和SRC长度宽度一样的位图
//        //将该图片作为画布
//        Canvas canvas = new Canvas(newb);
//        //在画布 0，0坐标上开始绘制原始图片
//        canvas.drawBitmap(src, 0, 0, null);
//        //在画布上绘制水印图片
//
//        Matrix matrix = new Matrix();
//        matrix.setScale(sx,sy);
//        canvas.drawBitmap(wte,matrix,null);
//
//        // 保存
//        canvas.save(Canvas.ALL_SAVE_FLAG);
//        // 存储
//        canvas.restore();
//
//        return newb;

    }


    /**
     * 计算图像旋转角度
     */

    public static int getBitmapDegree(String path) {
        int degree = 0;
        try {
            // 从指定路径下读取图片，并获取其EXIF信息
            ExifInterface exifInterface = new ExifInterface(path);
            // 获取图片的旋转信息
            int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION,ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    degree = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    degree = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    degree = 270;
                    break;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return degree;
    }


    /**
     * 旋转图片为正常角度
     */

    public static Bitmap rotateBitmapByDegree(Bitmap bm, int degree) {
        Bitmap returnBm = null;

        // 根据旋转角度，生成旋转矩阵
        Matrix matrix = new Matrix();
        matrix.postRotate(degree);
        try {
            // 将原始图片按照旋转矩阵进行旋转，并得到新的图片
            returnBm = Bitmap.createBitmap(bm, 0, 0, bm.getWidth(), bm.getHeight(), matrix, true);
        } catch (OutOfMemoryError e) {
        }
        if (returnBm == null) {
            returnBm = bm;
        }
        if (bm != returnBm) {
            bm.recycle();
        }
        return returnBm;
    }
}
