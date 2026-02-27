#!/system/bin/sh
# Magisk/KernelSU 模块安装脚本
# 功能：自动创建目标目录、移动脚本文件、设置root权限+755权限

############################## 配置项（无需修改，完全匹配你的需求） ##############################
# 目标文件夹路径
TARGET_DIR="/data/adb/boot-completed.d"
# 模块内的两个脚本路径（默认放在模块压缩包根目录，和customize.sh同级）
SRC_START_SH="$MODPATH/启动.sh"
SRC_SERVICE_SH="$MODPATH/服务.sh"
###################################################################################################

# 安装界面打印函数（Magisk/KernelSU通用）
ui_print "=========================================="
ui_print "  安卓16专属 开机脚本自动配置工具"
ui_print "=========================================="
ui_print ""

# 1. 创建目标文件夹，不存在则自动创建，已存在则不报错
ui_print "[1/4] 正在检查并创建目标文件夹..."
mkdir -p "${TARGET_DIR}"
if [ -d "${TARGET_DIR}" ]; then
    ui_print "✅ 目标文件夹创建/检查成功：${TARGET_DIR}"
else
    ui_print "❌ 错误：目标文件夹创建失败，请检查系统权限"
    abort "安装终止：文件夹创建失败"
fi

# 2. 给目标文件夹设置root权限+755权限，适配安卓16 SELinux规则
ui_print ""
ui_print "[2/4] 正在设置文件夹权限..."
chmod 0755 "${TARGET_DIR}"
chown 0:0 "${TARGET_DIR}"
chcon u:object_r:adb_data_file:s0 "${TARGET_DIR}"
ui_print "✅ 文件夹权限设置完成（root:root + 755）"

# 3. 检查模块内的脚本文件是否存在，避免文件缺失导致安装失败
ui_print ""
ui_print "[3/4] 正在检查模块内的脚本文件..."
# 检查启动.sh
if [ ! -f "${SRC_START_SH}" ]; then
    ui_print "❌ 错误：模块内未找到 启动.sh 脚本"
    ui_print "请确保 启动.sh 放在模块压缩包根目录，和customize.sh同级"
    abort "安装终止：脚本文件缺失"
fi
# 检查服务.sh
if [ ! -f "${SRC_SERVICE_SH}" ]; then
    ui_print "❌ 错误：模块内未找到 服务.sh 脚本"
    ui_print "请确保 服务.sh 放在模块压缩包根目录，和customize.sh同级"
    abort "安装终止：脚本文件缺失"
fi
ui_print "✅ 两个脚本文件检查通过，均存在"

# 4. 移动脚本文件到目标文件夹（强制覆盖已有同名文件），并设置权限
ui_print ""
ui_print "[4/4] 正在移动脚本并设置权限..."
# 移动启动.sh
mv -f "${SRC_START_SH}" "${TARGET_DIR}/"
if [ -f "${TARGET_DIR}/启动.sh" ]; then
    # 设置root所有者+755权限+SELinux上下文
    chmod 0755 "${TARGET_DIR}/启动.sh"
    chown 0:0 "${TARGET_DIR}/启动.sh"
    chcon u:object_r:adb_data_file:s0 "${TARGET_DIR}/启动.sh"
    ui_print "✅ 启动.sh 移动成功，权限设置完成"
else
    ui_print "❌ 错误：启动.sh 移动失败"
    abort "安装终止：文件移动失败"
fi

# 移动服务.sh
mv -f "${SRC_SERVICE_SH}" "${TARGET_DIR}/"
if [ -f "${TARGET_DIR}/服务.sh" ]; then
    # 设置root所有者+755权限+SELinux上下文
    chmod 0755 "${TARGET_DIR}/服务.sh"
    chown 0:0 "${TARGET_DIR}/服务.sh"
    chcon u:object_r:adb_data_file:s0 "${TARGET_DIR}/服务.sh"
    ui_print "✅ 服务.sh 移动成功，权限设置完成"
else
    ui_print "❌ 错误：服务.sh 移动失败"
    abort "安装终止：文件移动失败"
fi

# 安装完成提示
ui_print ""
ui_print "=========================================="
ui_print "🎉 所有配置执行完成！"
ui_print "📂 脚本存放路径：${TARGET_DIR}"
ui_print "🔐 权限配置：root所有者 + 755执行权限"
ui_print "=========================================="
