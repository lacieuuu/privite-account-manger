Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "✨ 账号管理器 - 全自动终极部署脚本 (Windows 版) ✨" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 刷新环境变量
function Update-EnvironmentVariables {
    foreach ($level in "Machine", "User") {
        [Environment]::GetEnvironmentVariables($level).GetEnumerator() | Where-Object { $_.Key -match "^Path$" } | ForEach-Object {
            $env:Path += ";" + $_.Value
        }
    }
}

# 1. 环境检测
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在全自动安装 Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    Update-EnvironmentVariables
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在全自动安装 Node.js..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent --accept-package-agreements --accept-source-agreements
    Update-EnvironmentVariables
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ 系统需要刷新环境，请重新打开 PowerShell 运行命令即可！" -ForegroundColor Red
    exit
}
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "📦 正在安装 Vercel 工具..." -ForegroundColor Yellow
    npm install -g vercel
}

# 2. 拉取代码
$ProjectDir = "private-account-manager"
if (-not (Test-Path "index.html")) {
    if (Test-Path $ProjectDir) {
        Set-Location $ProjectDir
    } else {
        git clone https://github.com/lacieuuu/private-account-manager.git
        Set-Location $ProjectDir
    }
}

Write-Host "=======================================================" -ForegroundColor Cyan
$user_supabase_url = Read-Host "1/3 请输入你的 Supabase Project URL"
$user_supabase_key = Read-Host "2/3 请输入你的 Supabase anon public Key"
$user_vercel_token = Read-Host "3/3 请输入你的 Vercel Token (用于免登录)"

Write-Host "⚙️ 正在注入密钥 (强制 UTF-8 编码)..." -ForegroundColor Yellow

# 【核心修复】：强制以 UTF-8 无 BOM 格式读写，防止中文乱码
$filePath = (Get-Item "index.html").FullName
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$indexContent = [System.IO.File]::ReadAllText($filePath, $utf8NoBOM)

# 匹配英文占位符，避开乱码识别坑
$indexContent = $indexContent.Replace('REPLACE_WITH_URL', $user_supabase_url)
$indexContent = $indexContent.Replace('REPLACE_WITH_KEY', $user_supabase_key)

[System.IO.File]::WriteAllText($filePath, $indexContent, $utf8NoBOM)

Write-Host "☁️ 正在免登录推送到 Vercel..." -ForegroundColor Yellow
vercel --prod --yes --token="$user_vercel_token"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "🎉 部署完成！访问上方输出的 Vercel 网址即可。" -ForegroundColor White
