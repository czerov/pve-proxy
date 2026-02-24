#!/bin/bash

# --- 默认配置 ---
DEFAULT_IP="192.168.5.102"
DEFAULT_PORT="7897"
APT_CONF="/etc/apt/apt.conf.d/99proxy"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
    clear
    echo -e "${YELLOW}=== PVE LXC 代理助手 (Debian 13) ===${NC}"
    
    # 检查 APT 配置文件是否存在
    if [ -f "$APT_CONF" ]; then
        echo -e "系统代理状态: ${GREEN}【已开启】${NC}"
    else
        echo -e "系统代理状态: ${RED}【已关闭】${NC}"
    fi

    # 探测代理服务器
    echo -n "代理服务器探测 ($DEFAULT_IP:$DEFAULT_PORT): "
    if timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DEFAULT_IP/$DEFAULT_PORT" 2>/dev/null; then
        echo -e "${GREEN}在线 (Active)${NC}"
    else
        echo -e "${RED}离线 (Offline)${NC}"
    fi

    echo "--------------------------------"
    echo "1. 开启代理 (使用默认地址)"
    echo "2. 手动输入代理地址并开启"
    echo "3. 关闭代理"
    echo "4. 刷新状态"
    echo "5. 退出"
    echo "--------------------------------"
    read -p "请选择 [1-5]: " CHOICE

    case "$CHOICE" in
        1)
            TARGET_ADDR="$DEFAULT_IP:$DEFAULT_PORT"
            echo "Acquire::http::Proxy \"http://$TARGET_ADDR\";" > $APT_CONF
            echo "Acquire::https::Proxy \"http://$TARGET_ADDR\";" >> $APT_CONF
            export http_proxy="http://$TARGET_ADDR"
            export https_proxy="http://$TARGET_ADDR"
            echo -e "${GREEN}已开启! APT 现已走代理。${NC}"
            sleep 1
            ;;
        2)
            read -p "请输入 IP: " IN_IP
            read -p "请输入端口: " IN_PORT
            TARGET_ADDR="${IN_IP:-$DEFAULT_IP}:${IN_PORT:-$DEFAULT_PORT}"
            echo "Acquire::http::Proxy \"http://$TARGET_ADDR\";" > $APT_CONF
            echo "Acquire::https::Proxy \"http://$TARGET_ADDR\";" >> $APT_CONF
            export http_proxy="http://$TARGET_ADDR"
            export https_proxy="http://$TARGET_ADDR"
            echo -e "${GREEN}配置已更新为 $TARGET_ADDR${NC}"
            sleep 1
            ;;
        3)
            [ -f "$APT_CONF" ] && rm "$APT_CONF"
            unset http_proxy https_proxy all_proxy
            echo -e "${RED}代理配置已清除。${NC}"
            sleep 1
            ;;
        4)
            continue
            ;;
        5)
            echo "退出助手。"
            break
            ;;
        *)
            echo -e "${RED}无效选项，请重新输入。${NC}"
            sleep 1
            ;;
    esac
done
