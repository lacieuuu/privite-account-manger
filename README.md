# 个人账号管理工具
简易云同步账号管理工具：支持跨设备云端互通，内置邮箱生成器，支持邮箱名和密码自动生成并保存至库、批量粘贴导入、改密及 CSV 备份；支持邮箱、网站账号、API 库分类管理及快速搜索；私有化部署，保护隐私。

# 使用步骤
### 第一阶段：准备工作
在开始部署前，请在手机或电脑上准备好以下三项密钥：
 1. **JSONBin BIN_ID**（数据存储库 ID）
   * 访问 jsonbin.io 注册账号。
   * 在左侧导航栏点击 **Bins**，选择 **Create a bin**。
   * 在编辑器中输入一对大括号 {} 并保存。
   * 复制生成的 **Bin ID**。
 2. **JSONBin MASTER_KEY**（管理密钥）
   * 在左侧导航栏点击 **API Keys**。
   * 复制 **Master Key**。
 3. **Vercel Token**（免登录令牌）
   * 登录 Vercel 官网。
   * 进入 **Tokens** 设置页面。
   * 点击 **Create**，输入名称（如 auto-deploy）后生成。
   * 复制该令牌，用于在终端执行免登录部署。
### 第二阶段：环境搭建
#### 电脑端 (Windows / Mac / Linux)
 1. **安装 Node.js**：前往 Node.js 官网安装长期支持版（LTS）。
 2. **安装 Git**：前往 Git 官网完成安装。
 3. **安装 Vercel CLI**：打开终端（cmd 或 PowerShell），执行以下命令：
   ```bash
   npm install -g vercel
   
   ```
#### 手机端 (Termux)
 1. **安装环境包**：打开 Termux，依次执行以下命令：
   ```bash
   pkg update && pkg upgrade -y
   pkg install git nodejs -y
   
   ```
 2. **安装 Vercel CLI**：在 Termux 中执行：
   ```bash
   npm install -g vercel
   
   ```
### 第三阶段：部署操作
请在终端中依次执行以下命令：
 1. **克隆项目代码**
   ```bash
   git clone https://github.com/lacieuuu/private-account-manager.git
   cd private-account-manager
   
   ```
 2. **运行部署脚本**
   ```bash
   bash deploy.sh
   
   ```
 3. **完成配置**
   * 根据终端弹出的提示，依次粘贴 **BIN_ID**、**MASTER_KEY** 和 **Vercel Token** 并按回车。
   * 脚本将自动完成密钥集成与发布，部署成功后会返回工具的访问网址。
