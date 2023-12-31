#!/bin/bash
# 测试参数
configs=${1} #"hichip_hc15xx_cb_b100_v30_lock,n,n;hichip_hc15xx_cb_b200_v21_xbmp5_c1,y,y"

# 遍历配置文件
echo "[TAG] build configs:"
configs_arr=(${configs//;/ });
for config in ${configs_arr[@]}
do
  # 分割配置编译项
  options_arr=(${config//,/ });
  config_name="${options_arr[0]}";
  # 选项变量定义
  item_name=${options_arr[0]}
  item_multiple_wifi=${options_arr[1]}
  item_disable_watchdog=${options_arr[2]}
  # 执行子编译脚本
  echo "${item_name}:"
  echo "------------------------------------------------------------------------"

  # 执行BL编译
  echo "[RUN] make O=bl_output ${item_name}_bl_defconfig"
  make O=bl_output ${item_name}_bl_defconfig
  echo "[RUN] make O=bl_output all"
  make O=bl_output all

  # 执行Config编译
  echo "[RUN] make ${item_name}_defconfig"
  make ${item_name}_defconfig

  # 修改output/.comfig权限
  chmod 777 output/.config

  # 判断是否关闭watchdog
  if [ "${item_disable_watchdog}" == "y" ];then
    # 关闭关门狗
    echo "[MODIFY] disable watchdog"
    sed -i "s/.*CONFIG_DRV_WDT.*/# CONFIG_DRV_WDT is not set/g" output/.config
    cat output/.config | egrep '.*CONFIG_DRV_WDT.*'
  fi

  # 判断是否编译多WiFi
  if [ "${item_multiple_wifi}" == "y" ];then
    # 备份配置
    cp output/.config output/.config.backup
    # 逐个WiFi编译
    echo "[MODIFY] enabled RTL8188FU"
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*/BR2_PACKAGE_PREBUILTS_RTL8188FU=y/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*/# BR2_PACKAGE_PREBUILTS_RTL8188EU is not set/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*/# BR2_PACKAGE_PREBUILTS_RTL8733BU is not set/g' output/.config
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*'
    echo "[RUN] make all"
    make all
    echo "[MODIFY] enabled RTL8188EU"
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*/# BR2_PACKAGE_PREBUILTS_RTL8188FU is not set/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*/BR2_PACKAGE_PREBUILTS_RTL8188EU=y/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*/# BR2_PACKAGE_PREBUILTS_RTL8733BU is not set/g' output/.config
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*'
    echo "[RUN] make all"
    make all
    echo "[MODIFY] Enabled RTL8733BU"
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*/# BR2_PACKAGE_PREBUILTS_RTL8188FU is not set/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*/# BR2_PACKAGE_PREBUILTS_RTL8188EU is not set/g' output/.config
    sed -i 's/.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*/BR2_PACKAGE_PREBUILTS_RTL8733BU=y/g' output/.config
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188FU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8188EU.*'
    cat output/.config | egrep '.*BR2_PACKAGE_PREBUILTS_RTL8733BU.*'
    echo "[RUN] make all"
    make all
    # 恢复配置
    mv output/.config.backup output/.config
  else
    echo "[RUN] make all"
    make all

  fi;

  echo "------------------------------------------------------------------------"
  echo ""
done
echo ""

# 暂停退出
#echo 按任意键继续
#read -n 1