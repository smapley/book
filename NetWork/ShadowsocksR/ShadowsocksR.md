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
