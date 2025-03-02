#!/usr/bin/env bash
# Author: yulinzhihou <yulinzhihou@gmail.com>
# Forum:  https://gsgamesahre.com
# Project: https://github.com/yulinzhihou/gstlenv.git
# Date :  2021-10-04
# Notes:  GS_TL_Env for CentOS/RedHat 7+ Debian 10+ and Ubuntu 18+
# comment: 查看当前配置项信息。需要在没人的时候查看，不然别人容易查看到你的关键信息
docker ps --format "{{.Names}}" | grep gsserver >/dev/null
if [ $? -eq 0 ]; then
  # 引入全局参数
  if [ -f /root/.gs/.env ]; then
    . /root/.gs/.env
  else
    . /usr/local/bin/.env
  fi
  # 颜色代码
  if [ -f ./color.sh ]; then
    . ${GS_PROJECT}/scripts/color.sh
  else
    . /usr/local/bin/color
  fi

  cat <<EOF
${CGREEN}
※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※
此命令只用于查看当前配置信息，不作任何修改。如需要重新设置，请执行【setconfig】命令
※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※
◎  数据库端口: $([ ${TL_MYSQL_PORT} == ${TL_MYSQL_DEFAULT_PORT} ] && echo ${TL_MYSQL_DEFAULT_PORT} || echo ${TL_MYSQL_PORT})
◎  数据库密码: $([ ${TL_MYSQL_PASSWORD} == ${TL_MYSQL_DEFAULT_PASSWORD} ] && echo ${TL_MYSQL_DEFAULT_PASSWORD} || echo ${TL_MYSQL_PASSWORD})
◎  验证端口: $([ ${BILLING_PORT} == ${BILLING_DEFAULT_PORT} ] && echo ${BILLING_DEFAULT_PORT} || echo ${BILLING_PORT})
◎  登录网关端口: $([ ${LOGIN_PORT} == ${LOGIN_DEFAULT_PORT} ] && echo ${LOGIN_DEFAULT_PORT} || echo ${LOGIN_PORT})
◎  游戏网关端口: $([ ${SERVER_PORT} == ${SERVER_DEFAULT_PORT} ] && echo ${SERVER_DEFAULT_PORT} || echo ${SERVER_PORT})
◎  网站端口: $([ ${WEB_PORT} == ${WEB_DEFAULT_PORT} ] && echo ${WEB_DEFAULT_PORT} || echo ${WEB_PORT})
◎  是否单服务器: $([ ${IS_DLQ} == '0' ] && echo "是" || echo "否")
◎  转发机器: $([ ${BILLING_DEFAULT_SERVER_IPADDR} == ${BILLING_SERVER_IPADDR} ] && echo ${BILLING_DEFAULT_SERVER_IPADDR} || echo ${BILLING_SERVER_IPADDR})
◎  服务端路径: $(echo ${TLBB_PATH})
※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※※
${CEND}
EOF
else
  echo "${CRED}环境毁坏，需要重新安装或者移除现有的环境重新安装！！！${CEND}"
  exit 1
fi
