# Communication Algorithms on FPGA 🛠️📡

[![Quartus](https://img.shields.io/badge/Quartus_II-13.0-0071C5?logo=intel)](https://www.intel.com)
[![FPGA](https://img.shields.io/badge/EP4CE10F17C8-Cyclone_IV-2EA44F)](https://www.intel.cn)
[![Verilog](https://img.shields.io/badge/HDL-Verilog_2012-00979D)](https://ieeexplore.ieee.org/document/8299595)

实现经典通信算法的FPGA硬件加速方案 | FPGA implementation of fundamental communication algorithms

## 项目目录 📂
- [背景](#背景-)

- [功能特性](#功能特性-)
- [硬件要求](#硬件要求-)
- [快速开始](#快速开始-)
- [项目结构](#项目结构-)
- [实现进度](#实现进度-%EF%B8%8F)

## 背景 📖
基于我在大二学习大三专业课“DSP与FPGA原理”，遇到了一位做FPGA相关教授，想要进入他的实验室学习，他给我出了以下算法的matlab代码，让我在FPGA上实现
- 2ASK
- 2FSK
- 2PSK
- 4ASK
- 16QAM
- 64QAM
- 802_11b
- BPSK
- ieee802_11a
- ieee802_11n
- OFDM
- QPSK     

本项目旨在构建可综合的通信算法Verilog IP核库，为以下场景提供硬件加速解决方案：
- 无线通信系统原型验证
- 通信原理教学实验平台
- 卫星通信基带处理
- 软件定义无线电(SDR)硬件加速




## 硬件平台 💻
### Altera Cyclone IV EP4CE10F17C8 

| 资源类型          | 数量/容量        | 备注                         |
|-------------------|------------------|------------------------------|
| 逻辑单元 (LE)     | 10,320           | 每个LE包含1个4输入LUT和1个触发器 |
| 存储块 (M9K)      | 46               | 每个M9K块包含9,216位（含校验位） |
| 乘法器 (18×18)    | 23               | 支持有符号/无符号乘法运算      |
| 全局时钟网络      | 10               | 支持全局时钟分配              |
| 用户I/O引脚       | 179              | 支持多种I/O标准               |
| PLL               | 4                | 支持时钟倍频、分频和相移      |
| 封装类型          | FBGA             | 256引脚                      |
| 工作温度          | 商业级 (0°C~85°C)|                              |
| 速度等级          | 8                | 表示器件性能等级              |
| 工艺节点          | 60nm             | 低功耗设计                   |

## 快速开始 ⚡
### 1. 克隆仓库
```bash
git clone https://github.com/KOSHM-Pig/communication-algorithm-onFPGA.git
cd communication-algorithm-onFPGA/2ASK
```
### 2. 打开quartus_prj下的qpf文件 （即QUARTUS II 项目）
### 3. 编译后仿真（推荐使用ModelSim进行仿真）


## 项目结构 📕
本仓库每个算法项目文件夹的结构如下：（例2ASK）
- 2ASK
  - doc （开发原理文档 包含波形图等信息）
  - quartus_prj （quartus ii 项目文件夹）
  - matlab (Matlab 仿真文件)
  - rtl （Verilog代码文件）
  - sim （仿真代码文件）

## 实现进度 🔋

- 2025.2.22 实现 2ASK 调制解调算法

