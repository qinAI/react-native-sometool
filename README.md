
# react-native-sometool


## Getting started

`$ npm install react-native-sometool --save`

### Mostly automatic installation

`$ react-native link react-native-sometool`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sometool` and add `RNSometool.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSometool.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.lifenglin.sometool.RNSometoolPackage;` to the imports at the top of the file
  - Add `new RNSometoolPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-sometool'
  	project(':react-native-sometool').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-sometool/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-sometool')
  	```


## Usage
```javascript
import RNSometool from 'react-native-sometool';

// TODO: What to do with the module?
RNSometool;
```
  
