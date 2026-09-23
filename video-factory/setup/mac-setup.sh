#!/bin/bash
# video-factory 環境構築スクリプト (Mac)
# 何度実行しても安全です。入っているものはスキップし、無いものだけ Homebrew で入れます。
# 実行方法は README.md の「Mac での手順」を見てください。

set -u

echo ""
echo "=== video-factory 環境チェックを開始します (Mac) ==="

# --- Homebrew（Mac 用のアプリ管理ツール。Windows の winget にあたる） ---
load_brew() {
  # Apple シリコン / Intel の両方に対応
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  if [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
}
load_brew
if ! command -v brew >/dev/null 2>&1; then
  echo ""
  echo "Homebrew を入れます。"
  echo "「Password:」と出たら Mac のログインパスワードを入力して Enter（入力中は何も表示されませんが正常です）。"
  echo "「Press RETURN」と出たら Enter を押してください。"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew
fi
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew のインストールに失敗しました。この画面をそのまま Claude に貼ってください。"
  exit 1
fi

# 次回ターミナルを開いたときも brew が使えるように設定を残す
BREW_LINE="eval \"\$($(command -v brew) shellenv)\""
# （zsh と bash のどちらを使っていても効くように両方に書く）
for rc in "$HOME/.zprofile" "$HOME/.bash_profile"; do
  touch "$rc"
  grep -qF "$BREW_LINE" "$rc" || echo "$BREW_LINE" >> "$rc"
done

# --- 各ツール ---
echo ""
echo "Node.js / Python 3.12 / ffmpeg / Git を確認・インストールします..."
brew install node python@3.12 ffmpeg git

# VOICEVOX は Homebrew 公式ではなく VOICEVOX 公式の tap から入れる
voicevox_installed() { [ -d "/Applications/VOICEVOX.app" ] || [ -d "$HOME/Applications/VOICEVOX.app" ]; }
if ! voicevox_installed; then
  echo ""
  echo "VOICEVOX をインストールします（サイズが大きいので時間がかかります）..."
  brew tap VOICEVOX/voicevox && brew install --cask voicevox
fi

# --- 作業フォルダ ---
WORK_DIR="$HOME/Documents/video-factory"
mkdir -p "$WORK_DIR"

# --- レポート ---
REPORT="$WORK_DIR/setup-report.txt"
{
  echo "=== video-factory 環境レポート (Mac) ==="
  echo "日時: $(date '+%Y-%m-%d %H:%M')"
  echo "Mac: $(sw_vers -productVersion) / $(uname -m)"
  echo "作業フォルダ: $WORK_DIR"
  echo ""
  echo "■ Node.js     : $(node --version 2>/dev/null || echo '見つかりません')"
  echo "   何のため: 動画のグラフや画面をプログラムで作るための土台"
  echo "■ Python 3.12 : $(python3.12 --version 2>/dev/null || echo '見つかりません')"
  echo "   何のため: CSV などのデータを集計・加工して、動画に載せる数字を用意するため"
  echo "■ ffmpeg      : $(ffmpeg -version 2>/dev/null | head -n 1 || true)"
  echo "   何のため: 画像・音声・BGM をつなげて最終的な mp4 動画に書き出すため"
  echo "■ VOICEVOX    : $(voicevox_installed && echo 'インストール済み' || echo '見つかりません')"
  echo "   何のため: 台本を無料の日本語ナレーション音声に変換するため"
  echo "■ Git         : $(git --version 2>/dev/null || echo '見つかりません')"
  echo "   何のため: プロジェクトを GitHub に保存し、次の PC へ引き継ぐため"
} > "$REPORT"

echo ""
cat "$REPORT"
echo ""
echo "この内容は $REPORT にも保存しました。"
echo "↑ の「=== video-factory 環境レポート (Mac) ===」から下を全部コピーして Claude に貼り付けてください。"
