#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# CentOS 常用软件一键安装脚本
# @author zhuangpf
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------ env

# Regular Color
export ENV_COLOR_BLACK="\033[0;30m"
export ENV_COLOR_RED="\033[0;31m"
export ENV_COLOR_GREEN="\033[0;32m"
export ENV_COLOR_YELLOW="\033[0;33m"
export ENV_COLOR_BLUE="\033[0;34m"
export ENV_COLOR_MAGENTA="\033[0;35m"
export ENV_COLOR_CYAN="\033[0;36m"
export ENV_COLOR_WHITE="\033[0;37m"
# Bold Color
export ENV_COLOR_B_BLACK="\033[1;30m"
export ENV_COLOR_B_RED="\033[1;31m"
export ENV_COLOR_B_GREEN="\033[1;32m"
export ENV_COLOR_B_YELLOW="\033[1;33m"
export ENV_COLOR_B_BLUE="\033[1;34m"
export ENV_COLOR_B_MAGENTA="\033[1;35m"
export ENV_COLOR_B_CYAN="\033[1;36m"
export ENV_COLOR_B_WHITE="\033[1;37m"
# Underline Color
export ENV_COLOR_U_BLACK="\033[4;30m"
export ENV_COLOR_U_RED="\033[4;31m"
export ENV_COLOR_U_GREEN="\033[4;32m"
export ENV_COLOR_U_YELLOW="\033[4;33m"
export ENV_COLOR_U_BLUE="\033[4;34m"
export ENV_COLOR_U_MAGENTA="\033[4;35m"
export ENV_COLOR_U_CYAN="\033[4;36m"
export ENV_COLOR_U_WHITE="\033[4;37m"
# Background Color
export ENV_COLOR_BG_BLACK="\033[40m"
export ENV_COLOR_BG_RED="\033[41m"
export ENV_COLOR_BG_GREEN="\033[42m"
export ENV_COLOR_BG_YELLOW="\033[43m"
export ENV_COLOR_BG_BLUE="\033[44m"
export ENV_COLOR_BG_MAGENTA="\033[45m"
export ENV_COLOR_BG_CYAN="\033[46m"
export ENV_COLOR_BG_WHITE="\033[47m"
# Reset Color
export ENV_COLOR_RESET="$(tput sgr0)"

# status
export ENV_YES=0
export ENV_NO=1
export ENV_SUCCEED=0
export ENV_FAILED=1


# ------------------------------------------------------------------------------ functions

# 显示打印日志的时间
SHELL_LOG_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
# 那个用户在操作
USER=$(whoami)
# 日志路径
LOG_PATH=${ENV_LOG_PATH:-/var/log/shell.log}
# 日志目录
LOG_DIR=${LOG_PATH%/*}

createLogFileIfNotExists() {
    if [[ ! -x "${LOG_PATH}" ]]; then
    mkdir -p "${LOG_DIR}"
    touch "${LOG_PATH}"
    fi
}

redOutput() {
    echo -e "${ENV_COLOR_RED} $@${ENV_COLOR_RESET}"
}
greenOutput() {
    echo -e "${ENV_COLOR_B_GREEN} $@${ENV_COLOR_RESET}"
}
yellowOutput() {
    echo -e "${ENV_COLOR_YELLOW} $@${ENV_COLOR_RESET}"
}
blueOutput() {
    echo -e "${ENV_COLOR_BLUE} $@${ENV_COLOR_RESET}"
}
magentaOutput() {
    echo -e "${ENV_COLOR_MAGENTA} $@${ENV_COLOR_RESET}"
}
cyanOutput() {
    echo -e "${ENV_COLOR_CYAN} $@${ENV_COLOR_RESET}"
}
whiteOutput() {
    echo -e "${ENV_COLOR_WHITE} $@${ENV_COLOR_RESET}"
}

logInfo() {
    echo -e "${ENV_COLOR_B_GREEN}[INFO] $@${ENV_COLOR_RESET}"
    createLogFileIfNotExists
    echo "[${SHELL_LOG_TIMESTAMP}] [${USER}] [INFO] [$0] $@" >> "${LOG_PATH}"
}
logWarn() {
    echo -e "${ENV_COLOR_B_YELLOW}[WARN] $@${ENV_COLOR_RESET}"
    createLogFileIfNotExists
    echo "[${SHELL_LOG_TIMESTAMP}] [${USER}] [WARN] [$0] $@" >> "${LOG_PATH}"
}
logError() {
    echo -e "${ENV_COLOR_B_RED}[ERROR] $@${ENV_COLOR_RESET}"
    createLogFileIfNotExists
    echo "[${SHELL_LOG_TIMESTAMP}] [${USER}] [ERROR] [$0] $@" >> "${LOG_PATH}"
}

printInfo() {
    echo -e "${ENV_COLOR_B_GREEN}[INFO] $@${ENV_COLOR_RESET}"
}
printWarn() {
    echo -e "${ENV_COLOR_B_YELLOW}[WARN] $@${ENV_COLOR_RESET}"
}
printError() {
    echo -e "${ENV_COLOR_B_RED}[ERROR] $@${ENV_COLOR_RESET}"
}

callAndLog () {
    $*
    if [[ $? -eq ${ENV_SUCCEED} ]]; then
        logInfo "$@"
        return ${ENV_SUCCEED}
    else
        logError "$@ EXECUTE FAILED"
        return ${ENV_FAILED}
    fi
}

# ------------------------------------------------------------------------------ functions

# 打印头部信息
printHeadInfo() {
printf "${C_B_BLUE}\n"
cat << EOF
###################################################################################
# 欢迎使用 Dunwu Shell 运维脚本
# 适用于 Linux CentOS 环境
# @author: zhuangpf
###################################################################################
EOF
printf "${C_RESET}\n"
}

# 打印尾部信息
printFootInfo() {
printf "${C_B_BLUE}\n"
cat << EOF
###################################################################################
# 脚本执行结束，感谢使用！
###################################################################################
EOF
printf "${C_RESET}\n"
}

# 检查操作系统环境
checkOsVersion() {
	if (($1 == 1)); then
		platform=`uname -i`
		if [[ ${platform} != "x86_64" ]]; then
			logError "脚本仅支持 64 位操作系统！"
			exit 1
		fi

		version=`cat /etc/redhat-release | awk '{print substr($4,1,1)}'`
		if [[ ${version} != 7 ]]; then
			logError "脚本仅支持 CentOS 7！"
			exit 1
		fi
	fi
}

menus=( "配置系统" "安装软件" "退出" )
selectAndExecTask() {
	printHeadInfo
	PS3="请输入命令编号："
	select item in "${menus[@]}"
	do
	case ${item} in
		"配置系统")
			./dunwu-sys.sh
			selectAndExecTask ;;
		"安装软件")
			./dunwu-soft.sh
			selectAndExecTask ;;
		"退出")
			printFootInfo
			exit 0 ;;
		*)
			logWarn "输入项不支持！"
			selectAndExecTask ;;
	esac
	break
	done
}


# ------------------------------------------------------------------------------ main

checkOsVersion 1
selectAndExecTask
