#!/system/bin/sh
TARGET_SERVICE="com.abilvcha.main/com.lvcha.main.LchaService"

# 安卓16强制使用前台服务启动，普通服务会被系统拦截
am start-foreground-service -n "${TARGET_SERVICE}"
