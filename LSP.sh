#!/bin/bash

# 定义颜色
RED='\033[31m'    # 红色
GREEN='\033[32m'  # 绿色
YELLOW='\033[33m' # 黄色
RESET='\033[0m'   # 重置颜色

# Root权限验证
[ $(id -u) -eq 0 ] || {
	echo -e "${RED}\n必须使用Root权限执行!${RESET}"
	exit 1
}

# 检查 ssh-keygen 是否可用
if ! command -v ssh-keygen >/dev/null 2>&1; then
	echo -e "${RED}\n请使用 MT 管理器扩展包环境执行！${RESET}"
	exit 1
fi

# 记录脚本开始的时间戳
START_TIME=$(date +%s)

# 默认密钥位置
route="/data/local/tmp/ssh"
key="id_ed25519"
mkdir -p "$route"
KEY_PATH=${route}${key}

# 输出欢迎信息
echo -e "${GREEN}\n欢迎使用辅助签名脚本\nby 传说中的小菜叶\nQQ群：642850968${RESET}\n"

# 获取当前时间并格式化
current_time=$(date "+%Y年-%m月-%d日 %H时:%M分:%S秒")

# 输出当前时间
echo -e "${GREEN}当前时间: ${current_time}${RESET}\n"

# 提示用户输入邮箱
echo -e -n "${YELLOW}请输入你 Github 绑定的邮箱：${RESET} "
read EMAIL
echo

# 检查邮箱格式
if ! echo "${EMAIL}" | grep -E -q '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'; then
	echo -e "${RED}邮箱格式不正确，请输入有效的邮箱地址！${RESET}"
	exit 1
fi

# 生成密钥并保存
ssh-keygen -t ed25519 -C "${EMAIL}" -f "${KEY_PATH}" -N "" -q

# 显示公钥内容
echo -e "${GREEN}请将以下内容更新到 Github 中：${RESET}\n"
cat "${KEY_PATH}.pub"
echo

# 提示用户输入挑战码
echo -e -n "${YELLOW}请输入挑战码: ${RESET} "
read CHALLENGE_CODE
echo

# 使用用户提供的挑战码进行签名
SIGNED_OUTPUT=$(echo -n "${CHALLENGE_CODE}" | ssh-keygen -Y sign -n lsposed -f "${KEY_PATH}" 2>&1)

# 输出签名结果
echo -e "${GREEN}签名结果: ${RESET}${SIGNED_OUTPUT}\n"

# 计算并显示执行时间
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo -e "${GREEN}脚本运行完成，总耗时: ${ELAPSED_TIME} 秒\n${RESET}"
