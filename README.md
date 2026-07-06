# loop2md

Microsoft Loop のページをクリップボード経由で取得し、Markdown + 画像ファイルへ変換するための PowerShell ツールです。

本リポジトリは、GUI 操作手順書を効率よく作るための実運用フローを想定しています。

- Loop で下書き・共同編集
- クリップボードの HTML を直接 Markdown 化

## できること

- Loop 由来のクリップボード HTML を取得
- 画像を `images/` にダウンロード
  - 画像参照を相対パスへ統一
  - 画像ファイル名を連番化（`001.png`, `002.png`, ...）
- 出力 Markdown ファイル名を自動決定（Loop タイトル or 最初の見出し要素）
- 生成された不要な装飾の自動除去
  - 単独行の `\`
  - `<div class="scriptor-paragraph">` / `</div>`

## 動作要件

- Windows
- PowerShell（Windows PowerShell 5.1 もしくは PowerShell 7 系）
- Pandoc（PATH が通っていること）
  - https://pandoc.org/installing.html
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
出力フォルダ/
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
.\loop2md.bat -OutDir .\export
```

### `-OutFileName`

出力する Markdown ファイル名を指定します（拡張子 `.md` は自動付与）。

省略した場合は、Loop ページの `<title>` または最初の見出し要素から自動生成します。

例:

```bat
.\loop2md.bat -OutDir .\export -OutFileName "手順書"
```

## デバッグ

自動ファイル名が期待どおりにならない場合は、現在のクリップボード HTML を保存して確認できます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\save_clipboard_html.ps1 -OutFile .\export\clipboard_dump.html
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

## 運用上の注意

- 画像連番は生成時点の参照順に基づきます。
- 本ツールはバイブコーディングによって作成しています。
- 2026年6月15日時点における Microsoft Loop で動作を確認しています。仕様変更により、今後、正常に使用できなくなる恐れがあります。

## ライセンス

このプロジェクトは MIT ライセンスです。詳細は [LICENSE](LICENSE) を参照してください.
