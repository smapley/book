#ShadowsocksR服务搭建
##1、购买服务器
> 
在[vultr](https://my.vultr.com/)购买一台`VPS`(Virtual Private Server 虚拟专用服务器)
支持**Alipay**

**配置**
|||
|:--:|:--:|
|Charges|CPU|RAM|Storage|Bandwidth|System|
|$5/mon|1vCore|1024MB|25 GB SSD|1000GB|CentOS 6|

##2、登录服务器
> [xShell](https://www.baidu.com/s?ie=UTF-8&wd=xshell)

##3、安装`shadowsocksR`
###1. CentOS 6 (适配CentOS 7有问题)
    yum -y install wget
    wget -N --no-check-certificate https://softs.fun/Bash/ssr.sh && chmod +x ssr.sh && bash ssr.sh
##4、配置`shadowsocksR`
    IP         : 140.82.5.110
    端口       : 22222
    密码       : ericssrnts
    加密       : aes-256-cfb
    协议       : auth_sha1_v4
    混淆       : tls1.2_ticket_auth
    设备数限制 : 6
    单线程限速 : 0 KB/S
    端口总限速 : 0 KB/S
##5、锐速加速器
###1. 更换内核（完成后会重启）
    wget --no-check-certificate https://blog.asuhu.com/sh/ruisu.sh
    bash ruisu.sh
###2. 安装锐速
    wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh install
###3.检查是否启用
    lsmod |grep appex
##6、客户端
* [Windows](https://github.com/shadowsocksr-backup/shadowsocksr-csharp/releases)
* [Mac](https://github.com/shadowsocksr-backup/ShadowsocksX-NG/releases)
* [Android](https://github.com/shadowsocksr-backup/shadowsocksr-android/releases)
* ISO
    Potatso Lite、Potatso、shadowrocket都可以作为SSR客户端，但这些软件目前已经在国内的app商店下架，请用美区的appid账号来下载，网络上有申请国外appid的教程或者淘宝购买

**参考链接**
[自建SS服务器教程](https://www.cnblogs.com/yjiu1990/p/7771429.html)
[锐速安装](http://www.vpsdx.com/2812.html)
