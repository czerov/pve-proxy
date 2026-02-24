#!/bin/bash
# 建议文件名: proxy.sh

proxy_manager() {
    # --- 默认配置 ---
    local DEFAULT_IP="192.168.5.102" [cite: 1]
    local DEFAULT_PORT="7897" [cite: 1]
    local APT_CONF="/etc/apt/apt.conf.d/99proxy" [cite: 1]

    # 颜色
    local RED='\033[0;31m' [cite: 1]
    local GREEN='\033[0;32m' [cite: 1]
    local YELLOW='\033[1;33m' [cite: 1]
    local NC='\033[0m' [cite: 1]

    while true; do [cite: 1, 2]
        clear
        echo -e "${YELLOW}=== PVE LXC 代理助手 (Debian 13) ===${NC}" [cite: 2]
        
        # 检查状态
        if [ -f "$APT_CONF" ]; then [cite: 2, 3]
            echo -e "系统代理状态: ${GREEN}【已开启】${NC}" [cite: 3]
        else
            echo -e "系统代理状态: ${RED}【已关闭】${NC}" [cite: 3]
        fi

        # 探测代理服务器 [cite: 3]
        echo -n "代理服务器探测 ($DEFAULT_IP:$DEFAULT_PORT): " [cite: 3]
        if timeout 1 bash -c "cat < /dev/null > /dev/tcp/$DEFAULT_IP/$DEFAULT_PORT" 2>/dev/null; then 
            echo -e "${GREEN}在线 (Active)${NC}" [cite: 4]
        else
            echo -e "${RED}离线 (Offline)${NC}" [cite: 4]
        fi

        echo "--------------------------------" [cite: 4]
        echo "1. 开启代理 (使用默认地址)" [cite: 4]
        echo "2. 手动输入代理地址并开启" [cite: 8]
        echo "3. 关闭代理" [cite: 11]
        echo "4. 刷新状态" [cite: 12]
        echo "5. 退出" [cite: 13]
        echo "--------------------------------" [cite: 4]
        read -p "请选择 [1-5]: " CHOICE [cite: 4]

        case "$CHOICE" in
            1)
                TARGET_ADDR="$DEFAULT_IP:$DEFAULT_PORT" [cite: 5]
                echo "Acquire::http::Proxy \"http://$TARGET_ADDR\";" > $APT_CONF [cite: 5, 6]
                echo "Acquire::https::Proxy \"http://$TARGET_ADDR\";" >> $APT_CONF [cite: 6, 7]
                export http_proxy="http://$TARGET_ADDR" 
                export https_proxy="http://$TARGET_ADDR" 
                export all_proxy="socks5://$TARGET_ADDR" 
                echo -e "${GREEN}已开启! APT 与当前 Session 现已走代理。${NC}" 
                sleep 1
                ;;
            2)
                read -p "请输入 IP (默认 $DEFAULT_IP): " IN_IP [cite: 8]
                read -p "请输入端口 (默认 $DEFAULT_PORT): " IN_PORT [cite: 8]
                TARGET_ADDR="${IN_IP:-$DEFAULT_IP}:${IN_PORT:-$DEFAULT_PORT}" [cite: 8]
                echo "Acquire::http::Proxy \"http://$TARGET_ADDR\";" > $APT_CONF [cite: 8, 9]
                echo "Acquire::https::Proxy \"http://$TARGET_ADDR\";" >> $APT_CONF [cite: 9, 10]
                export http_proxy="http://$TARGET_ADDR" [cite: 10]
                export https_proxy="http://$TARGET_ADDR" [cite: 10]
                echo -e "${GREEN}配置已更新为 $TARGET_ADDR${NC}" [cite: 10]
                sleep 1
                ;;
            3)
                [ -f "$APT_CONF" ] && rm "$APT_CONF" [cite: 11]
                unset http_proxy https_proxy all_proxy [cite: 11]
                echo -e "${RED}代理配置已清除。${NC}" [cite: 11]
                sleep 1
                ;;
            4) continue ;; [cite: 12]
            5) echo "退出助手。"; break ;; [cite: 13]
            *) echo -e "${RED}无效选项${NC}"; sleep 1 ;; [cite: 14]
        esac
    done
}

# 自动执行
proxy_manager
