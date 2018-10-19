# nodeStack
node.js服务器自动安装脚本
用于阿里云 ECS-centos-7.4，其他环境未测试

已有功能：
- 采用 whiptail 实现更加友好的交互式操作
- 选择是否执行系统软件更新
- 检查并创建数据目录
- 选择是否安装 Git
- 选择是否安装 nginx
- 启动 nginx 服务并设为自动启动
- 选择要安装的 Node.js 版本(V8.x / V10.x)
- 选择要安装的 MongoDB 版本(V4.0 / V3.6)
- 启动 mongod 服务并设为自动启动
- 选择关闭 CentOS 系统的 THP
- 安装全局 npm 模块

待添加功能：
- 配置 yum 的 repo 源
