#!/usr/bin/env bash
# Author: yulinzhihou <yulinzhihou@gmail.com>
# Forum:  https://gsgamesahre.com
# Project: https://github.com/yulinzhihou/gstlenv.git
# Date :  2021-07-11
# Notes:  GS_TL_Env for CentOS/RedHat 7+ Debian 10+ and Ubuntu 18+
# comment: 根据env文件的环境变量，修改对应的配置文件，复制配置文件替换到指定目录，并给与相应权限
docker ps --format "{{.Names}}" | grep gsserver >/dev/null
if [ $? -eq 0 ]; then
    # 颜色代码
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

    BASE_PATH="/root/.tlgame/config"
    GS_PROJECT_PATH="/tlgame"

    tar zxf ${BASE_PATH}/ini.tar.gz -C ${BASE_PATH}
    if [ ! -d "${GS_PROJECT_PATH}/billing/" ]; then
        mkdir -p ${GS_PROJECT_PATH}/billing/ && chown -R root:root ${GS_PROJECT_PATH} && chmod -R 777 ${GS_PROJECT_PATH}
    fi
    \cp -rf ${BASE_PATH}/billing ${GS_PROJECT_PATH}/billing/

    # 游戏内注册=0，登录器注册=1
    if [ ${IS_DLQ} == 1 ]; then
        sed -i "s/127.0.0.2/${BILLING_SERVER_IPADDR}/g" ${BASE_PATH}/ServerInfo.ini
    else
        sed -i "s/127.0.0.2/127.0.0.1/g" ${BASE_PATH}/ServerInfo.ini
    fi

    # 游戏配置文件
    if [ "${TL_MYSQL_PASSWORD}" != "123456" ]; then
        sed -i "s/DBPassword=123456/DBPassword=${TL_MYSQL_PASSWORD}/g" ${BASE_PATH}/LoginInfo.ini
        sed -i "s/DBPassword=123456/DBPassword=${TL_MYSQL_PASSWORD}/g" ${BASE_PATH}/ShareMemInfo.ini
        sed -i "s/123456/${TL_MYSQL_PASSWORD}/g" ${BASE_PATH}/odbc.ini
        sed -i "s/123456/${TL_MYSQL_PASSWORD}/g" ${BASE_PATH}/config.yaml
    fi

    if [ ${BILLING_PORT} != "21818" ]; then
        sed -i "s/21818/${BILLING_PORT}/g" ${BASE_PATH}/config.yaml
        sed -i "s/Port0=21818/Port0=${BILLING_PORT}/g" ${BASE_PATH}/ServerInfo.ini
    fi

    if [ "${LOGIN_PORT}" != "13580" ]; then
        sed -i "s/Port0=13580/Port0=${LOGIN_PORT}/g" ${BASE_PATH}/ServerInfo.ini
    fi

    if [ "${SERVER_PORT}" != "15680" ]; then
        sed -i "s/Port0=15680/Port0=${SERVER_PORT}/g" ${BASE_PATH}/ServerInfo.ini
    fi

    #复制到已经修改好的文件到指定容器
    \cp -rf ${BASE_PATH}/config.yaml ${GS_PROJECT_PATH}/billing/
    \cp -rf ${BASE_PATH}/LoginInfo.ini ${BASE_PATH}/ShareMemInfo.ini ${BASE_PATH}/ServerInfo.ini ${GS_PROJECT_PATH}/tlbb/Server/Config/
    docker cp ${BASE_PATH}/odbc.ini gsserver:/etc
    docker cp /root/.tlgame/scripts/step.sh gsserver:/usr/local/bin/step
    # 复制配置文件
    docker cp /root/.tlgame/include/alter_point.sql gsmysql:/usr/local/bin/alter_point.sql
    docker cp /root/.tlgame/include/change_valid.sql gsmysql:/usr/local/bin/change_valid.sql
    docker cp /root/.tlgame/include/change_invalid.sql gsmysql:/usr/local/bin/change_invalid.sql
    docker cp /root/.tlgame/include/gsmysqlRestore.sh gsmysql:/usr/local/bin/gsmysqlRestore.sh
    docker cp /root/.tlgame/include/gsset.sh gsmysql:/usr/local/bin/gsset.sh
    docker cp /root/.tlgame/include/gssetvalid.sh gsmysql:/usr/local/bin/gssetvalid.sh

    #每次更新后，先重置更改过的文件
    #sed -i 's/^else$/else\n  \/home\/billing\/billing up -d/g' ${GS_PROJECT_PATH}/tlbb/run.sh && \
    sed -i 's/exit$/tail -f \/dev\/null/g' ${GS_PROJECT_PATH}/tlbb/run.sh &&
        cd ${BASE_PATH}/ &&
        rm -rf ${BASE_PATH}/*.ini ${BASE_PATH}/config.yaml ${BASE_PATH}/billing
    chown -R root:root ${GS_PROJECT_PATH} && chmod -R 777 ${GS_PROJECT_PATH}
    if [ $? -eq 0 ]; then
        echo -e "${CSUCCESS}配置文件已经写入成功，可以执行【runtlbb】进行开服操作！！${CEND}"
        exit 0
    else
        echo -e "${CRED}配置文件写入失败！${CEND}"
        exit 1
    fi
else
    echo -e "${CRED}环境毁坏，需要重新安装或者移除现有的环境重新安装！！！${CEND}"
    exit 1
fi
