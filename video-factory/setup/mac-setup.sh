#!/bin/bash
# video-factory 環境構築スクリプト (Mac)
# 何度実行しても安全です。入っているものはスキップし、無いものだけ Homebrew で入れます。

set -u

echo ""
echo "=== video-factory 環境チェックを開始します (Mac) ==="

# Homebrew（Mac 用のアプリ管理ツール。Windows の winget にあたる）
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew を入れます（パスワードを聞かれたら Mac のログインパスワードを入力。画面には表示されません）"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple シリコン / Intel の両方に対応
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  if [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
fi

brew install node python@3.12 ffmpeg git
if [ ! -d "/Applications/VOICEVOX.app" ]; then
  brew install --cask voicevox || echo "VOICEVOX の自動インストールに失敗しました。https://voicevox.hiroshiba.jp/ から手動で入れてください。"
fi

WORK_DIR="$HOME/Documents/video-factory"
mkdir -p "$WORK_DIR"

echo ""
echo "=== video-factory 環境レポート (Mac) ==="
echo "作業フォルダ: $WORK_DIR"
echo "Node.js     : $(node --version 2>/dev/null)"
echo "Python 3.12 : $(python3.12 --version 2>/dev/null)"
echo "ffmpeg      : $(ffmpeg -version 2>/dev/null | head -n 1)"
echo "VOICEVOX    : $( [ -d /Applications/VOICEVOX.app ] && echo 'インストール済み' || echo '見つかりません')"
echo "Git         : $(git --version 2>/dev/null)"
echo ""
echo "↑ のレポートをコピーして Claude に貼り付けてください。"
