#!/bin/bash
# 定义全局变量
# $scripts_dir 脚本所在目录
scripts_dir=$(cd "$(dirname "$0")";pwd)
# $lede_dir lede所在目录
lede_dir=$(pwd)
# $conf 配置文件绝对地址
conf=$(pwd)/.config
# 配置文件大小
conf_size=`ls - l ${conf} | awk '{pring $5}'`
# 配置文件大小
std_size=$((1024*100))
# 编译线程数
threads=$(($(nproc) + 1))
# 开始时间
startTime=`date +"%Y-%m-%d %H:%M:%S"`
# 脚本开始，设置输出文字的颜色
# \033[32m 绿色
echo -e "\033[32m Strat $0 ! \033[0m"
# 判断配置文件文件大小与存在性
if [ !-f ${conf}] || [${conf_size} gt std_size=$((1024*100)) ];then
  make defconfig
fi
# 执行下载依赖包
echo -e "\033[32m Download Files \033[0m"
make download -j$threads
# 删除已存在的固件
if [ -d ${lede_dir}/bin ];then
  rm -rf ${lede_dir}/bin
fi
# 开始编译固件（包含简单的异常处理）
echo -e "\033[32m Start Compile Firmware \033[0m"
make -j${threads} || rm -rf ${lede_dir}/build_dir/target-x86_64_musl/linux-* && make -j1 V=s
# 结束时间
endTime=`date +"%Y-%m-%d %H:%M:%S"`
st=`date -d  "${startTime}" +%s`
et=`date -d  "${endTime}" +%s`
sumTime=$((${et}-${st}))
if [ !-f ${lede_dir}/bin/targets/**/**/sha256sums ];then
  echo -e "\033[31m ${startTime} ---> ${endTime},Compile Fail ! Total time is : ${sumTime} second. \033[0m"
  exit 1
fi
echo -e "\033[32m ${startTime} ---> ${endTime} $0 done ! Total time is : ${sumTime} second. \033[0m"
