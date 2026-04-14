# 强制解除 Windows 脚本执行限制（解决无法加载 npm.ps1 的红字问题）
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "✨ 账号管理器 - 全自动终极部署脚本 (Windows 版) ✨" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 刷新环境变量函数
function Update-Env {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 1. 环境检测与自动安装
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在自动安装 Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    Update-Env
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在自动安装 Node.js..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements --accept-source-agreements
    Update-Env
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ 环境已安装但需刷新，请关闭此窗口重新运行命令即可！" -ForegroundColor Red
    exit
}
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在通过 npm 安装 Vercel 工具..." -ForegroundColor Yellow
    npm install -g vercel
}

# 2. 获取代码
$ProjectDir = "private-account-manager"
if (-not (Test-Path "index.html")) {
    if (Test-Path $ProjectDir) { Set-Location $ProjectDir }
    else { git clone https://github.com/lacieuuu/private-account-manager.git; Set-Location $ProjectDir }
}

Write-Host "=======================================================" -ForegroundColor Cyan
$user_url = Read-Host "1/3 请输入 Supabase URL"
$user_key = Read-Host "2/3 请输入 Supabase Key"
$user_token = Read-Host "3/3 请输入 Vercel Token"

Write-Host "⚙️ 正在注入密钥 (UTF-8)..." -ForegroundColor Yellow

# 【核心修复】：强制 UTF-8 读写防止乱码
$filePath = (Get-Item "index.html").FullName
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$content = [System.IO.File]::ReadAllText($filePath, $utf8NoBOM)
$content = $content.Replace('REPLACE_WITH_URL', $user_url).Replace('REPLACE_WITH_KEY', $user_key)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBOM)

Write-Host "☁️ 正在生成唯一随机网址并推送到 Vercel..." -ForegroundColor Yellow

# 生成 6 位随机后缀防止域名冲突
$Suffix = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
$UniqueName = "private-account-manager-$Suffix"

vercel --prod --yes --name "$UniqueName" --token="$user_token"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "🎉 部署完成！请保存上方输出的 https://$UniqueName.vercel.app 网址" -ForegroundColor Green
