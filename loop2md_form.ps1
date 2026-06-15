Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if ([Threading.Thread]::CurrentThread.ApartmentState -ne [Threading.ApartmentState]::STA) {
    [Windows.Forms.MessageBox]::Show(
        "このスクリプトは STA モードで実行する必要があります。`n例: powershell.exe -STA -File .\\loop2md_form.ps1",
        "loop2md フォーム",
        [Windows.Forms.MessageBoxButtons]::OK,
        [Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$converterPath = Join-Path $scriptRoot "loop2md.ps1"
if (-not (Test-Path -LiteralPath $converterPath)) {
    [Windows.Forms.MessageBox]::Show(
        "同じフォルダー内に loop2md.ps1 が見つかりません。",
        "loop2md フォーム",
        [Windows.Forms.MessageBoxButtons]::OK,
        [Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

function New-Label([string]$text) {
    $label = New-Object Windows.Forms.Label
    $label.AutoSize = $true
    $label.Text = $text
    return $label
}

$form = New-Object Windows.Forms.Form
$form.Text = "loop2md フォーム"
$form.StartPosition = "CenterScreen"
$form.AutoScaleMode = [Windows.Forms.AutoScaleMode]::Dpi
$baseFont = [Windows.Forms.SystemInformation]::MenuFont
$scaledSize = [single]($baseFont.Size * 1.2)
$fontStyle = [Drawing.FontStyle]$baseFont.Style
$form.Font = [Drawing.Font]::new($baseFont.FontFamily, $scaledSize, $fontStyle)
$form.AutoSize = $true
$form.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.Padding = New-Object Windows.Forms.Padding(12)

$root = New-Object Windows.Forms.TableLayoutPanel
$root.Dock = [Windows.Forms.DockStyle]::Fill
$root.AutoSize = $true
$root.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$root.ColumnCount = 1
$root.RowCount = 6
$root.Margin = New-Object Windows.Forms.Padding(0)
$root.Padding = New-Object Windows.Forms.Padding(0)
$form.Controls.Add($root)

$lblIntro = New-Object Windows.Forms.Label
$lblIntro.AutoSize = $true
$lblIntro.MaximumSize = New-Object Drawing.Size(700, 0)
$lblIntro.Text = @"
1) 事前に Loop ページの内容をクリップボードへコピーしてください。
2) 出力先フォルダーを設定します。
3) 出力ファイル名は自動または指定を選択します。
4) [開始] ボタンを押します。
"@
$lblIntro.Margin = New-Object Windows.Forms.Padding(0, 0, 0, 10)
$root.Controls.Add($lblIntro)

$groupOut = New-Object Windows.Forms.GroupBox
$groupOut.Text = "出力先"
$groupOut.AutoSize = $true
$groupOut.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$groupOut.Dock = [Windows.Forms.DockStyle]::Top
$groupOut.Padding = New-Object Windows.Forms.Padding(10)
$groupOut.Margin = New-Object Windows.Forms.Padding(0, 0, 0, 10)
$root.Controls.Add($groupOut)

$outLayout = New-Object Windows.Forms.TableLayoutPanel
$outLayout.AutoSize = $true
$outLayout.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$outLayout.ColumnCount = 3
$outLayout.RowCount = 4
$outLayout.Dock = [Windows.Forms.DockStyle]::Fill
$outLayout.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle([Windows.Forms.SizeType]::AutoSize)))
$outLayout.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle([Windows.Forms.SizeType]::Percent, 100)))
$outLayout.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle([Windows.Forms.SizeType]::AutoSize)))
$groupOut.Controls.Add($outLayout)

$lblBase = New-Label "保存場所"
$outLayout.Controls.Add($lblBase, 0, 0)

$txtBase = New-Object Windows.Forms.TextBox
$txtBase.Width = 520
$txtBase.Text = $scriptRoot
$txtBase.Anchor = [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$outLayout.Controls.Add($txtBase, 1, 0)

$btnBrowse = New-Object Windows.Forms.Button
$btnBrowse.Text = "参照..."
$btnBrowse.AutoSize = $true
$outLayout.Controls.Add($btnBrowse, 2, 0)

$chkDateFolder = New-Object Windows.Forms.CheckBox
$chkDateFolder.AutoSize = $true
$chkDateFolder.Text = "日付をフォルダー名に自動設定する"
$chkDateFolder.Checked = $true
$outLayout.Controls.Add($chkDateFolder, 1, 1)

$lblSub = New-Label "フォルダー名"
$outLayout.Controls.Add($lblSub, 0, 2)

$txtSub = New-Object Windows.Forms.TextBox
$txtSub.Width = 300
$txtSub.Text = (Get-Date -Format "yyyyMMdd_HHmmss")
$txtSub.Enabled = $false
$txtSub.Anchor = [Windows.Forms.AnchorStyles]::Left -bor [Windows.Forms.AnchorStyles]::Right
$outLayout.Controls.Add($txtSub, 1, 2)

$lblPreview = New-Object Windows.Forms.Label
$lblPreview.AutoSize = $true
$lblPreview.MaximumSize = New-Object Drawing.Size(700, 0)
$lblPreview.Margin = New-Object Windows.Forms.Padding(0, 6, 0, 0)
$outLayout.Controls.Add($lblPreview, 1, 3)
$outLayout.SetColumnSpan($lblPreview, 2)

$groupName = New-Object Windows.Forms.GroupBox
$groupName.Text = "出力ファイル名"
$groupName.AutoSize = $true
$groupName.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$groupName.Dock = [Windows.Forms.DockStyle]::Top
$groupName.Padding = New-Object Windows.Forms.Padding(10)
$groupName.Margin = New-Object Windows.Forms.Padding(0, 0, 0, 10)
$root.Controls.Add($groupName)

$nameLayout = New-Object Windows.Forms.TableLayoutPanel
$nameLayout.AutoSize = $true
$nameLayout.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$nameLayout.ColumnCount = 2
$nameLayout.RowCount = 3
$nameLayout.Dock = [Windows.Forms.DockStyle]::Fill
$nameLayout.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle([Windows.Forms.SizeType]::AutoSize)))
$nameLayout.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle([Windows.Forms.SizeType]::Percent, 100)))
$groupName.Controls.Add($nameLayout)

$rbAuto = New-Object Windows.Forms.RadioButton
$rbAuto.AutoSize = $true
$rbAuto.Checked = $true
$rbAuto.Text = "自動設定（title -> 最初の見出し要素 -> output）"
$nameLayout.Controls.Add($rbAuto, 0, 0)
$nameLayout.SetColumnSpan($rbAuto, 2)

$rbManual = New-Object Windows.Forms.RadioButton
$rbManual.AutoSize = $true
$rbManual.Text = "指定ファイル名"
$nameLayout.Controls.Add($rbManual, 0, 1)

$txtName = New-Object Windows.Forms.TextBox
$txtName.Width = 300
$txtName.Enabled = $false
$nameLayout.Controls.Add($txtName, 1, 1)

$lblNameHint = New-Object Windows.Forms.Label
$lblNameHint.AutoSize = $true
$lblNameHint.Text = "拡張子 .md は自動で付与されます。"
$lblNameHint.Margin = New-Object Windows.Forms.Padding(0, 6, 0, 0)
$nameLayout.Controls.Add($lblNameHint, 1, 2)

$panelActions = New-Object Windows.Forms.FlowLayoutPanel
$panelActions.AutoSize = $true
$panelActions.AutoSizeMode = [Windows.Forms.AutoSizeMode]::GrowAndShrink
$panelActions.FlowDirection = [Windows.Forms.FlowDirection]::LeftToRight
$panelActions.Dock = [Windows.Forms.DockStyle]::Top
$panelActions.Margin = New-Object Windows.Forms.Padding(0, 0, 0, 6)
$root.Controls.Add($panelActions)

$btnStart = New-Object Windows.Forms.Button
$btnStart.Text = "開始"
$btnStart.AutoSize = $true
$btnStart.Padding = New-Object Windows.Forms.Padding(10, 4, 10, 4)
$panelActions.Controls.Add($btnStart)

$lblStatus = New-Object Windows.Forms.Label
$lblStatus.AutoSize = $true
$lblStatus.MaximumSize = New-Object Drawing.Size(700, 0)
$lblStatus.Text = "準備完了"
$root.Controls.Add($lblStatus)

$folderDialog = New-Object Windows.Forms.FolderBrowserDialog
$folderDialog.Description = "保存場所を選択してください"
$folderDialog.ShowNewFolderButton = $true

function Update-Preview {
    $folderName = if ($chkDateFolder.Checked) { Get-Date -Format "yyyyMMdd_HHmmss" } else { $txtSub.Text.Trim() }
    $base = $txtBase.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($base) -or [string]::IsNullOrWhiteSpace($folderName)) {
        $lblPreview.Text = "出力先プレビュー: （未設定）"
        return
    }

    $preview = Join-Path $base $folderName
    $lblPreview.Text = "出力先プレビュー: " + $preview
}

$btnBrowse.Add_Click({
    if (Test-Path -LiteralPath $txtBase.Text) {
        $folderDialog.SelectedPath = $txtBase.Text
    }
    if ($folderDialog.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $txtBase.Text = $folderDialog.SelectedPath
        Update-Preview
    }
})

$chkDateFolder.Add_CheckedChanged({
    $txtSub.Enabled = -not $chkDateFolder.Checked
    if ($chkDateFolder.Checked) {
        $txtSub.Text = (Get-Date -Format "yyyyMMdd_HHmmss")
    }
    Update-Preview
})

$txtBase.Add_TextChanged({ Update-Preview })
$txtSub.Add_TextChanged({ Update-Preview })

$rbAuto.Add_CheckedChanged({
    if ($rbAuto.Checked) {
        $txtName.Enabled = $false
    }
})

$rbManual.Add_CheckedChanged({
    if ($rbManual.Checked) {
        $txtName.Enabled = $true
        $txtName.Focus() | Out-Null
    }
})

$btnStart.Add_Click({
    try {
        $btnStart.Enabled = $false
        $form.UseWaitCursor = $true
        [Windows.Forms.Application]::DoEvents()

        $base = $txtBase.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($base)) {
            throw "保存場所を入力してください。"
        }

        $folderName = if ($chkDateFolder.Checked) { Get-Date -Format "yyyyMMdd_HHmmss" } else { $txtSub.Text.Trim() }
        if ([string]::IsNullOrWhiteSpace($folderName)) {
            throw "フォルダー名を入力してください。"
        }

        $outDir = Join-Path $base $folderName

        if (-not (Test-Path -LiteralPath $base)) {
            throw "保存場所が存在しません: $base"
        }

        $result = $null
        if ($rbManual.Checked) {
            $manualName = $txtName.Text.Trim()
            if ([string]::IsNullOrWhiteSpace($manualName)) {
                throw "指定ファイル名を入力するか、自動設定を選択してください。"
            }
            $result = & $converterPath -OutDir $outDir -OutFileName $manualName
        }
        else {
            $result = & $converterPath -OutDir $outDir
        }

        $mdPath = $null
        $imgPath = $null
        if ($null -ne $result) {
            $mdPath = $result.MarkdownPath
            $imgPath = $result.ImagesDir
        }

        if ([string]::IsNullOrWhiteSpace($mdPath)) {
            $mdPath = "（不明）"
        }
        if ([string]::IsNullOrWhiteSpace($imgPath)) {
            $imgPath = "（不明）"
        }

        $lblStatus.Text = "完了: $mdPath"

        [Windows.Forms.MessageBox]::Show(
            "変換が完了しました。`n`nMarkdown:`n$mdPath`n`n画像フォルダー:`n$imgPath",
            "loop2md フォーム",
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
    catch {
        $lblStatus.Text = "失敗: " + $_.Exception.Message
        [Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "loop2md フォーム",
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
    finally {
        $form.UseWaitCursor = $false
        $btnStart.Enabled = $true
    }
})

Update-Preview
[void]$form.ShowDialog()
