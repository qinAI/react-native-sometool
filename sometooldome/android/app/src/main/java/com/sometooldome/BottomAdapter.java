package com.sometooldome;

import android.graphics.Bitmap;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class BottomAdapter extends RecyclerView.Adapter<BottomAdapter.ViewHolder> {


    private SparseArray<Bitmap> images;
    private SparseArray<String> titles;

    private OnItemClickedListener mOnItemClickedListener;


    public void setTitles(SparseArray<String> titles) {
        this.titles = titles;
    }

    public void setImages(SparseArray<Bitmap> images) {
        this.images = images;
    }

    /**
     * 定义一个接口
     */
    public interface OnItemClickedListener {
        void onClicked(View view, int position);
    }


    /**
     * 赋值点击监听
     * @param onItemClickedListener
     */
    public void setOnItemClickedListener(OnItemClickedListener onItemClickedListener) {
        mOnItemClickedListener = onItemClickedListener;
    }


    /**
     * 外部调用
     *
     * @param holder
     * @param position
     */
    private void handleViewClicked(ViewHolder holder, final int position) {
        holder.containerRl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickedListener != null) {
                    mOnItemClickedListener.onClicked(v, position);
                }
            }
        });
    }




    /**
     * 实现三个方法
     * @return
     */
    @Override
    public int getItemCount() {
        return titles == null ? 0 : titles.size();
    }

    /**
     * 设置数据
     * @param holder
     * @param position
     */
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, final int position) {

        String title = titles.valueAt(position);
        Bitmap bm = images.valueAt(position);

        holder.beautyRvItemTv.setText(title);
        holder.imageView.setImageBitmap(bm);

        handleViewClicked(holder,position);

//        holder.containerRl.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                Log.i("曹尼玛","打印事件---"+position);
//            }
//        });
    }

    /**
     * 返回布局cell
     * @param parent
     * @param viewType
     * @return
     */
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.rv_itme,parent,false);
        return new ViewHolder(v);
    }




    /**
     * 创建一个类
     */
    class ViewHolder extends RecyclerView.ViewHolder {
        TextView beautyRvItemTv;
        ImageView imageView;
        RelativeLayout containerRl;

        ViewHolder(View view) {
            super(view);
            beautyRvItemTv = view.findViewById(R.id.tv);
            imageView = view.findViewById(R.id.img);
            containerRl = view.findViewById(R.id.container);
        }
    }
}
