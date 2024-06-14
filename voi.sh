#!/bin/bash

# 部署节点
function install_node() {
	
	sudo apt update
	sudo apt upgrade
	export VOINETWORK_IMPORT_ACCOUNT=1
	sudo /bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"

}

#创建钱包，账户，获取助记词

function create-wallet(){
	#创建钱包
	echo "请输入钱包名称："
	read wallet_name
	sudo $HOME/voi/bin/create-wallet "$wallet_name"
}

#获取账户助记词
function get-account-mnemonic(){
	echo "请输入账户地址："
	read account_address
	sudo $HOME/voi/bin/get-account-mnemonic "$account_address"
}

#导入账户
function import-account(){
	echo "请输入账户地址："
	read account_address
	sudo $HOME/voi/bin/import-account
}


#生成参与密钥（参与密钥将在预计 60 天后过期，需要重新生成。）
function generate-participation-key (){
	echo "请输入账户地址："
	read account_address
	sudo $HOME/voi/bin/generate-participation-key "$account_address"
	echo "参与密钥将在预计 60 天后过期，需要重新生成："
}


#重新生成参与密钥
function Re-generate-participation-key(){
	sudo /bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
}

#查看账户参与状态
function check_status(){
	echo "请输入账户地址："
	read account_address
	sudo $HOME/voi/bin/get-participation-status "$account_address"
}

#节点状态
function get-node-status(){
	sudo $HOME/voi/bin/get-node-status
}

# 主菜单
function main_menu() {
	while true; do
	    clear
	    echo "===================VOI 一键部署脚本==================="
		echo "沟通电报群：https://t.me/lumaogogogo"
		echo "推荐配置：18C16G300G"
	    echo "请选择要执行的操作:"
	    echo "1. 部署节点 install_node"
	    echo "2. 创建账户 create-wallet"
	    echo "3. 获取账户助记词 get-account-mnemonic"
	    echo "4. 导入账户 import-account"
	    echo "5. 生成参与秘钥（60天过期） generate-participation-key"
	    echo "6. 生成参与秘钥 Re-generate participation key"
	    echo "7. 查看账户参与状态 check_status"
	    echo "8. 获取节点健康信息 get-node-status"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_node ;;
	    2) create-wallet ;;
	    3) get-account-mnemonic;;
	    4) import-account ;;
	    5) generate-participation-key ;;
	    6) Re-generate-participation-key ;;
	    7) check_status ;;
	    8) get-node-status ;;
	    0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 1 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

main_menu
