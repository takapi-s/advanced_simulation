# PowerShell: results/report.md を PDF にビルド
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Md = Join-Path $Root "results\report.md"
$Html = Join-Path $Root "results\report.html"
$Pdf = Join-Path $Root "results\report.pdf"
$Css = Join-Path $Root "results\report.css"

$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandoc) {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Push-Location (Split-Path $Md)
pandoc "report.md" -o "report.html" --standalone --embed-resources --css "report.css"
Pop-Location

$Edge = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $Edge) {
    Write-Error "Microsoft Edge が見つかりません。report.html をブラウザで開いて PDF 保存してください。"
}

$HtmlPath = (Resolve-Path $Html).Path
$HtmlUri = "file:///" + ($HtmlPath -replace '\\', '/')
& $Edge --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="$Pdf" $HtmlUri 2>$null
Start-Sleep -Seconds 3

if (Test-Path $Pdf) {
    Write-Host "Generated: $Pdf"
} else {
    Write-Error "PDF の生成に失敗しました。"
}
