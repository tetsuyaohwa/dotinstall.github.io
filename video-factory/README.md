# video-factory

YouTube 用の「データ動画」を自動で作る仕組みです。
どの PC（今の Windows でも、将来の Mac でも）でも同じ手順で作業を再開できるようにしてあります。

## フォルダの中身

| 場所 | 中身 | GitHub に保存する？ |
|---|---|---|
| `setup/` | 環境構築スクリプト（Windows 用・Mac 用） | する |
| `scripts/` | 動画を作るプログラム | する |
| `templates/` | 動画のデザイン・レイアウト | する |
| `data/` | 動画のもとになるデータ（CSV など、小さいもの） | する |
| `assets/` | ロゴ・フォント・BGM など（**再配布してよいものだけ**） | する |
| `.env.example` | 設定ファイルの見本 | する |
| `.env` | 本物の設定・APIキー | **しない**（秘密） |
| `output/` | 出来上がった動画 | **しない**（大きい・作り直せる） |
| `node_modules/` `.venv/` | 自動で入る部品 | **しない**（コマンド1つで作り直せる） |

詳しいルールと Mac への引き継ぎ手順は [docs/引き継ぎガイド.md](docs/引き継ぎガイド.md) を見てください。

## Windows での手順（最初の1回）

1. キーボードの **Windows キー** を押し、`powershell` と入力して **Enter**。青か黒の画面が開きます。
2. 下の枠の中を **まるごとコピー** して、その画面に **右クリックで貼り付け**、**Enter** を押します。

   ```powershell
   $f="$env:TEMP\vf-setup.ps1"; irm https://raw.githubusercontent.com/tetsuyaohwa/dotinstall.github.io/claude/friendly-lovelace-pqbop3/video-factory/setup/windows-setup.ps1 -OutFile $f; powershell -ExecutionPolicy Bypass -File $f
   ```

3. 途中で「このアプリがデバイスに変更を加えることを許可しますか？」と出たら **「はい」** を押します（数回出ます）。
4. 10〜20分ほどで「=== video-factory 環境レポート ===」が表示されます。そこから下を全部コピーして Claude に貼り付けてください。

何度実行しても安全です（入っているものは飛ばします）。

## Mac での手順（買い替えたとき）

1. `command + space` を押して `ターミナル` と入力し、**Enter**。
2. 下を貼り付けて **Enter**。

   ```bash
   curl -fsSL https://raw.githubusercontent.com/tetsuyaohwa/dotinstall.github.io/claude/friendly-lovelace-pqbop3/video-factory/setup/mac-setup.sh | bash
   ```

3. 出てきたレポートを Claude に貼り付けてください。
