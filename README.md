# 笔记_fastbuild

[TOC]

<br/>

## 1 基本介绍  
### 1.1 fastbuild介绍  
#### 1.1.1 作用  
FastBuild 是一个针对 Windows、 Linux 和 OS x 的高性能、开源的构建系统，它支持高度可伸缩的编译、缓存和网络分布。  
就是分布式编译，也叫联合编译，加快编译速度的。  
原本一个项目只能用自己机器上的核来编，但太慢了，尤其是大型项目，有时候一不小心点个rebuild就，，，就可以点杯奶茶喝到下班了。  
联合编译可以让你用其它机器上的核来编，理论上贡献出来的核越多，编得应该就越快。  
c++在windows上用得比较多的联编工具主要是IncrediBuild、FastBuild，在linux上一般是用distcc、icecream。  

#### 1.1.2 优势  
* 开源  
划重点，**不用花钱**。  
如果是有钱的老板，建议直接买IncrediBuild来用。没这么麻烦，直接安上，配置一个调度机ip就能用，而且最牛的是和VS无缝对接。  
* 可以通过缓存和网络分发来加快构建的过程。  

### 1.2 工作原理  
需要编译项目的机器暂且叫**主机**，能贡献出来用的机器叫**工作机**。  
主机用命令 fbuild.exe fbuild.bff -dist 启动编译，工作机要启动 FBuildWorker.exe。  
在fbuild.bff中描述了这个c++项目的编译过程，也就是指定编译器路径、链接器路径、包含目录、库目录、源代码目录、编译参数等等一些编译必要的信息，和CMakeLists.txt有点类似。  
工作机通过写入一个令牌到一个共享文件夹来表示它们可以贡献出来给别人用，主机通过检查这个文件夹里的令牌来找到可用的工作机，然后Fastbuild会将主机上的编译器工具链同步到工作机上，再接着把可以给工作机编译的源文件发过去，工作机把源文件编译成obj再发回给主机。  

### 1.3 版本配置和项目环境  
我用的win7的64位电脑，VS2013，lib库和dll都有，要编的项目是需要生成32位的exe，fastbuild是v1.00版本。  
我们项目组windows下联编原本用的是IncrediBuild 5.0，但这个版本只能在win7上用，而且会和windows一些自动更新的补丁冲突导致不能联编。用win10又用不了IncrediBuild，得花钱，最后能联编的win7电脑起来越少，就只能去搞fastbuild。  
很奇怪在网上搜到的资料很少，官网资料反而是最有用的，按理说这种能加快编译速度的东西应该有挺多人用的，难道都是用的IncrediBuild吗？  
还好之前项目组里有个大佬搞了个半成品，在他的基础上改出来的。  

<br/>

## 2 文件脚本  
[https://github.com/sbfhy/note_fastbuild](https://github.com/sbfhy/note_fastbuild)  

<br />

## 3 具体实现步骤  
### 3.1   
* 下载解压  
[FASTBuild-Windows-x64-v1.00.zip](https://www.fastbuild.org/downloads/v1.00/FASTBuild-Windows-x64-v1.00.zip)  
* 在一台机器上设置一个共享文件夹，权限设置为所有人能自由读写。  
* 添加环境变量，FASTBUILD_BROKERAGE_PATH设为共享文件夹路径。  
* 关掉防火墙  

### 3.2 工作机上操作  
* 启动FBuildWorker.exe  
设置了环境变量可以直接启动。  
也可以把start_fbuild_worker.bat脚本放到FBuildWorker.exe目录下，修改里面指向的共享文件夹路径，执行。  

### 3.3 主机上操作  
* 添加系统变量  
系统变量，在Path后面添加FBuild.exe的路径 D:\software\FastBuild\FASTBuild-Windows-x64-v1.00;  
* 修改template1.bff  
修改template1.bff里面VS的安装位置，WindowsSDK位置，编译器和链接器位置，编译选项，64位和32位的选择。  
* 生成.bff文件  
修改buildvcxproj.bat里的.vcxproj路径，执行。  
会用vcxproj2bff.exe按照template1.bff里的规则，去读取VS的.vcxproj配置文件，生成对应的.bff文件。  
这个vcxproj2bff.exe是之前组里大佬搞出来的程序，没有留下源码，这个没办法，可能生成出来的.bff会有些小问题，自己手改一下。  
其实就是像解xml文件一样去解.vcxproj，取出包含目录、库目录、源代码目录、编译选项，然后按.bff的语法规则生成，这个如果有时间可以自己手撸个脚本也是一样的。  
* 启动分布式编译  
修改fbuild.bat里的.bff路径，执行。  
脚本fbuild_start2.bat，也是启动用的，可以实现在窗口显示日志，并同时打出日志到文件中，看个人需求改吧，在需要看日志的时候可以用到。不过要下载一个[tee.exe](http://bbs.bathome.net/s/tool/index.html?key=tee)，放到C:\Windows\System32目录下。  

<br />

## 4 遇到的问题   
### 4.1 mspdb120.dll丢失，无法加载 mspdbst.dll (错误代码: 193)
https://www.azdll.net/files/mspdb120-dll	下载  
注意版本问题，32位复制到C\Windows\System32，64位复制到C\Windows\SysWOW64。  
打开“开始-运行-输入regsvr32 mspdb120.dll。  
打开“开始-运行-输入regsvr32 mspdbst.dll。  
120是VS2013用的，其它版本不是这个，看具体报错具体解决吧。  

### 4.2 x86和x64问题  
我用的amd64_x86，编译器cl.exe、链接器link.exe、库生成器lib.exe都要改成相对应的路径。  
fatal error LNK1112: 模块计算机类型“X86”与目标计算机类型“x64”冲突:  
这种问题大概率是用的lib库和dll库在生成时的位数不对，要和你项目生成的位数对应，就是链接器选项和库生成器选项中的' /MACHINE:X86'，意思是指定目标计算机。  

### 4.3 #ifdef WIN32 没用  
要加编译选项，' /D "WIN32"'  
__DEBUG，release也是类似  

### 4.4 包含目录问题，error LNK2019: 无法解析的外部符号  
* 要和源文件里需要的头文件对应上  
比如有个头文件路径是 D\project\a\b\c.h ，  
如果在源文件里是 #include "c.h" ，那包含目录就要加上D\project\a\b ；  
如果在源文件里是 #include "b\c.h" ，那包含目录就要加上D\project\a ；  
* 一个.bff里，包含目录下不能有相同名字的头文件  
比如有两个源文件 D\project\a\c.cpp, D\project\b\c.cpp, 代码里都是 #include "c.h"， 然后包含目录里加了两个目录 D\project\a, D\project\b，里面都有一个c.h。  
这种情况有一个头文件是匹配不到的，估计是匹配第一个目录。  

### 4.5 编出来的.obj太大了。  
生成出来的.obj文件大小是正常的5倍多，因为加了 ' /Z7' 参数，加了调试信息, 生成包含用于调试器的完整符号调试信息的.obj文件，不生成任何 .pdb 文件。  

### 4.6 编译器把警告或者不安全的用法当成错误停止编译  
加上 ' /D "_SCL_SECURE_NO_WARNINGS"' 编译参数忽略掉  

### 4.7 error LNK2038: 检测到“RuntimeLibrary”的不匹配项:  值“MDd_DynamicDebug”不匹配值“MTd_StaticDebug”  
工程的运行库设置不一样，加上一样的编译参数就好了，多线程(/MT)、多线程调试(/MTd)、多线程DLL(/MD)、多线程调试DLL(/MDd)、单线程(/ML)、单线程调试(/MLd)  

### 4.8 error C2664: “CWnd::MessageBoxW”: 不能将参数 1 从“const char [17]”转换为“LPCTSTR”  
把“字符集”改为“使用多字节字符集”，也就是不要加编译参数 /D "UNICODE"。  

### 4.9 无法连接上工作机  
* 工作机的核可能都在忙，或者模式没设置好，要显示Idle才表示可以贡献出来用：
![](https://www.fastbuild.org/docs/img/worker_available.png)  
* 可能是共享文件夹权限不能自由读写，可以在共享文件夹创建文件试一下；  
* 环境变量没设置好；  
* 防火墙没关或网络问题；  
* 主机在启动编译时没有加 -dist 或 -distverbose 参数；  
主机编译的日志里可以在开头看到在找工作机的日志：  
3 workers found in '\\192.168.2.201\myshare_fastbuild\main\20.windows\'  
Distributed Compilation : 2 Workers in pool '\\192.168.2.201\myshare_fastbuild\main\20.windows\'  
* 工作机端口31264，可能被占用了，杀掉占用的进程；  

可以通过cmd，输入命令netstat -an |findstr 31264，查看socket连接。  
正常连接上了，在界面上也是会有Connections提示的：  
![](https://www.fastbuild.org/docs/img/worker_connection.png)  

### 4.10 连接上了工作机，但不能用工作机的核来编  
编译器的环境没有同步过去，环境包括编译器和需要的dll，需要的dll一般都在cl.exe的同级目录下。  
参考 https://www.fastbuild.org/docs/functions/compiler.html  
对于MSVC编译器：   
　　/ZW 选项不能使用  
　　预编译头文件不能被分发，他们是因机器而异的。（使用了PCH的对象可以被分发）  
　　/clr 选项不能使用，因为微软编译器的预处理器有bug。  
如果连接上了工作机编译，会打出 REMOTE 日志：  
Obj: C:\Test\tmp\x86-Profile\TestFramework\Unity1.obj <REMOTE: 192.168.0.8\>  

### 4.11 用fbuild 编译完，想在VS里进行调试，但是点了F5后，VS会再次编译项目  
这是因为bff配置没有和vs配置完全一样导致的，可以选择attch调试。  

### 4.12 std::max 无法和宏定义区分  
	(std::max)，
	(std::numeric_limits<UINT32>::max) error C2589: “(”:“::”右边的非法标记
	error C2440: “<function-style-cast>”: 无法从“overloaded-function”转换为“UINT32” 上下文不允许消除重载函数的歧义

### 4.13 VS的一些宏要修改，依赖库要添加  

<br />

## 5 扩展  
### 5.1 FASTBuildMonitor  
下载 [fastbuild monitor](https://github.com/yass007/FASTBuildMonitor)，VS编译可视化插件，这个挺有用的，可以看到在主机的VS上看到其它工作机的编译进度情况。  
![报错](https://ae01.alicdn.com/kf/H5b84b0001a7e41b99aef4f72db6fec3ca.jpg)  
查看这个xml最后的报错，缺少了一个VS2015的dll：  
```
<entry>
    <record>911</record>
    <time>2020/05/26 13:50:22.457</time>
    <type>Error</type>
    <source>VisualStudio</source>
    <description>End package load [FASTBuildMonitorPackage]</description>
    <guid>{73DE7C44-188B-45D3-AAB2-19AF8724C5C9}</guid>
    <hr>80004005 - E_FAIL</hr>
    <errorinfo>未能加载文件或程序集“Microsoft.VisualStudio.Shell.14.0, Version=14.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a”或它的某一个依赖项。系统找不到指定的文件。</errorinfo>
  </entry>
```
装个VS2015就有用了。。。  


### 5.2 命令行参数  
参考 https://www.fastbuild.org/docs/options.html  
#### 5.2.1 fbuild.exe 
-dist : 		开启分布式编译  
-cache : 		使用构建缓存  
-config file.bff : 		指定使用的bff文件，如果不用这个参数，就默认是同目录下的fbuild.bff  
-j2 : 			限制本地只用2个核，没那么卡  
-monitor : 		输出一个机器可读的文件，供第三方工具使用，FASTBuildMonitor就要加这个  
-clean : 		清理  
-debug : 		允许在启动时立即附加调试器(仅限windows)  
-nostoponerror ： 出错不要停止构建  

#### 5.2.2 FBuildWorker.exe  
-console : 		控制台模式启动，并且隐藏了窗口，启动后只在任务管理器中才能被看到(仅限windows)  
-cpus=[n|-n|n%] : 	分配工作的cpu  
-mode=[disabled|idle|dedicated|proportional] : 	设置启动后模式  

<br />

## 6 参考资料  
https://www.fastbuild.org/docs/documentation.html		官方文档，必看  
https://github.com/fastbuild/fastbuild 					github源代码  
https://www.cnblogs.com/tangxin-blog/p/8635438.html		初识FASTBuild 一个大幅提升C/C++项目编译速度的分布式编译工具  
https://www.cnblogs.com/tangxin-blog/p/8653715.html		在FASTBuild中使用Distribution  
https://github.com/yass007/FASTBuildMonitor 			fastbuild monitor  
https://www.bilibili.com/video/av70564103/				B站视频，UE4#C++#20-FastBuild编译环境  
https://github.com/hillin/FASTBuild-Dashboard			面板，就是好看一点  
https://github.com/LendyZhang/msfastbuild 				Utility to build Visual Studio solutions and projects with FASTBuild, supports VS2015/2017/2019.  
https://www.cnblogs.com/Shaojunping/p/11941712.html 	fastbuild联编ue4 shader的使用  
https://lab.uwa4d.com/lab/5b85620802004fb65975b1f1		允许使用VS2015／VS2017和Windows 10下的FASTBuild构建虚幻引擎  

