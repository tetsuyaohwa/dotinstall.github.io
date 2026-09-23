# video-factory 環境構築スクリプト (Windows)
# 何度実行しても安全です。入っているものはスキップし、無いものだけ winget で入れます。
# 実行方法は README.md の「Windows での手順」を見てください。

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Update-PathFromRegistry {
    # winget で入れた直後でも新しいコマンドを使えるように PATH を読み直す
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Get-FirstLine($cmd, $args_) {
    try { return ((& $cmd @args_ 2>&1) | Select-Object -First 1).ToString().Trim() } catch { return $null }
}

function Install-WithWinget($id) {
    Write-Host "  -> winget で $id をインストールします（確認画面が出たら「はい」を押してください）" -ForegroundColor Yellow
    winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
    Update-PathFromRegistry
}

Write-Host ''
Write-Host '=== video-factory 環境チェックを開始します ===' -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host 'winget が見つかりません。Microsoft Store で「アプリ インストーラー」を更新してから、もう一度実行してください。' -ForegroundColor Red
    return
}

# --- 各ツールの確認方法 ---
function Test-Node   { Get-Command node -ErrorAction SilentlyContinue }
function Test-Python {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        $v = Get-FirstLine 'py' @('-3.12', '--version')
        if ($v -match '^Python 3\.12') { return $true }
    }
    return $false
}
function Test-Ffmpeg { Get-Command ffmpeg -ErrorAction SilentlyContinue }
function Test-Git    { Get-Command git -ErrorAction SilentlyContinue }
function Get-VoicevoxPath {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\VOICEVOX\VOICEVOX.exe",
        "$env:ProgramFiles\VOICEVOX\VOICEVOX.exe"
    )
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    return $null
}

$tools = @(
    @{ Name = 'Node.js';     Id = 'OpenJS.NodeJS.LTS';             Test = { Test-Node };   Purpose = '動画のグラフや画面をプログラムで作るためのエンジン（Remotion などを動かす土台）' },
    @{ Name = 'Python 3.12'; Id = 'Python.Python.3.12';            Test = { Test-Python }; Purpose = 'CSVなどのデータを集計・加工して、動画に載せる数字を用意するため' },
    @{ Name = 'ffmpeg';      Id = 'Gyan.FFmpeg';                   Test = { Test-Ffmpeg }; Purpose = '画像・音声・BGMをつなげて最終的な mp4 動画に書き出すため' },
    @{ Name = 'VOICEVOX';    Id = 'HiroshibaKazuyuki.VOICEVOX.CPU'; Test = { Get-VoicevoxPath }; Purpose = '台本を無料の日本語ナレーション音声に変換するため（商用利用はキャラ毎の規約を確認）' },
    @{ Name = 'Git';         Id = 'Git.Git';                       Test = { Test-Git };    Purpose = 'プロジェクトを GitHub に保存し、新しいPC（Mac）へ引き継ぐため' }
)

$results = @()
foreach ($t in $tools) {
    Write-Host ''
    Write-Host "[$($t.Name)] を確認中..."
    $status = 'すでに入っていました'
    if (-not (& $t.Test)) {
        Install-WithWinget $t.Id
        if (& $t.Test) { $status = '今回インストールしました' } else { $status = '失敗（下のメモを参照）' }
    }
    Write-Host "  $status" -ForegroundColor Green
    $results += [pscustomobject]@{ Name = $t.Name; Status = $status; Purpose = $t.Purpose }
}

# --- バージョン取得 ---
Update-PathFromRegistry
$versions = @{
    'Node.js'     = Get-FirstLine 'node'   @('--version')
    'Python 3.12' = Get-FirstLine 'py'     @('-3.12', '--version')
    'ffmpeg'      = Get-FirstLine 'ffmpeg' @('-version')
    'VOICEVOX'    = (Get-VoicevoxPath)
    'Git'         = Get-FirstLine 'git'    @('--version')
}

# --- 作業フォルダ作成（OneDrive にドキュメントが移動されていても正しい場所を使う） ---
$docs = [Environment]::GetFolderPath('MyDocuments')
$workDir = Join-Path $docs 'video-factory'
if (-not (Test-Path $workDir)) {
    New-Item -ItemType Directory -Path $workDir | Out-Null
    Write-Host ''
    Write-Host "作業フォルダを作りました: $workDir" -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host "作業フォルダはすでにあります: $workDir" -ForegroundColor Green
}

# --- レポート ---
$lines = @()
$lines += '=== video-factory 環境レポート ==='
$lines += "日時: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$lines += "作業フォルダ: $workDir"
$lines += ''
foreach ($r in $results) {
    $lines += "■ $($r.Name) : $($r.Status)"
    $lines += "   バージョン/場所: $($versions[$r.Name])"
    $lines += "   何のため: $($r.Purpose)"
}
$report = $lines -join "`r`n"
$reportPath = Join-Path $workDir 'setup-report.txt'
[System.IO.File]::WriteAllText($reportPath, $report, (New-Object System.Text.UTF8Encoding $true))

Write-Host ''
Write-Host $report
Write-Host ''
Write-Host "この内容は $reportPath にも保存しました。" -ForegroundColor Cyan
Write-Host '↑ の「=== video-factory 環境レポート ===」から下を全部コピーして Claude に貼り付けてください。' -ForegroundColor Cyan
if ($results.Status -contains '失敗（下のメモを参照）') {
    Write-Host 'メモ: 失敗があった場合は、PowerShell を一度閉じて開き直し、同じコマンドをもう一度実行してください。それでもダメならその画面をそのまま Claude に貼ってください。' -ForegroundColor Yellow
}
