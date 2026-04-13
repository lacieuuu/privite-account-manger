Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "✨ 账号管理器 - 全自动终极部署脚本 (Windows 版) ✨" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 刷新环境变量的内部函数
function Update-EnvironmentVariables {
    foreach ($level in "Machine", "User") {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | Where-Object { $_.Key -match "^Path$" } | ForEach-Object {
            $env:Path += ";" + $_.Value
        }
    }
}

# 1. 检测并自动安装 Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📦 未检测到 Git，正在全自动安装..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    Update-EnvironmentVariables
}

# 2. 检测并自动安装 Node.js
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "📦 未检测到 Node.js，正在全自动安装..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements --accept-source-agreements
    Update-EnvironmentVariables
}

# 3. 拦截因环境变量未生效导致的报错
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ Node.js 刚刚安装完毕，系统需要刷新！`n👉 请关闭当前 PowerShell 窗口，重新打开后再运行一次刚刚的命令即可继续！" -ForegroundColor Red
    exit
}

# 4. 检测并自动安装 Vercel CLI
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "📦 未检测到 Vercel 工具，正在通过 npm 全局安装..." -ForegroundColor Yellow
    npm install -g vercel
}

# 5. 拉取/更新代码
$ProjectDir = "private-account-manager"
if (-not (Test-Path "$ProjectDir\index.html")) {
    Write-Host "📥 正在拉取项目代码..." -ForegroundColor Yellow
    if (Test-Path $ProjectDir) {
        Set-Location $ProjectDir
        git pull origin main
    } else {
        git clone https://github.com/lacieuuu/private-account-manager.git
        Set-Location $ProjectDir
    }
} else {
    Write-Host "✅ 已在项目目录中" -ForegroundColor Green
}

Write-Host "=======================================================" -ForegroundColor Cyan
$user_supabase_url = Read-Host "1/3 请输入你的 Supabase Project URL"
$user_supabase_key = Read-Host "2/3 请输入你的 Supabase anon public Key"
$user_vercel_token = Read-Host "3/3 请输入你的 Vercel Token (用于免登录)"

Write-Host "⚙️ 正在将密钥注入你的专属网页..." -ForegroundColor Yellow
$indexContent = Get-Content -Path index.html -Raw
$indexContent = $indexContent -replace '在这里填入你的_Project_URL', $user_supabase_url
$indexContent = $indexContent -replace '在这里填入你的_anon_public_Key', $user_supabase_key
Set-Content -Path index.html -Value $indexContent -Encoding UTF8

Write-Host "☁️ 正在免登录推送到 Vercel 生产环境，请稍候..." -ForegroundColor Yellow
vercel --prod --yes --token="$user_vercel_token"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "🎉 部署大功告成！" -ForegroundColor Green
Write-Host "👉 请复制上方输出的 Vercel 网址 (通常是 https://xxx.vercel.app) 访问你的平台。" -ForegroundColor White
