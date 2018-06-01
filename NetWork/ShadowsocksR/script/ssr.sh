#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

abstract="
#################################################
# System Required: CentOS7                      #
# Description: Install the ShadowsocksR server  #
# Version: 1.0.0                                #
# Author: Smapley                               #
#################################################"

ssr_port="22222"
ssr_password="ericssrnts"
ssr_method="aes-256-cfb"
ssr_protocol="auth_sha1_v4"
ssr_obfs="tls1.2_ticket_auth"
ssr_protocol_param="6"
ssr_speed_limit_per_con=0
ssr_speed_limit_per_user=0

config_folder="/etc/shadowsocksr"
config_user_file="${config_folder}/user-config.json"

ssr_name="shadowsocksr-3.2.2"
ssr_folder="/usr/local/shadowsocksr/"
ssr_url="https://github.com/smapley/shadowsocksr/archive/3.2.2.tar.gz"

jq_name="jq"
jq_file="${ssr_folder}${jq_name}"
jq_32_url="https://github.com/smapley/shadowsocks_install/raw/master/jq-linux32"
jq_64_url="https://github.com/smapley/shadowsocks_install/raw/master/jq-linux64"

ssr_manager_name="ssr"
ssr_manager_file="/etc/init.d/${ssr_manager_name}"
ssr_manager_centos_url="https://raw.githubusercontent.com/smapley/shadowsocks_install/master/ssr_centos"
ssr_manager_debian_url="https://raw.githubusercontent.com/smapley/shadowsocks_install/master/ssr_debian"

ssr_ss_file="${ssr_folder}/shadowsocks"
ssr_log_file="${ssr_ss_file}/ssserver.log"

ssr_menus=(
安装ShadowsocksR
启动ShadowsocksR
停止ShadowsocksR
重启ShadowsocksR
卸载ShadowsocksR
修改配置信息
查看连接信息
查看连接用户
查看运行日志
修改配置文件
切换端口模式
)
ssr_moehods=(
none
rc4
rc4-md5
rc4-md5-6
aes-128-ctr
aes-192-ctr
aes-256-ctr
aes-128-cfb
aes-192-cfb
aes-256-cfb
aes-128-cfb8
aes-192-cfb8
aes-256-cfb8
salsa20
chacha20
chacha20-ietf
)
ssr_protocols=(
origin
auth_sha1_v4
auth_aes128_md5
auth_aes128_sha1
auth_chain_a
auth_chain_b
)
ssr_obfss=(
plain
http_simple
http_post
random_head
tls1.2_ticket_auth
)

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Line="——————————————————————————————"

check_sys(){
	cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
	[ ! $? -eq  0 ] &&  echo -e "${Error} 本脚本不支持当前系统 !" && exit 1
	bit=`uname -m`
}
check_role(){
	[[ $EUID -ne 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}
SSR_installation_status(){
	[[ ! -e ${config_user_file} ]] && echo -e "${Error} 没有发现 ShadowsocksR 配置文件，请检查 !" && exit 1
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有发现 ShadowsocksR 文件夹，请检查 !" && exit 1
}

# Disable selinux
disable_selinux(){
	if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		setenforce 0
	fi
}

show_menu(){
	cur_dir=`pwd`
	clear
	echo -e "${abstract}"
	for((i=1;i<=${#ssr_menus[@]};i++)); do
		echo -e "${Green_font_prefix}${i}.${Font_color_suffix} ${ssr_menus[$i-1]}"
		if [[ $((i%5)) == 0 ]]; then
			echo -e "-------------------"
		fi
	done
	if [[ -e ${config_user_file} ]]; then
		if [[ ! -z "${PID}" ]]; then
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
		now_mode=$(cat "${config_user_file}"|grep '"port_password"')
		if [[ -z "${now_mode}" ]]; then
			echo -e " 当前模式: ${Green_font_prefix}单端口${Font_color_suffix}"
		else
			echo -e " 当前模式: ${Green_font_prefix}多端口${Font_color_suffix}"
		fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}

# 设置 配置信息
Set_config_port(){
	while true
	do
	echo -e "请输入要设置的ShadowsocksR账号 端口"
	stty erase '^H' && read -p "(默认: ${ssr_port}):" ssr_port_in
	[[ ! -z "$ssr_port_in" ]] && ssr_port="${ssr_port_in}"
	expr ${ssr_port} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_port} -ge 1 ]] && [[ ${ssr_port} -le 65535 ]]; then
			echo && echo ${Line} && echo -e "	端口 : ${Green_font_prefix}${ssr_port}${Font_color_suffix}" && echo ${Line} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi
	done
}
Set_config_password(){
	echo "请输入要设置的ShadowsocksR账号 密码"
	stty erase '^H' && read -p "(默认: ${ssr_password}):" ssr_password_in
	[[ ! -z "${ssr_password_in}" ]] && ssr_password=${ssr_password_in}
	echo && echo ${Line} && echo -e "	密码 : ${Green_font_prefix}${ssr_password}${Font_color_suffix}" && echo ${Line} && echo
}
Set_config_method(){
	echo -e "请选择要设置的ShadowsocksR账号 加密方式:"
	for((i=1;i<=${#ssr_moehods[@]};i++)); do
		echo -e "${Green_font_prefix} ${i}.${Font_color_suffix} ${ssr_moehods[$i-1]}"
		if [[ $((i%3)) == 1 ]]; then
			echo -e "-------------------"
		fi
	done
	echo -e "${Tip} 如果使用 auth_chain_a 协议，请加密方式选择 none，混淆随意(建议 plain)
${Tip} salsa20/chacha20-*系列加密方式，需要额外安装依赖 libsodium ，否则会无法启动ShadowsocksR !" && echo
	stty erase '^H' && read -p "(默认: ${ssr_method}):" ssr_method_in
	[[ ! -z "${ssr_method_in}" ]] && ssr_method="${ssr_moehods[$ssr_method_in-1]}"
	echo && echo ${Line} && echo -e "	加密 : ${Green_font_prefix}${ssr_method}${Font_color_suffix}" && echo ${Line} && echo
}
Set_config_protocol(){
	echo -e "请选择要设置的ShadowsocksR账号 协议插件:"
	for((i=1;i<=${#ssr_protocols[@]};i++));do
		echo -e "${Green_font_prefix} ${i}.${Font_color_suffix} ${ssr_protocols[$i-1]}"
	done
	echo -e "${Tip} 如果使用 auth_chain_a 协议，请加密方式选择 none，混淆随意(建议 plain)" && echo
	stty erase '^H' && read -p "(默认: ${ssr_protocol}):" ssr_protocol_in
	[[ ! -z "${ssr_protocol_in}" ]] && ssr_protocol="${ssr_protocols[$ssr_protocol_in-1]}"
	echo && echo ${Line} && echo -e "	协议 : ${Green_font_prefix}${ssr_protocol}${Font_color_suffix}" && echo ${Line} && echo
	if [[ ${ssr_protocol} != "origin" ]]; then
		if [[ ${ssr_protocol} == "auth_sha1_v4" ]]; then
			stty erase '^H' && read -p "是否设置 协议插件兼容原版(_compatible)？[Y/n]" ssr_protocol_yn
			[[ -z "${ssr_protocol_yn}" ]] && ssr_protocol_yn="n"
			[[ $ssr_protocol_yn == [Yy] ]] && ssr_protocol=${ssr_protocol}"_compatible"
			echo
		fi
	fi
}
Set_config_obfs(){
	echo -e "请选择要设置的ShadowsocksR账号 混淆插件:"
	for((i=1;i<=${#ssr_obfss[@]};i++));do
		echo -e "${Green_font_prefix} ${i}.${Font_color_suffix} ${ssr_obfss[$i-1]}"
	done
	echo -e "${Tip} 如果使用 ShadowsocksR 加速游戏，请选择 混淆兼容原版或 plain 混淆，然后客户端选择 plain，否则会增加延迟 !" && echo
	stty erase '^H' && read -p "(默认: ${ssr_obfs}):" ssr_obfs_in
	[[ ! -z "${ssr_obfs}" ]] && ssr_obfs="${ssr_obfss[$ssr_obfs_in-1]}"
	echo && echo ${Line} && echo -e "	混淆 : ${Green_font_prefix}${ssr_obfs}${Font_color_suffix}" && echo ${Line} && echo
	if [[ ${ssr_obfs} != "plain" ]]; then
			stty erase '^H' && read -p "是否设置 混淆插件兼容原版(_compatible)？[Y/n]" ssr_obfs_yn
			[[ -z "${ssr_obfs_yn}" ]] && ssr_obfs_yn="n"
			[[ $ssr_obfs_yn == [Yy] ]] && ssr_obfs=${ssr_obfs}"_compatible"
			echo
	fi
}
Set_config_protocol_param(){
	while true
	do
	echo -e "请输入要设置的ShadowsocksR账号 欲限制的设备数 (${Green_font_prefix} auth_* 系列协议 不兼容原版才有效 ${Font_color_suffix})"
	echo -e "${Tip} 设备数限制：每个端口同一时间能链接的客户端数量(多端口模式，每个端口都是独立计算)，建议最少 2个。"
	stty erase '^H' && read -p "(默认: 无限):" ssr_protocol_param_in
	[[ -z "$ssr_protocol_param_in" ]] && ssr_protocol_param="" && echo && break
	ssr_protocol_param="${ssr_protocol_param_in}"
	expr ${ssr_protocol_param} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_protocol_param} -ge 1 ]] && [[ ${ssr_protocol_param} -le 9999 ]]; then
			echo && echo ${Line} && echo -e "	设备数限制 : ${Green_font_prefix}${ssr_protocol_param}${Font_color_suffix}" && echo ${Line} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-9999)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-9999)"
	fi
	done
}
Set_config_speed_limit_per_con(){
	while true
	do
	echo -e "请输入要设置的每个端口 单线程 限速上限(单位：KB/S)"
	echo -e "${Tip} 单线程限速：每个端口 单线程的限速上限，多线程即无效。"
	stty erase '^H' && read -p "(默认: 无限):" ssr_speed_limit_per_con_in
	[[ -z "$ssr_speed_limit_per_con_in" ]] && ssr_speed_limit_per_con=0 && echo && break
	ssr_speed_limit_per_con="${ssr_speed_limit_per_con_in}"
	expr ${ssr_speed_limit_per_con} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_con} -ge 1 ]] && [[ ${ssr_speed_limit_per_con} -le 131072 ]]; then
			echo && echo ${Line} && echo -e "	单线程限速 : ${Green_font_prefix}${ssr_speed_limit_per_con} KB/S${Font_color_suffix}" && echo ${Line} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-131072)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-131072)"
	fi
	done
}
Set_config_speed_limit_per_user(){
	while true
	do
	echo
	echo -e "请输入要设置的每个端口 总速度 限速上限(单位：KB/S)"
	echo -e "${Tip} 端口总限速：每个端口 总速度 限速上限，单个端口整体限速。"
	stty erase '^H' && read -p "(默认: 无限):" ssr_speed_limit_per_user_in
	[[ -z "$ssr_speed_limit_per_user_in" ]] && ssr_speed_limit_per_user=0 && echo && break
	ssr_speed_limit_per_user="${ssr_speed_limit_per_user_in}"
	expr ${ssr_speed_limit_per_user} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_user} -ge 1 ]] && [[ ${ssr_speed_limit_per_user} -le 131072 ]]; then
			echo && echo ${Line} && echo -e "	端口总限速 : ${Green_font_prefix}${ssr_speed_limit_per_user} KB/S${Font_color_suffix}" && echo ${Line} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-131072)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-131072)"
	fi
	done
}
Set_config_all(){
	Set_config_port
	Set_config_password
	Set_config_method
	Set_config_protocol
	Set_config_obfs
	Set_config_protocol_param
	Set_config_speed_limit_per_con
	Set_config_speed_limit_per_user
}
# 修改 配置信息
Modify_config_port(){
	sed -i 's/"server_port": '"$(echo ${port})"'/"server_port": '"$(echo ${ssr_port})"'/g' ${config_user_file}
}
Modify_config_password(){
	sed -i 's/"password": "'"$(echo ${password})"'"/"password": "'"$(echo ${ssr_password})"'"/g' ${config_user_file}
}
Modify_config_method(){
	sed -i 's/"method": "'"$(echo ${method})"'"/"method": "'"$(echo ${ssr_method})"'"/g' ${config_user_file}
}
Modify_config_protocol(){
	sed -i 's/"protocol": "'"$(echo ${protocol})"'"/"protocol": "'"$(echo ${ssr_protocol})"'"/g' ${config_user_file}
}
Modify_config_obfs(){
	sed -i 's/"obfs": "'"$(echo ${obfs})"'"/"obfs": "'"$(echo ${ssr_obfs})"'"/g' ${config_user_file}
}
Modify_config_protocol_param(){
	sed -i 's/"protocol_param": "'"$(echo ${protocol_param})"'"/"protocol_param": "'"$(echo ${ssr_protocol_param})"'"/g' ${config_user_file}
}
Modify_config_speed_limit_per_con(){
	sed -i 's/"speed_limit_per_con": '"$(echo ${speed_limit_per_con})"'/"speed_limit_per_con": '"$(echo ${ssr_speed_limit_per_con})"'/g' ${config_user_file}
}
Modify_config_speed_limit_per_user(){
	sed -i 's/"speed_limit_per_user": '"$(echo ${speed_limit_per_user})"'/"speed_limit_per_user": '"$(echo ${ssr_speed_limit_per_user})"'/g' ${config_user_file}
}
Modify_config_connect_verbose_info(){
	sed -i 's/"connect_verbose_info": '"$(echo ${connect_verbose_info})"'/"connect_verbose_info": '"$(echo ${ssr_connect_verbose_info})"'/g' ${config_user_file}
}
Modify_config_all(){
	Modify_config_port
	Modify_config_password
	Modify_config_method
	Modify_config_protocol
	Modify_config_obfs
	Modify_config_protocol_param
	Modify_config_speed_limit_per_con
	Modify_config_speed_limit_per_user
}
Modify_config_port_many(){
	sed -i 's/"'"$(echo ${port})"'":/"'"$(echo ${ssr_port})"'":/g' ${config_user_file}
}
Modify_config_password_many(){
	sed -i 's/"'"$(echo ${password})"'"/"'"$(echo ${ssr_password})"'"/g' ${config_user_file}
}

# 显示 多端口用户配置
List_multi_port_user(){
	user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
	[[ ${user_total} = "0" ]] && echo -e "${Error} 没有发现 多端口用户，请检查 !" && exit 1
	user_list_all=""
	for((integer = ${user_total}; integer >= 1; integer--))
	do
		user_port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
		user_password=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $2}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
		user_list_all=${user_list_all}"端口: "${user_port}" 密码: "${user_password}"\n"
	done
	echo && echo -e "用户总数 ${Green_font_prefix}"${user_total}"${Font_color_suffix}"
	echo -e ${user_list_all}
}
# 添加 多端口用户配置
Add_multi_port_user(){
	Set_config_port
	Set_config_password
	sed -i "8 i \"        \"${ssr_port}\":\"${ssr_password}\"," ${config_user_file}
	sed -i "8s/^\"//" ${config_user_file}
	Add_iptables
	Save_iptables
	echo -e "${Info} 多端口用户添加完成 ${Green_font_prefix}[端口: ${ssr_port} , 密码: ${ssr_password}]${Font_color_suffix} "
}
# 修改 多端口用户配置
Modify_multi_port_user(){
	List_multi_port_user
	echo && echo -e "请输入要修改的用户端口"
	stty erase '^H' && read -p "(默认: 取消):" modify_user_port
	[[ -z "${modify_user_port}" ]] && echo -e "已取消..." && exit 1
	del_user=`cat ${config_user_file}|grep '"'"${modify_user_port}"'"'`
	if [[ ! -z "${del_user}" ]]; then
		port="${modify_user_port}"
		password=`echo -e ${del_user}|awk -F ":" '{print $NF}'|sed -r 's/.*\"(.+)\".*/\1/'`
		Set_config_port
		Set_config_password
		sed -i 's/"'$(echo ${port})'":"'$(echo ${password})'"/"'$(echo ${ssr_port})'":"'$(echo ${ssr_password})'"/g' ${config_user_file}
		Del_iptables
		Add_iptables
		Save_iptables
		echo -e "${Inof} 多端口用户修改完成 ${Green_font_prefix}[旧: ${modify_user_port}  ${password} , 新: ${ssr_port}  ${ssr_password}]${Font_color_suffix} "
	else
		echo -e "${Error} 请输入正确的端口 !" && exit 1
	fi
}
# 删除 多端口用户配置
Del_multi_port_user(){
	List_multi_port_user
	user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
	[[ "${user_total}" = "1" ]] && echo -e "${Error} 多端口用户仅剩 1个，不能删除 !" && exit 1
	echo -e "请输入要删除的用户端口"
	stty erase '^H' && read -p "(默认: 取消):" del_user_port
	[[ -z "${del_user_port}" ]] && echo -e "已取消..." && exit 1
	del_user=`cat ${config_user_file}|grep '"'"${del_user_port}"'"'`
	if [[ ! -z ${del_user} ]]; then
		port=${del_user_port}
		Del_iptables
		Save_iptables
		del_user_determine=`echo ${del_user:((${#del_user} - 1))}`
		if [[ ${del_user_determine} != "," ]]; then
			del_user_num=$(sed -n -e "/${port}/=" ${config_user_file})
			del_user_num=$(expr $del_user_num - 1)
			sed -i "${del_user_num}s/,//g" ${config_user_file}
		fi
		sed -i "/${port}/d" ${config_user_file}
		echo -e "${Info} 多端口用户删除完成 ${Green_font_prefix} ${del_user_port} ${Font_color_suffix} "
	else
		echo "${Error} 请输入正确的端口 !" && exit 1
	fi
}
# 手动修改 用户配置
Manually_Modify_Config(){
	SSR_installation_status
	port=`${jq_file} '.server_port' ${config_user_file}`
	vi ${config_user_file}
	if [[ -z "${now_mode}" ]]; then
		ssr_port=`${jq_file} '.server_port' ${config_user_file}`
		Del_iptables
		Add_iptables
	fi
	Restart_SSR
}
# 修改 用户配置
Modify_Config(){
	SSR_installation_status
	if [[ -z "${now_mode}" ]]; then
		echo && echo -e "当前模式: 单端口，你要做什么？
 ${Green_font_prefix}1.${Font_color_suffix} 修改 用户端口
 ${Green_font_prefix}2.${Font_color_suffix} 修改 用户密码
 ${Green_font_prefix}3.${Font_color_suffix} 修改 加密方式
 ${Green_font_prefix}4.${Font_color_suffix} 修改 协议插件
 ${Green_font_prefix}5.${Font_color_suffix} 修改 混淆插件
 ${Green_font_prefix}6.${Font_color_suffix} 修改 设备数限制
 ${Green_font_prefix}7.${Font_color_suffix} 修改 单线程限速
 ${Green_font_prefix}8.${Font_color_suffix} 修改 端口总限速
 ${Green_font_prefix}9.${Font_color_suffix} 修改 全部配置" && echo
		stty erase '^H' && read -p "(默认: 取消):" ssr_modify
		[[ -z "${ssr_modify}" ]] && echo "已取消..." && exit 1
		Get_User
		if [[ ${ssr_modify} == "1" ]]; then
			Set_config_port
			Modify_config_port
			Add_firewall
			Del_firewall
		elif [[ ${ssr_modify} == "2" ]]; then
			Set_config_password
			Modify_config_password
		elif [[ ${ssr_modify} == "3" ]]; then
			Set_config_method
			Modify_config_method
		elif [[ ${ssr_modify} == "4" ]]; then
			Set_config_protocol
			Modify_config_protocol
		elif [[ ${ssr_modify} == "5" ]]; then
			Set_config_obfs
			Modify_config_obfs
		elif [[ ${ssr_modify} == "6" ]]; then
			Set_config_protocol_param
			Modify_config_protocol_param
		elif [[ ${ssr_modify} == "7" ]]; then
			Set_config_speed_limit_per_con
			Modify_config_speed_limit_per_con
		elif [[ ${ssr_modify} == "8" ]]; then
			Set_config_speed_limit_per_user
			Modify_config_speed_limit_per_user
		elif [[ ${ssr_modify} == "9" ]]; then
			Set_config_all
			Modify_config_all
		else
			echo -e "${Error} 请输入正确的数字(1-9)" && exit 1
		fi
	else
		echo && echo -e "当前模式: 多端口，你要做什么？
 ${Green_font_prefix}1.${Font_color_suffix}  添加 用户配置
 ${Green_font_prefix}2.${Font_color_suffix}  删除 用户配置
 ${Green_font_prefix}3.${Font_color_suffix}  修改 用户配置
——————————
 ${Green_font_prefix}4.${Font_color_suffix}  修改 加密方式
 ${Green_font_prefix}5.${Font_color_suffix}  修改 协议插件
 ${Green_font_prefix}6.${Font_color_suffix}  修改 混淆插件
 ${Green_font_prefix}7.${Font_color_suffix}  修改 设备数限制
 ${Green_font_prefix}8.${Font_color_suffix}  修改 单线程限速
 ${Green_font_prefix}9.${Font_color_suffix}  修改 端口总限速
 ${Green_font_prefix}10.${Font_color_suffix} 修改 全部配置" && echo
		stty erase '^H' && read -p "(默认: 取消):" ssr_modify
		[[ -z "${ssr_modify}" ]] && echo "已取消..." && exit 1
		Get_User
		if [[ ${ssr_modify} == "1" ]]; then
			Add_multi_port_user
		elif [[ ${ssr_modify} == "2" ]]; then
			Del_multi_port_user
		elif [[ ${ssr_modify} == "3" ]]; then
			Modify_multi_port_user
		elif [[ ${ssr_modify} == "4" ]]; then
			Set_config_method
			Modify_config_method
		elif [[ ${ssr_modify} == "5" ]]; then
			Set_config_protocol
			Modify_config_protocol
		elif [[ ${ssr_modify} == "6" ]]; then
			Set_config_obfs
			Modify_config_obfs
		elif [[ ${ssr_modify} == "7" ]]; then
			Set_config_protocol_param
			Modify_config_protocol_param
		elif [[ ${ssr_modify} == "8" ]]; then
			Set_config_speed_limit_per_con
			Modify_config_speed_limit_per_con
		elif [[ ${ssr_modify} == "9" ]]; then
			Set_config_speed_limit_per_user
			Modify_config_speed_limit_per_user
		elif [[ ${ssr_modify} == "10" ]]; then
			Set_config_method
			Set_config_protocol
			Set_config_obfs
			Set_config_protocol_param
			Set_config_speed_limit_per_con
			Set_config_speed_limit_per_user
			Modify_config_method
			Modify_config_protocol
			Modify_config_obfs
			Modify_config_protocol_param
			Modify_config_speed_limit_per_con
			Modify_config_speed_limit_per_user
		else
			echo -e "${Error} 请输入正确的数字(1-9)" && exit 1
		fi
	fi
	Restart_SSR
}
# 安装 依赖
Install_dependency(){
	yum -y update
	yum install -y python python-devel python-setuptools openssl openssl-devel curl wget unzip gcc automake autoconf make libtool net-tools
	cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}
install_cleanup(){
	cd ${cur_dir}
	rm -rf ${ssr_name}.tar.gz ${jq_name} ${ssr_manager_name}
}
# 下载 ShadowsocksR
Download_File(){
	# Download ShadowsocksR file
	if ! wget --no-check-certificate -O ${ssr_name}.tar.gz ${ssr_url}; then
		echo -e "${Error} Failed to download ${ssr_name}.tar.gz file!" && install_cleanup && exit 1
	fi
	# Download jq file
	if [[ ${bit} = "x86_64" ]]; then
			jq_url="${jq_64_url}"
		else
			jq_url="${jq_32_url}"
		fi
	if ! wget -N --no-check-certificate -O ${jq_name} ${jq_url}; then
		echo -e "${Error} Failed to download ${jq_name}!" && install_cleanup && exit 1
	fi
	# Download ssr_manager
	if ! wget --no-check-certificate -O ${ssr_manager_name} ${ssr_manager_centos_url}; then
		echo -e "${Error} Failed to download ${ssr_manager_name} !" && install_cleanup && exit 1
	fi
}

Write_configuration_many(){
	cat > ${config_user_file}<<-EOF
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "port_password":{
        "${ssr_port}":"${ssr_password}"
    },
    "method": "${ssr_method}",
    "protocol": "${ssr_protocol}",
    "protocol_param": "${ssr_protocol_param}",
    "obfs": "${ssr_obfs}",
    "obfs_param": "",
    "speed_limit_per_con": ${ssr_speed_limit_per_con},
    "speed_limit_per_user": ${ssr_speed_limit_per_user},

    "additional_ports" : {},
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 0,
    "redirect": "",
    "fast_open": false
}
EOF
}
# 切换端口模式
Port_mode_switching(){
	SSR_installation_status
	if [[ -z "${now_mode}" ]]; then
		echo && echo -e "	当前模式: ${Green_font_prefix}单端口${Font_color_suffix}" && echo
		echo -e "确定要切换为 多端口模式？[y/N]"
		stty erase '^H' && read -p "(默认: n):" mode_yn
		[[ -z ${mode_yn} ]] && mode_yn="n"
		if [[ ${mode_yn} == [Yy] ]]; then
			port=`${jq_file} '.server_port' ${config_user_file}`
			Set_config_all
			Write_configuration_many
			Del_iptables
			Add_iptables
			Save_iptables
			Restart_SSR
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo && echo -e "	当前模式: ${Green_font_prefix}多端口${Font_color_suffix}" && echo
		echo -e "确定要切换为 单端口模式？[y/N]"
		stty erase '^H' && read -p "(默认: n):" mode_yn
		[[ -z ${mode_yn} ]] && mode_yn="n"
		if [[ ${mode_yn} == [Yy] ]]; then
			user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
				Del_iptables
			done
			Set_config_all
			Write_configuration
			Add_iptables
			Restart_SSR
		else
			echo && echo "	已取消..." && echo
		fi
	fi
}
# 安装
Service_SSR(){
	cd ${cur_dir}
	# Install ShadowsocksR
	tar zxf ${ssr_name}.tar.gz
	mv ${ssr_name}/ ${ssr_folder}
	# Install jq
	mv ${jq_name} ${jq_file}
	chmod +x "${jq_file}"
	# Install ssr_manager
	mv ${ssr_manager_name} ${ssr_manager_file}
	chmod +x "${ssr_manager_file}"
	chkconfig --add "${ssr_name}"
	chkconfig "${ssr_name}" on
}
# 写入 配置信息
Write_configuration(){
	[[ -e ${config_folder} ]] && rm -rf ${config_folder}
	mkdir ${config_folder}
	cat > ${config_user_file}<<-EOF
{
    "server": "0.0.0.0",
    "server_ipv6": "::",
    "server_port": ${ssr_port},
    "local_address": "127.0.0.1",
    "local_port": 1080,

    "password": "${ssr_password}",
    "method": "${ssr_method}",
    "protocol": "${ssr_protocol}",
    "protocol_param": "${ssr_protocol_param}",
    "obfs": "${ssr_obfs}",
    "obfs_param": "",
    "speed_limit_per_con": ${ssr_speed_limit_per_con},
    "speed_limit_per_user": ${ssr_speed_limit_per_user},

    "additional_ports" : {},
    "timeout": 120,
    "udp_timeout": 60,
    "dns_ipv6": false,
    "connect_verbose_info": 0,
    "redirect": "",
    "fast_open": false
}
EOF
}
# 防火墙设置
Add_firewall(){
	echo -e "[${green}Info${plain}] firewall set start..."
	systemctl status firewalld > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		firewall-cmd --permanent --zone=public --add-port=${ssr_port}/tcp
		firewall-cmd --permanent --zone=public --add-port=${ssr_port}/udp
		firewall-cmd --reload
	else
		echo -e "${Error} firewalld looks like not running or not installed, please enable port ${ssr_port} manually if necessary."
	fi
	echo -e "${Info} firewall set completed..."
}
# 防火墙设置
Del_firewall(){
	echo -e "[${green}Info${plain}] firewall set start..."
	systemctl status firewalld > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		firewall-cmd --permanent --zone=public --remove-port=${port}/tcp
		firewall-cmd --permanent --zone=public --remove-port=${port}/udp
		firewall-cmd --reload
	else
		echo -e "${Error} firewalld looks like not running or not installed, please enable port ${ssr_port} manually if necessary."
	fi
	echo -e "${Info} firewall set completed..."
}
Start_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR 正在运行 !" && exit 1
	${ssr_manager_file} start
	check_pid
	[[ ! -z ${PID} ]] && View_Config
}
Stop_SSR(){
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} ShadowsocksR 未运行 !" && exit 1
	${ssr_manager_file} stop
}
Restart_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && ${ssr_manager_file} stop
	${ssr_manager_file} start
	check_pid
	[[ ! -z ${PID} ]] && View_Config
}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} ShadowsocksR日志文件不存在 !" && exit 1
	echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo
	tail -f ${ssr_log_file}
}
# 读取 配置信息
Get_IP(){
	ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
	if [[ -z "${ip}" ]]; then
		ip=$(wget -qO- -t1 -T2 api.ip.sb/ip)
		if [[ -z "${ip}" ]]; then
			ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
			if [[ -z "${ip}" ]]; then
				ip="VPS_IP"
			fi
		fi
	fi
}
Get_User(){
	[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ解析器 不存在，请检查 !" && exit 1
	port=`${jq_file} '.server_port' ${config_user_file}`
	password=`${jq_file} '.password' ${config_user_file} | sed 's/^.//;s/.$//'`
	method=`${jq_file} '.method' ${config_user_file} | sed 's/^.//;s/.$//'`
	protocol=`${jq_file} '.protocol' ${config_user_file} | sed 's/^.//;s/.$//'`
	obfs=`${jq_file} '.obfs' ${config_user_file} | sed 's/^.//;s/.$//'`
	protocol_param=`${jq_file} '.protocol_param' ${config_user_file} | sed 's/^.//;s/.$//'`
	speed_limit_per_con=`${jq_file} '.speed_limit_per_con' ${config_user_file}`
	speed_limit_per_user=`${jq_file} '.speed_limit_per_user' ${config_user_file}`
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
}
urlsafe_base64(){
	date=$(echo -n "$1"|base64|sed ':a;N;s/\n/ /g;ta'|sed 's/ //g;s/=//g;s/+/-/g;s/\//_/g')
	echo -e "${date}"
}
ss_link_qr(){
	SSbase64=$(urlsafe_base64 "${method}:${password}@${ip}:${port}")
	SSurl="ss://${SSbase64}"
	SSQRcode="http://doub.pw/qr/qr.php?text=${SSurl}"
	ss_link=" SS    链接 : ${Green_font_prefix}${SSurl}${Font_color_suffix} \n SS  二维码 : ${Green_font_prefix}${SSQRcode}${Font_color_suffix}"
}
ssr_link_qr(){
	SSRprotocol=$(echo ${protocol} | sed 's/_compatible//g')
	SSRobfs=$(echo ${obfs} | sed 's/_compatible//g')
	SSRPWDbase64=$(urlsafe_base64 "${password}")
	SSRbase64=$(urlsafe_base64 "${ip}:${port}:${SSRprotocol}:${method}:${SSRobfs}:${SSRPWDbase64}")
	SSRurl="ssr://${SSRbase64}"
	SSRQRcode="http://doub.pw/qr/qr.php?text=${SSRurl}"
	ssr_link=" SSR   链接 : ${Red_font_prefix}${SSRurl}${Font_color_suffix} \n SSR 二维码 : ${Red_font_prefix}${SSRQRcode}${Font_color_suffix} \n "
}
ss_ssr_determine(){
	protocol_suffix=`echo ${protocol} | awk -F "_" '{print $NF}'`
	obfs_suffix=`echo ${obfs} | awk -F "_" '{print $NF}'`
	if [[ ${protocol} = "origin" ]]; then
		if [[ ${obfs} = "plain" ]]; then
			ss_link_qr
			ssr_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				ss_link=""
			else
				ss_link_qr
			fi
		fi
	else
		if [[ ${protocol_suffix} != "compatible" ]]; then
			ss_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				if [[ ${obfs_suffix} = "plain" ]]; then
					ss_link_qr
				else
					ss_link=""
				fi
			else
				ss_link_qr
			fi
		fi
	fi
	ssr_link_qr
}
# 显示 配置信息
View_Config(){
	SSR_installation_status
	Get_IP
	Get_User
	now_mode=$(cat "${config_user_file}"|grep '"port_password"')
	[[ -z ${protocol_param} ]] && protocol_param="0(无限)"
	if [[ -z "${now_mode}" ]]; then
		ss_ssr_determine
		clear && echo "===================================================" && echo
		echo -e " ShadowsocksR账号 配置信息：" && echo
		echo -e " I  P\t    : ${Green_font_prefix}${ip}${Font_color_suffix}"
		echo -e " 端口\t    : ${Green_font_prefix}${port}${Font_color_suffix}"
		echo -e " 密码\t    : ${Green_font_prefix}${password}${Font_color_suffix}"
		echo -e " 加密\t    : ${Green_font_prefix}${method}${Font_color_suffix}"
		echo -e " 协议\t    : ${Red_font_prefix}${protocol}${Font_color_suffix}"
		echo -e " 混淆\t    : ${Red_font_prefix}${obfs}${Font_color_suffix}"
		echo -e " 设备数限制 : ${Green_font_prefix}${protocol_param}${Font_color_suffix}"
		echo -e " 单线程限速 : ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"
		echo -e " 端口总限速 : ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}"
		echo -e "${ss_link}"
		echo -e "${ssr_link}"
		echo -e " ${Green_font_prefix} 提示: ${Font_color_suffix}
 在浏览器中，打开二维码链接，就可以看到二维码图片。
 协议和混淆后面的[ _compatible ]，指的是 兼容原版协议/混淆。"
		echo && echo "==================================================="
	else
		user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
		[[ ${user_total} = "0" ]] && echo -e "${Error} 没有发现 多端口用户，请检查 !" && exit 1
		clear && echo "===================================================" && echo
		echo -e " ShadowsocksR账号 配置信息：" && echo
		echo -e " I  P\t    : ${Green_font_prefix}${ip}${Font_color_suffix}"
		echo -e " 加密\t    : ${Green_font_prefix}${method}${Font_color_suffix}"
		echo -e " 协议\t    : ${Red_font_prefix}${protocol}${Font_color_suffix}"
		echo -e " 混淆\t    : ${Red_font_prefix}${obfs}${Font_color_suffix}"
		echo -e " 设备数限制 : ${Green_font_prefix}${protocol_param}${Font_color_suffix}"
		echo -e " 单线程限速 : ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"
		echo -e " 端口总限速 : ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}" && echo
		for((integer = ${user_total}; integer >= 1; integer--))
		do
			port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
			password=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $2}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
			ss_ssr_determine
			echo -e ${Line}
			echo -e " 端口\t    : ${Green_font_prefix}${port}${Font_color_suffix}"
			echo -e " 密码\t    : ${Green_font_prefix}${password}${Font_color_suffix}"
			echo -e "${ss_link}"
			echo -e "${ssr_link}"
		done
		echo -e " ${Green_font_prefix} 提示: ${Font_color_suffix}
 在浏览器中，打开二维码链接，就可以看到二维码图片。
 协议和混淆后面的[ _compatible ]，指的是 兼容原版协议/混淆。"
		echo && echo "==================================================="
	fi
}
Install_SSR(){
	[[ -e ${config_user_file} ]] && echo -e "${Error} ShadowsocksR 配置文件已存在，请检查( 如安装失败或者存在旧版本，请先卸载 ) !" && exit 1
	[[ -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR 文件夹已存在，请检查( 如安装失败或者存在旧版本，请先卸载 ) !" && exit 1
	echo -e "${Info} 1.开始安装 ShadowsocksR依赖..."
	Install_dependency
	echo -e "${Info} 2.开始下载 ShadowsocksR..."
	Download_File
	echo -e "${Info} 3.开始安装 ShadowsocksR..."
	Service_SSR
	echo -e "${Info} 4.开始配置 ShadowsocksR..."
	Write_configuration
	echo -e "${Info} 5.开始设置 firewall防火墙..."
	Add_firewall
	echo -e "${Info} 所有步骤 安装完毕，开始启动 ShadowsocksR服务端..."
	Start_SSR
}
Uninstall_SSR(){
	[[ ! -e ${config_user_file} ]] && [[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有安装 ShadowsocksR，请检查 !" && exit 1
	echo "确定要 卸载ShadowsocksR？[y/N]" && echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z "${PID}" ]] && kill -9 ${PID}
		if [[ -z "${now_mode}" ]]; then
			port=`${jq_file} '.server_port' ${config_user_file}`
			Del_firewall
		else
			user_total=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | wc -l`
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=`${jq_file} '.port_password' ${config_user_file} | sed '$d' | sed "1d" | awk -F ":" '{print $1}' | sed -n "${integer}p" | sed -r 's/.*\"(.+)\".*/\1/'`
				Del_firewall
			done
		fi
		chkconfig --del ssr
		rm -rf ${ssr_folder} && rm -rf ${config_folder} && rm -rf ${ssr_manager_file}
		echo && echo " ShadowsocksR 卸载完成 !" && echo
	else
		echo && echo " 卸载已取消..." && echo
	fi
}
get_IP_address(){
	if [[ ! -z ${user_IP_1} ]]; then
		for((integer_1 = ${user_IP_total}; integer_1 >= 1; integer_1--))
		do
			IP=`echo "${user_IP_1}" |sed -n "$integer_1"p`
			IP_address=`wget -qO- -t1 -T2 http://freeapi.ipip.net/${IP}|sed 's/\"//g;s/,//g;s/\[//g;s/\]//g'`
			user_IP="${user_IP}\n${IP}(${IP_address})"
			sleep 1s
		done
	fi
}
# 显示 连接信息
View_user_connection_info(){
	SSR_installation_status
	if [[ -z "${now_mode}" ]]; then
		now_mode="单端口" && user_total="1"
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_port=`${jq_file} '.server_port' ${config_user_file}`
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep ":${user_port} " |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" `
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			get_IP_address
		fi
		user_list_all="端口: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t 链接IP总数: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t 当前链接IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
		echo -e "当前模式: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} 链接IP总数: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix}"
		echo -e "${user_list_all}"
	else
		now_mode="多端口" && user_total=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' | wc -l`
		IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
		user_list_all=""
		for((integer = ${user_total}; integer >= 1; integer--))
		do
			user_port=`${jq_file} '.port_password' ${config_user_file} |sed '$d;1d' |awk -F ":" '{print $1}' |sed -n "${integer}p" |sed -r 's/.*\"(.+)\".*/\1/'`
			user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep "${user_port}" |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
			if [[ -z ${user_IP_1} ]]; then
				user_IP_total="0"
			else
				user_IP_total=`echo -e "${user_IP_1}"|wc -l`
				get_IP_address
			fi
			user_list_all=${user_list_all}"端口: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\t 链接IP总数: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}\t 当前链接IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
			user_IP=""
		done
		echo -e "当前模式: ${Green_background_prefix} "${now_mode}" ${Font_color_suffix} 用户总数: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} 链接IP总数: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
		echo -e "${user_list_all}"
	fi
}
chose_menu(){
	echo && stty erase '^H' && read -p "请输入数字 [1-15]：" num
	case "$num" in
		1)
		Install_SSR
		;;
		2)
		Start_SSR
		;;
		3)
		Stop_SSR
		;;
		4)
		Restart_SSR
		;;
		5)
		Uninstall_SSR
		;;
		6)
		Modify_Config
		;;
		7)
		View_Config
		;;
		8)
		View_user_connection_info
		;;
		9)
		View_Log
		;;
		10)
		Manually_Modify_Config
		;;
		11)
		Port_mode_switching
		;;
		*)
		echo -e "${Error} 请输入正确的数字 [1-15]"
		;;
	esac
}

disable_selinux
check_sys
check_role
check_pid
show_menu
chose_menu


