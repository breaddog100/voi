#!/bin/bash

function install_node() {
	#设置主机名
	#主机名格式 {$two arbitrary chars represents you}-${cloud provider}-${2 letter country}-${3 letter airport short code}-${3 arbitrary numbers}
	echo "排重见官方文档附录A：https://docs.google.com/document/d/1yWSL3BT-pX22_P5eyyxKa4IeKy2GgUpm-bbF84yfito/edit"
	read -p "请输入主机名（2位自定义码不能重复-3位云提供商-2国家-3位机场短代码-3位随机数）: " hostname
	if [[ -z "$hostname" ]]; then
	    echo "错误：主机名不能为空。"
	    exit 1
	fi
	
	# 配置logging.config
	echo "打开https://guidgenerator.com/点击【Generate some GUIDs!】按钮，然后点击【Copy to Clipboard】复制内容"
	read -p "请粘贴GUID:" guidvalue
	# 配置algod.token
	echo "打开https://emn178.github.io/online-tools/sha256.html，在【Input】中输入内容，然后复制【Output】中的内容"
	read -p "请粘贴Output内容:" hashvalue
	
	sudo hostnamectl set-hostname --static "$hostname"
	
	# 检查ufw是否正在运行
	if sudo ufw status | grep -q "Status: active"; then
	    echo "ufw is active. Configuring rules..."
	    # 允许从特定IP到任何端口9100的流量
	    sudo ufw allow from 170.205.24.129 to any port 9100
	    # 允许端口5011的流量
	    sudo ufw allow 5011
	    echo "Rules have been added."
	fi
	
	#添加Docker的官方GPG密钥：
	sudo apt-get update
	sudo apt-get install ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	
	#将存储库添加到 Apt 源：
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	
	#安装 Docker
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin jq
	
	#设置权限-使用ubuntu账户
	sudo usermod -aG docker ${USER}
	
	#创建节点文件夹和3个文件
	mkdir $HOME/node
	cd $HOME/node
	
	#voi_testnet/node将此 repo 文件夹中的 config.json、logging.config 和 algod.token 的内容复制到这些文件中。
	#确保更改logging.config文件中的 GUID，您可以使用此工具创建一个新的 GUID 。
	#确保更改algod.token文件中的文本，您可以使用此工具创建一个新的哈希。您只需在输入中输入随机字符即可。
	
	# 配置config.json
	sudo cat << EOF > config.json
{    
"Version": 31,
"Archival": false,
"GossipFanout": 8,
"NetAddress": "0.0.0.0:5011",
"MaxConnectionsPerIP": 2,
"IncomingConnectionsLimit": 90,
"DNSBootstrapID": "<network>.voi.network?backup=<network>.voinetwork.net&dedup=<name>.(voi.*?)\\.(network|net)",
"EnableMetricReporting": true,
"EnableLedgerService": true,
"EnableBlockService": true,
"CatchpointFileHistoryLength": 3,
"CatchpointTracking": 2,
"MaxBlockHistoryLookback": 22000
}
EOF

	# 配置logging.config
	#read -p "请输入GUID（到 https://guidgenerator.com/ 生成）:" guidvalue
	sudo cat << EOF > logging.config
{    
"Enable": false,
"SendToLog": false,
"URI": "",
"Name": "",
"GUID": "$guidvalue",
"FilePath": "",
"UserName": "",
"Password": "",
"MinLogLevel": 3,
"ReportHistoryLevel": 3
}
EOF
	
	# 配置algod.token
	#read -p "请输入哈希值（到 https://emn178.github.io/online-tools/sha256.html 生成）:" hashvalue
	sudo cat << EOF > algod.token
$hashvalue
EOF
	
	#返回你的主目录
	cd $HOME
	
	#voi_testnet将此 repo 文件夹中 docker-compose.yaml、goal.sh 和 catchup.sh 的内容复制到这些文件中。
	
	#配置docker-compose.yaml
	wget https://raw.githubusercontent.com/cswenor/voi-relay-setup/main/voi_testnet/docker-compose.yaml
	    
	#配置goal.sh
	wget https://raw.githubusercontent.com/cswenor/voi-relay-setup/main/voi_testnet/goal.sh
	  
	#配置catchup.sh
	wget https://raw.githubusercontent.com/cswenor/voi-relay-setup/main/voi_testnet/catchup.sh
	
	chmod +x catchup.sh
	chmod +x goal.sh
	
	#挂载节点数据文件夹
	sudo mkdir /mnt/nodevoit
	sudo chmod 777 /mnt/nodevoit
	
	#拉取 Docker 镜像
	sudo docker pull urtho/algod-voitest-rly
	
	#独立启动服务，在后台运行
	sudo docker compose up -d
	echo "部署完成，请退出并重新连接服务器已生效配置..."
	newgrp docker
}

# 同步服务器
function catchup(){
	echo "启动同步需要约1分钟，请等待..."
	~/catchup.sh
}

# 检查是否已同步
function goal(){
	~/goal.sh node status
}

# 启动节点
function stop_node(){
	sudo docker compose down
}

# 停止节点
function start_node(){
	sudo docker compose up -d
}

function update_config(){
	stop_node
	rm -f $HOME/node/config.json 
	cd $HOME/node/
	# 配置config.json
	sudo cat << EOF > config.json
{    
"Version": 31,
"Archival": false,
"GossipFanout": 8,
"NetAddress": "0.0.0.0:5011",
"MaxConnectionsPerIP": 2,
"IncomingConnectionsLimit": 90,
"DNSBootstrapID": "<network>.voi.network?backup=<network>.voinetwork.net&dedup=<name>.(voi.*?)\\.(network|net)",
"EnableMetricReporting": true,
"EnableLedgerService": true,
"EnableBlockService": true,
"CatchpointFileHistoryLength": 3,
"CatchpointTracking": 2,
"MaxBlockHistoryLookback": 22000
}
EOF
	start_node
}

# 卸载节点
function uninstall_node(){
    echo "你确定要卸载节点程序吗？这将会删除所有相关的数据。[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载节点程序..."
            stop_node
            # 获取所有名字以 node- 开头的 Docker 镜像 ID
			image_ids=$(docker images --format "{{.ID}} {{.Repository}}" | grep "node-" | awk '{print \$1}')
            # 删除匹配的镜像
			for image_id in $image_ids; do
			    echo "正在删除镜像 ID: $image_id"
			    sudo docker rmi $image_id
			done
            sudo rm -rf $HOME/catchup.sh  $HOME/docker-compose.yaml  $HOME/goal.sh  $HOME/node /mnt/nodevoit

            echo "节点程序卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}

# 主菜单
function main_menu() {
	while true; do
	    clear
	    echo "==================VOI 中继节点 一键部署脚本==================="
		echo "沟通电报群：https://t.me/lumaogogogo"
		echo "推荐配置：16C16G100G-NVME"
		echo "需要到官方申请"
	    echo "请选择要执行的操作:"
	    echo "1. 部署节点 install_node"
	    echo "2. 同步服务器 catchup"
	    echo "3. 检查同步状态 goal"
	    echo "4. 启动节点 start_node"
	    echo "5. 停止节点 stop_node"
	    echo "6. 更新配置文件 update_config"
	    echo "1618. 卸载节点 uninstall_node"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_node ;;
	    2) catchup ;;
	    3) goal ;;
	    4) start_node ;;
	    5) stop_node ;;
	    6) update_config ;;
	    1618) uninstall_node ;;
	    0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

main_menu
