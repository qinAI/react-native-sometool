package com.sometooldome;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class AppUtils {

    /**
     * 去除文件路径头
     * @param url
     * @return
     */
    public static String removeFilePathHeader(String url){
        String path = url;
        int dot = url.lastIndexOf("file://");
        if ((dot >-1) && (dot < (url.length() - 1))) {
            path = url.substring(dot + 7);
        }
        return path;
    }


    /**
     * 获取图片
     * @param url
     * @return
     */
    public static Bitmap getImageFromePath(String url){

        String imageURL = removeFilePathHeader(url);

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



    public static boolean saveImageToPath(Bitmap bm,String savePath){

        try {
            File file = new File(savePath);
            FileOutputStream fos = new FileOutputStream(file);
            bm.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
            return true;
        }catch (Exception e){
            Log.i("曹尼玛","getImageFromePath---"+e.getMessage());
            return false;
        }

    }


    /**
     * Java文件操作 获取文件扩展名
     * */
    public static String getExtensionName(String filename) {
        if ((filename != null) && (filename.length() > 0)) {
            int dot = filename.lastIndexOf('.');
            if ((dot >-1) && (dot < (filename.length() - 1))) {
                return filename.substring(dot + 1);
            }
        }
        return filename;
    }


    /**
     * Java文件操作 获取不带扩展名的文件名
     * */
    public static String getFileNameNoEx(String filename) {
        if ((filename != null) && (filename.length() > 0)) {
            int dot = filename.lastIndexOf('.');
            if ((dot >-1) && (dot < (filename.length()))) {
                return filename.substring(0, dot);
            }
        }
        return filename;
    }

}
