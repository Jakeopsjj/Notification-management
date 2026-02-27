#!/system/bin/sh
TARGET_PKG="com.abilvcha.main"

# 强制停止原有进程，确保冷启动
am force-stop "${TARGET_PKG}"
sleep 0.5

# 自动获取主Activity，安卓16专属启动参数
MAIN_ACTIVITY=$(cmd package resolve-activity --brief "${TARGET_PKG}" | tail -n 1)
am start-activity -n "${MAIN_ACTIVITY}" \
    -f 0x10000000 \
    --activity-clear-top \
    --activity-no-user-action-required
