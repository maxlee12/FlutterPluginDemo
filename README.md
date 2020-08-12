# FlutterPluginDemo
如何在 Flutter pugin 中使用Framework
最近做的一个flutter项目中，需要使用到科大讯飞的AIUI 语音唤醒和语音识别等功能。由于 [dart-pub](https://dart-pub.mirrors.sjtug.sjtu.edu.cn)上目前没有现成的package供我们使用，因此需要我们自己动手创建一个flutter plugin。
下面将介绍一下Flutter plugin的创建使用步骤。

整个过程分为以下几个步骤：
准备好科大讯飞iOS 和 Android 的示例代码。在原生iOS 和 Android平台能正常运行
创建一个flutter Plugin
对插件进行iOS 平台编码，测试
对插件进行Android 平台编码，测试
将插件集成到项目中，测试
测试好的插件进行打包

一、准备需要集成的原生程序
这个步骤不需要多说，插件的功能不同，需要的程序来源不同。对于我这个示例项目，是在[科大讯飞的平台](https://console.xfyun.cn/app/myapp)上，创建好项目，选择需要接入的服务，然后下载好官方给的对应的example。
下载好example后，需要在原生平台上测试通过

二、创建flutter plugin
创建插件有两种方式，一是使用Android studio 创建；二是 使用命令行创建。
1、使用Android studio创建可能由于用户的偏好设置不同，创建的项目可能不包含iOS Android 所有平台。比如我创建的项目不含Android
打开Android studio
选择start a new Flutter project
在弹出的Creat NewFlutter Project窗口中选择Flutter plugin，点击next
填入需要创建的项目的 project name Project location Description等信息，点击next
填入需要创建的项目的 Company domain Platform channel language 等信息，点击Finish
等待plugin创建完成。创建好的plugin 初始文件夹如下图所示
![截图截图](https://github.com/maxlee12/FlutterPluginDemo/master/Screenshots/iOS/photo2.png)

2、使用命令行创建Flutter plugin。[官方指导文档地址](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
打开命令行，进入需要创建的文件夹地址
输入命令：flutter create --template=plugin --platforms=android,ios -i objc flutter_plugin
等待创建完成。创建好的目录如下图所示
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)

三、对iOS 平台编码测试
1、添加插件需要的资源图片文件以及framework
打开插件项目目录下的iOS 文件夹，创建Resources文件夹和Libs 文件夹
将项目需要的framework文件放入Libs文件夹下
将项目需要的资源文件放入Resources 文件夹下
2、修改iOS 文件夹下的.podspec文件，原生需要的framework和资源文件加入pod管理中
打开.podspec文件，按照[podspec的格式要求](https://guides.cocoapods.org/syntax/podspec.html)修改文件
frameworks中加入需要的系统framework
libraries中加入需要的tbd文件
preserve_paths中写入自定义Lib文件路径
vendored_frameworks中写入自定文件路径
resources中写入资源文件路径
科大讯飞需要的framework如下图所示：
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)
修改好的文件如下图所示：
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)
3、开始写iOS 代码
podspec文件配置好，iOS端插件的依赖就准备好了，下面可以开始写业务代码了
打开iOS目录下的example文件夹，使用 命令行执行pod install，完成后，打开.xcworkspace文件
在example中配置需要的语音权限，plist中加入 Privacy - Microphone Usage Description
在example -iOS-Classes 文件加下加入业务代码，提供接口给iOS Class FlutterPlugin
在example -iOS-Classes FlutterPlugin 文件中调用业务代码，提供接口给Flutter 插件 。本示例采用EventChannel 和 MethodChannel的方式
在iOS目录下，打开lib-flutter_plugin，在该dart文件中，使用channel调用iOS业务代码，提供接口给Flutter工程
在example中，调用写好的插件，debug调试、验证程序
iOS端plugin完成
Classes文件下加入的业务代码截图：
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)

iOS FlutterPlugin 中调用业务代码截图：(注意channel method和channel event的使用方法)
本示例中plugin 使用channel method 来调用原生方法，使用channel event回调原生的处理结果
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)

Dart flutter_plugin 中使用channel method和 channel event调用原生方法，同时提供接口给flutter工程使用
截图如下：
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)

在example中，调用写好的插件。打开example中lib下的main.dart，开始调用插件。
截图如下：
![截图截图](https://github.com/chenyufeng1991/NewsClient/raw/master/Screenshots/2.png)


4、iOS端示例代码地址：
地址包含完整的plugin文件 和 科大讯飞的示例唤醒iOS Android demo

四、对Android 平台编码测试
未完待续
