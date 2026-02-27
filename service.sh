#!/system/bin/sh
# 安卓16专属 开机等待+子脚本执行脚本
# 必须放在Magisk/KernelSU的 /data/adb/service.d/ 目录，权限设为0755

# 1. root权限校验（安卓16必须root才能执行后续操作）
if [ "$(id -u)" -ne 0 ]; then
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] 错误：脚本未获取root权限，无法执行" >> /data/adb/boot_auto_start.log
    exit 1
fi

# 2. 原逻辑：等待Android系统完全开机完成
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
# 安卓16额外增加1秒缓冲，确保系统服务完全就绪
sleep 3

# ========== 配置项（无需修改，和你的路径完全匹配） ==========
SCRIPT_DIR="/data/adb/boot-completed.d"
START_APP_SCRIPT="${SCRIPT_DIR}/启动.sh"
START_SERVICE_SCRIPT="${SCRIPT_DIR}/服务.sh"
TARGET_PKG="com.abilvcha.main"
LOG_FILE="/data/adb/boot_auto_start.log"

# 日志函数
log_print() {
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] $1" >> "${LOG_FILE}"
}

log_print "===== 安卓16开机启动任务开始 ====="
log_print "系统开机完成，当前用户ID: $(id -u)"

# 3. 安卓16专属：提前给目标应用加入系统豁免，避免被系统拦截/休眠
log_print "正在给目标应用加入系统白名单"
# 加入电池优化豁免
cmd deviceidle whitelist +${TARGET_PKG}
# 设为活跃待机分组，避免被系统休眠
cmd package set-standby-bucket ${TARGET_PKG} active
# 允许应用后台弹出界面（厂商+系统双重限制）
appops set ${TARGET_PKG} SYSTEM_ALERT_WINDOW allow
appops set ${TARGET_PKG} BACKGROUND_START_ALLOWED allow
log_print "应用白名单配置完成"

# 4. 执行启动应用的脚本（启动.sh）
if [ -f "${START_APP_SCRIPT}" ]; then
    log_print "开始执行启动应用脚本：${START_APP_SCRIPT}"
    /system/bin/sh "${START_APP_SCRIPT}"
    if [ $? -eq 0 ]; then
        log_print "✅ 启动应用脚本执行成功"
    else
        log_print "❌ 启动应用脚本执行失败"
    fi
else
    log_print "❌ 错误：启动应用脚本不存在，请检查路径：${START_APP_SCRIPT}"
fi

# 安卓16专属：预留2秒缓冲，确保应用进程完全启动，再启动服务避免报错
sleep 2

# 5. 执行启动服务的脚本（服务.sh）
if [ -f "${START_SERVICE_SCRIPT}" ]; then
    log_print "开始执行启动服务脚本：${START_SERVICE_SCRIPT}"
    /system/bin/sh "${START_SERVICE_SCRIPT}"
    if [ $? -eq 0 ]; then
        log_print "✅ 启动服务脚本执行成功"
    else
        log_print "❌ 启动服务脚本执行失败"
    fi
else
    log_print "❌ 错误：启动服务脚本不存在，请检查路径：${START_SERVICE_SCRIPT}"
fi

log_print "===== 所有任务执行完毕 ====="
