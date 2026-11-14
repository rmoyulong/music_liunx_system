#!/bin/bash
# verify-config.sh —— 校验 7.3.x PREEMPT_RT 关键配置项
# 用法: ./j1900-verify-config.sh [.config路径]   默认当前目录 .config

CONFIG_FILE="${1:-.config}"
FAIL=0

# 检查函数: check <符号> <期望值>
# 期望值写 y 表示必须 =y；写 4 表示必须 =4（NR_CPUS 是整数）
check() {
    local sym="$1" expect="$2"
    local line
    line=$(grep -E "^${sym}=${expect}$" "$CONFIG_FILE" 2>/dev/null)

    if [ -n "$line" ]; then
        echo "[OK]    ${sym}=${expect}"
    else
        local actual
        actual=$(grep -E "^${sym}=" "$CONFIG_FILE" 2>/dev/null | head -n1)
        if [ -z "$actual" ]; then
            actual="(未设置)"
        fi
        echo "[ERROR] ${sym}=${expect} 缺失，实际: ${actual}"
        FAIL=1
    fi
}

echo "===== 校验配置文件: ${CONFIG_FILE} ====="

check CONFIG_PREEMPT_RT  y
check CONFIG_EXPERT      y
check CONFIG_KERNEL_ZSTD y

echo "======================================"
if [ "$FAIL" -ne 0 ]; then
    echo "结果: 存在 [ERROR]，请检查上述项。"
    exit 1
else
    echo "结果: 全部 [OK]。"
    exit 0
fi