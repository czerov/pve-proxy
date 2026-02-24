#!/bin/bash

# 定义函数以隔离变量
proxy_helper() {
    local DEFAULT_IP="192.168.5.102"
    local DEFAULT_PORT="7897"
    local APT_CONF="/etc/apt/apt.conf.d/99proxy"
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local NC='\033[0m'

    while true; do
        clear
        echo -e "${YELLOW}=== PVE LXC 代理助手 ===${NC}"
        
        # 状态检查 [cite: 3]
        if [ -f "$APT_CONF" ]; then
            echo -e "APT 代理: ${GREEN}已开启${NC}"
        else
            echo -e "APT 代理: ${RED}已关闭${NC}"
        fi

        # 连通性探测 [cite: 4]
        echo -n "检测代理 $DEFAULT_IP:$DEFAULT_PORT... "
        if timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DEFAULT_IP/$DEFAULT_PORT" 2>/dev/null; then
            echo -e "${GREEN}正常${NC}"
        else
            echo -e "${RED}无法连接${NC}"
        fi

        echo "--------------------------------"
        echo "1. 开启代理 (默认地址)"
        echo "2. 手动输入代理"
        echo "3. 关闭并清除代理"
        echo "4. 刷新状态"
        echo "5. 退出"
        echo "--------------------------------"
        read -p "选择 [1-5]: " CHOICE

        case "$CHOICE" in
            1)
                TARGET="$DEFAULT_IP:$DEFAULT_PORT"
                echo "Acquire::http::Proxy \"http://$TARGET\";" > $APT_CONF [cite: 6]
                echo "Acquire::https::Proxy \"http://$TARGET\";" >> $APT_CONF [cite: 7]
                export http_proxy="http://$TARGET" [cite: 7]
                export https_proxy="http://$TARGET" [cite: 7]
                echo -e "${GREEN}代理已启用${NC}"
                sleep 1
                ;;
            2)
                read -p "IP: " IN_IP
                read -p "端口: " IN_PORT
                TARGET="${IN_IP:-$DEFAULT_IP}:${IN_PORT:-$DEFAULT_PORT}" [cite: 8]
                echo "Acquire::http::Proxy \"http://$TARGET\";" > $APT_CONF [cite: 9]
                echo "Acquire::https::Proxy \"http://$TARGET\";" >> $APT_CONF [cite: 10]
                export http_proxy="http://$TARGET" [cite: 10]
                export https_proxy="http://$TARGET" [cite: 10]
                sleep 1
                ;;
            3)
                rm -f $APT_CONF [cite: 11]
                unset http_proxy https_proxy all_proxy [cite: 11]
                echo -e "${RED}代理已关闭${NC}"
                sleep 1
                ;;
            4) continue ;; [cite: 12]
            5) break ;; [cite: 13]
            *) echo "无效选项"; sleep 1 ;; [cite: 14]
        esac
    done
}

# 执行函数
proxy_helper
