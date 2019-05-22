package com.sometooldome;

import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;

import com.facebook.react.ReactActivity;

public class MainActivity extends ReactActivity {


    static private Handler handler;


    /**
     * 官方建议的静态内部类
     */
    private final Handler mainHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {

            Log.i("你啊妈妈 ", "-------------" + message.what);
            Log.i("你啊妈妈：mainHandler",Thread.currentThread().getName());//这里打印的会是handler thread
            return true;
        }
    });




    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "sometooldome";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        /**
         * 创建一个线程
         */
        HandlerThread ht = new HandlerThread("ProcessingFilterImage");
        ht.start();


        handler = new Handler(ht.getLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                Log.i("你啊妈妈：handler",Thread.currentThread().getName());//这里打印的会是handler thread


                /**
                 * 由简单到复杂依次使用，arg1， setData(), obj。会比较好一些。
                 */
//                Message msg = mainHandler.obtainMessage();
//                msg.what = 1;            //消息标识
//                msg.arg1=2;              //存放整形数据，如果携带数据简单，优先使用arg1和arg2，比Bundle更节省内存。
//                msg.arg2=3;              //存放整形数据
//                Bundle bundle=new Bundle();
//                bundle.putString("dd","adfasd");
//                bundle.putInt("love",5);
//                msg.setData(bundle);
//                msg.obj=bundle;          //用来存放Object类型的任意对象
//                mainHandler.sendMessage(msg); //发送消息

                mainHandler.sendEmptyMessage(0);
            }
        });


    }
}
