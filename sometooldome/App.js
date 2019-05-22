/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, View, Button,NativeModules,SafeAreaView,Image,Dimensions,PermissionsAndroid} from 'react-native';


const RNSometool = NativeModules.RNSometool;

var window = Dimensions.get('window');

type Props = {};
export default class App extends Component<Props> {


    constructor(props) {
        super(props);
        this.state = {imageURl:""};
    }

    /**
     * 华为9.0以后必须手动申请权限 才能读写
     * @returns {Promise<void>}
     */
    requestPermission = async () => {
        try {
            const granted = await PermissionsAndroid.request(
                PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
                {
                    title: '申请读写手机存储权限',
                    message:
                    '一个很牛逼的应用想借用你的摄像头，' +
                    '然后你就可以拍出酷炫的皂片啦。',
                    buttonNeutral: '等会再问我',
                    buttonNegative: '不行',
                    buttonPositive: '好吧',
                },
            );
            if (granted === PermissionsAndroid.RESULTS.GRANTED) {
                console.log('现在你获得摄像头权限了');
            } else {
                console.log('用户并不给你');
            }
        } catch (err) {
            console.warn(err);
        }
    };



    componentDidMount() {
        this.requestPermission();
    }



    _openImageAlbum = (index) => {
        if (index === 1){
            // 打开图像选择  maxSelectNum 最大选择张数  1和9
            RNSometool.showPictureSelector((state,list) => {
                console.log('----多选9张',state,list);

                if (state === 200){
                    let path = list[0].path;

                    this.setState({
                        imageURl:path
                    })
                }

            })

        } else if (index === 2){
            // 打开相机拍照
            RNSometool.showCameraTakePicture((state,list) => {
                console.log('----拍照',state,list);
                if (state === 200){
                    let path = list[0].path;


                    this.setState({
                        imageURl:path
                    })
                }
            })

        } else if (index === 3){
            // 打开视频选择 单选true  false 多选
            RNSometool.showVideosSelectorType(false ,(state,list) => {

                console.log('----选视频',state,list);
            })

        } else if (index === 4){
            // 打开相机录制 单个录制
            RNSometool.showCameraTakeVideo((state,list) => {
                console.log('----录制视频',state,list);
            })
        } else if (index === 5){
            // 单选正方形裁剪
            RNSometool.showSingleCrop((state,list) => {

                console.log('----单选方形裁剪',state,list);
                if (state === 200){
                    let path = list[0].cutPath;

                    this.setState({
                        imageURl:path
                    })
                }
            })

        } else if(index === 6){

            let imagePath = this.state.imageURl;
            RNSometool.showCropFilterImageVc(imagePath,0,(state,map)=>{
                console.log('裁剪-----------',map);
                if (state === 200){
                    this.setState({imageURl:map.path});
                }

            });

        } else if(index === 7){

            let imagePath = this.state.imageURl;
            RNSometool.showCropFilterImageVc(imagePath,1,(state,map)=>{
                console.log('滤镜-----------',map);
                if (state === 200){
                    this.setState({imageURl:map.path});
                }
            });

        } else if(index === 8){

            let imagePath = this.state.imageURl;

            /**
             * 由于安卓的.9图像缩放和iOS的缩放机制不同
             * 从而使用缩放逻辑导致缩放效果添加的相框差别太大
             *
             * 只有采用限定图像最大宽高,按照物理缩放添加相框
             * 目前没有更好的解决方案
             *
             * 裁剪和滤镜不采取限定最大宽高的处理,并不影响功能和显示效果
             *
             */
            RNSometool.showPhotoFrameImageVc(imagePath,800,(state,map)=>{
                console.log('相框-----------',map);
                if (state === 200){
                    this.setState({imageURl:map.path});
                }
            });
        } else if (index === 10) {

        }

    }



  render() {
    return (
      <View style={styles.container}>
          <SafeAreaView>
              <Button onPress={() => this._openImageAlbum(1)} title='多选图片'/>
              <Button onPress={() => this._openImageAlbum(2)} title='拍照'/>
              <Button onPress={() => this._openImageAlbum(3)} title='选视频'/>
              <Button onPress={() => this._openImageAlbum(4)} title='录制视频'/>
              <Button onPress={() => this._openImageAlbum(5)} title='单选裁剪'/>
              <Button onPress={() => this._openImageAlbum(6)} title='裁剪'/>
              <Button onPress={() => this._openImageAlbum(7)} title='滤镜'/>
              <Button onPress={() => this._openImageAlbum(8)} title='相框'/>

              <Image style={{ width : window.width * 0.5, height:window.height * 0.5,backgroundColor:"#ff0"}}
                     source={{uri:this.state.imageURl}}
                     resizeMode={'contain'}/>
          </SafeAreaView>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5FCFF',
  },

});
