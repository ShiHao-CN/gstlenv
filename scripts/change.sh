#!/usr/bin/env bash
# Author: yulinzhihou <yulinzhihou@gmail.com>
# Forum:  https://gsgamesahre.com
# Project: https://github.com/yulinzhihou/gstlenv.git
# Date :  2021-02-01
# Notes:  GS_TL_Env for CentOS/RedHat 7+ Debian 10+ and Ubuntu 18+
# comment: 换版本
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
  # 换端前，先备份版本与数据库
  function backup_tlbb() {
    backup all
  }

  function main() {
    docker stop $(docker ps -a -q) &&
      docker rm $(docker ps -a -q) &&
      rm -rf /tlgame/tlbb/* &&
      untar &&
      cd ${ROOT_PATH}/${GSDIR} &&
      docker-compose up -d &&
      setini &&
      runtlbb
    if [ $? -eq 0 ]; then
      echo -e "${CSUCCESS}换端成功，请耐心等待几分钟后，建议使用：【runtop】查看开服的情况！${CEND}"
      exit 0
    else
      echo -e "${CRED}换端失败！请检查配置！${CEND}"
      exit 1
    fi
  }

  if [ ! -f /root/tlbb.tar.gz ] && [ ! -f /root/tlbb.zip ]; then
    echo "${CRED}新服务端版本文件不存在，请先上传服务端 tlbb.tar.gz 或者 tlbb.zip 到 /root 目录下再执行换端操作！${CEND}"
    exit 1
  fi

  while :; do
    echo
    for ((time = 5; time >= 0; time--)); do
      echo -ne "\r正准备换端操作，会清除所有数据，建议在执行前先进行【backup】命令进行备份，剩余 ${CRED}$time${CEND} 秒，可以在计时结束前，按 CTRL+C 退出！\r"
      sleep 1
    done
    echo -ne "\n\r"
    echo -ne "${CYELLOW}正在重构环境，换版本…………${CEND}"
    backup_tlbb && main
  done
else
  echo "${CRED}环境毁坏，需要重新安装或者移除现有的环境重新安装！！！${CEND}"
  exit 1
fi
