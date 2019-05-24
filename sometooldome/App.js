/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, View, Button,NativeModules,SafeAreaView,Image,Dimensions,PermissionsAndroid,Text} from 'react-native';


const RNSometool = NativeModules.RNSometool;


import Video from 'react-native-af-video-player'


var window = Dimensions.get('window');

type Props = {};
export default class App extends Component<Props> {






    constructor(props) {
        super(props);
        this.state = {imageURl:"",videoURl:""};
    }





    componentWillUnmount() {
        // 请注意Un"m"ount的m是小写

        // 如果存在this.timer，则使用clearTimeout清空。
        // 如果你使用多个timer，那么用多个变量，或者用个数组来保存引用，然后逐个clear
        this.timer && clearTimeout(this.timer);
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

                if (state === 200){
                    let path = list[0].path;

                    this.setState({
                        videoURl:path
                    });

                    // RNSometool.showVideoPlayer(path);






                    let videoWidth = list[0].width;
                    if (videoWidth > 720){

                        const options = {
                            width: 720,
                            height: 1280,
                            bitrateMultiplier: 3,
                            saveToCameraRoll: false, // default is false, iOS only
                            saveWithCurrentDate: false, // default is false, iOS only
                            minimumBitrate: 300000,
                            removeAudio: false, // default is false
                        };


                        if (Platform.OS === 'android') {
                            // 安卓调用
                            RNSometool.videoTrimmerCompress(path,options).then((data) =>{
                                    if (data.source !== undefined){
                                        this.setState({videoURl:data.source});
                                    }
                                    console.log('videoTrimmerCompress---------',data.source)
                                }
                            );
                        }else {
                            //iOS调用
                            RNSometool.videoTrimmerCompress(path,options,(data,url)=>{

                                if (url !== undefined){
                                    this.setState({videoURl:url});
                                }

                                console.log('videoTrimmerCompress---------',data,url);
                            });
                        }
                    }
                }
            })

        } else if (index === 4){
            // 打开相机录制 单个录制
            RNSometool.showCameraTakeVideo((state,list) => {
                console.log('----录制视频',state,list);

                if (state === 200){
                    let path = list[0].path;

                    this.setState({
                        videoURl:path
                    });

                    // RNSometool.showVideoPlayer(path);
                }

            })
        } else if (index === 5){
            // 单选正方形裁剪
            RNSometool.showSingleCrop((state,list) => {

                console.log('----单选方形裁剪',state,list);
                if (state === 200){
                    let path = list[0].cutPath;

                    this.setState({
                        imageURl:path
                    });


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


    // onBuffer = (data) => {
    //     console.log('onBuffer:',data);
    // }
    //
    // videoError = (err) => {
    //     console.log('videoError:',err);
    // }
    //
    // onLoad = (data) => {
    //     console.log('onLoad:',data);
    //     // this.setState({ duration: data.duration });
    // };
    //
    // onProgress = (data) => {
    //     console.log('onProgress:',data);
    //     // this.setState({ currentTime: data.currentTime });
    // };
    //
    // onEnd = () => {
    //     console.log('onEnd:');
    //     this.setState({ paused: true })
    //     this.video.seek(0)
    // };
    //
    // onAudioBecomingNoisy = () => {
    //     console.log('onAudioBecomingNoisy:');
    //     // this.setState({ paused: true })
    // };
    //
    // onAudioFocusChanged = (event: { hasAudioFocus: boolean }) => {
    //     console.log('onAudioFocusChangedhasAudioFocus:',event.hasAudioFocus);
    //     // this.setState({ paused: !event.hasAudioFocus })
    // };


    // play = () => {
    //     this.video.play()
    //     this.video.seekTo(0)
    // }
    //
    // pause = () => {
    //     this.video.pause()
    // }



    onMorePress() {
        console.log('onMorePress');
        RNSometool.showVideoPlayer(this.state.videoURl);
    }



    onFullScreen(status) {
        console.log('onFullScreen : ',status);
    }


  render() {

      // const url = 'file:///storage/emulated/0/DCIM/Camera/dc1a217ff7ebf86277b9c3dbcac5ab10.mp4'
      const logo = 'https://your-url.com/logo.png'
      // const placeholder = 'https://your-url.com/placeholder.png'
      const title = 'video title';


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

              <View style={{ width : window.width, height: window.height * 0.5, flexDirection:'row'}}>

                  <Image style={styles.bottomImageStyle}
                         source={{uri:this.state.imageURl}}
                         resizeMode={'contain'}/>


                  {
                      this.state.videoURl.length > 0
                      ? (<Video style={styles.bottomVideoStyle}
                                resizeMode={'contain'}
                                url={this.state.videoURl}
                                autoPlay
                                loop={true}          //自动循环播放
                                inlineOnly={true}    //隐藏全屏按钮 本控件的全屏模式不太好 全屏模式最好手动吧
                                ref={(ref) => { this.video = ref }}
                                title={title}
                                logo={logo}
                                onMorePress={() => this.onMorePress()}/>
                          )
                      : (<Text style={styles.bottomVideoStyle}>视频地址为空iOS会闪退哦</Text>)
                  }

              </View>

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

    bottomImageStyle:{
        width : window.width * 0.5,
        height: window.height * 0.5,
        backgroundColor:"#ff0"
    },
    bottomVideoStyle: {
        width : window.width * 0.5,
        height: window.height * 0.5,
        backgroundColor:"#0ff"
    }

});
