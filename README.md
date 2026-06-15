# loop2md

Microsoft Loop のページをクリップボード経由で取得し、Markdown + 画像ファイルへ変換するための PowerShell ツールです。

本リポジトリは、GUI 操作手順書を効率よく作るための実運用フローを想定しています。

- Loop で下書き・共同編集
- クリップボードの HTML を直接 Markdown 化
- 画像を `images/` にダウンロード
- 画像参照を相対パスへ統一
- 画像ファイル名を連番化（`001.png`, `002.png`, ...）
- 出力 Markdown ファイル名を自動決定（Loop タイトル or 最初の見出し要素）

## できること

- Loop 由来のクリップボード HTML を取得
- Pandoc で Markdown へ変換
- 生成された不要な装飾の自動除去
  - 単独行の `\`
  - `<div class="scriptor-paragraph">` / `</div>`
- 画像パスの正規化
  - 絶対パスや UNC を `images/xxx.png` に置換
- 画像ファイルの連番化
  - 参照順に `001.png` から採番
- 出力ファイル名の自動生成
  - 優先順位: `<title>` → 最初の見出し要素（`h1`〜`h6` / `role="heading"`）→ `output.md`
- UTF-8（BOM なし）で Markdown を保存

## 想定ユースケース

次のような場面で有効です。

- Loop で教材本文を共同編集したい
- Word / PowerPoint だけで手順書を作ると時間がかかる
- Markdown を正本として管理したい
- 画像注釈は後段（PowerPoint など）で行いたい

## 動作要件

- Windows
- PowerShell（Windows PowerShell 5.1 もしくは PowerShell 7 系）
- Pandoc（PATH が通っていること）
- Microsoft Loop からページ内容をコピーできること

## ファイル構成

- `loop2md.ps1`: 本体スクリプト
- `loop2md.bat`: 実行ラッパー（引数透過）
- `loop2md_form.ps1`: フォームアプリ本体
- `loop2md_form.bat`: フォームアプリ起動用ラッパー
- `save_clipboard_html.ps1`: クリップボード HTML 保存・デバッグ用
- `README.md`: 本ドキュメント

## 使い方

### 1. Loop ページをコピー

Loop で対象ページ（または必要範囲）をコピーします。

> 注意: 本ツールは、クリップボード内容が Loop 由来と判定できない場合は処理を中断します。

### 2. 変換を実行

#### GUI フォームアプリ（推奨）

```bat
loop2md_form.bat
```

フォームでは次を指定できます。

- 出力先（ベースフォルダ + 日時による自動設定 or 手動フォルダ名）
- 出力ファイル名（自動設定 or 指定ファイル名）
- 出力開始ボタン


#### コンソールアプリ（bat 経由）

```bat
loop2md.bat -OutDir .\lesson01
```

ファイル名を明示する場合:

```bat
loop2md.bat -OutDir .\lesson01 -OutFileName "手順書"
```

`loop2md.bat` は受け取った引数をそのまま `loop2md.ps1` に渡します。

#### コンソールアプリ（PowerShell）

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\loop2md.ps1 -OutDir .\lesson01
```

### 3. 生成物を確認

```text
lesson01/
├── 手順書.md
└── images/
    ├── 001.png
    ├── 002.png
    └── ...
```

## 引数

### `-OutDir`

出力先ディレクトリ。省略時はカレントディレクトリ。

例:

```bat
.\loop2md.bat -OutDir .\kensho01
```

### `-OutFileName`

出力する Markdown ファイル名を指定します（拡張子 `.md` は自動付与）。

省略した場合は、Loop ページの `<title>` または最初の見出し要素から自動生成します。

例:

```bat
.\loop2md.bat -OutDir .\kensho01 -OutFileName "lesson01"
```

## デバッグ

自動ファイル名が期待どおりにならない場合は、現在のクリップボード HTML を保存して確認できます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\save_clipboard_html.ps1 -OutFile .\kensho04\clipboard_dump.html
```

このスクリプトは、`<title>` と見出し検出結果をコンソールに表示します。

## 処理フロー

1. クリップボードの `HTML Format` を取得
2. Loop 由来らしさをチェック
3. 一時 HTML ファイルに UTF-8 で保存
4. Pandoc で Markdown + 画像抽出
5. 後処理
  - 出力ファイル名決定（自動 or 指定）
  - 不要タグ/記号除去
  - 画像ファイル連番化
  - 画像参照の相対化
6. 生成した `.md` を UTF-8（BOM なし）で保存

## エラーハンドリング

次のケースでは処理を停止します。

- STA で起動されていない
- `pandoc` が見つからない
- クリップボードに `HTML Format` がない
- クリップボード内容が Loop 由来と判定できない
- Pandoc の実行失敗

## 推奨ワークフロー（GUI 操作手順書作成）

1. スクリーンショット撮影
2. Loop で本文編集
3. 本ツールで Markdown + images 生成
4. 必要に応じて PowerPoint 等で画像注釈
5. Markdown 側の画像参照を差し替え
6. Git 管理 / 配布用変換（HTML, PDF, Word など）

## 運用上の注意

- 画像連番は生成時点の参照順に基づきます。
- 本ツールはバイブコーディングによって作成しています。
- 2026年6月15日時点における Microsoft Loop で動作を確認しています。仕様変更により、今後、正常に使用できなくなる恐れがあります。

## ライセンス

このプロジェクトは MIT ライセンスです。詳細は [LICENSE](LICENSE) を参照してください.
