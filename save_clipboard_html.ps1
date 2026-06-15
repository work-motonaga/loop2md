param(
    [string]$OutFile = ".\clipboard_dump.html"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore

if ([Threading.Thread]::CurrentThread.ApartmentState -ne [Threading.ApartmentState]::STA) {
    Write-Error "This script must run in STA mode. Example: powershell.exe -STA -File .\save_clipboard_html.ps1"
    exit 1
}

if (-not [Windows.Forms.Clipboard]::ContainsData("HTML Format")) {
    Write-Error "Clipboard does not contain HTML Format."
    exit 1
}

$html = $null
if ([System.Windows.Clipboard]::ContainsText([System.Windows.TextDataFormat]::Html)) {
    $html = [System.Windows.Clipboard]::GetText([System.Windows.TextDataFormat]::Html)
}

if ([string]::IsNullOrWhiteSpace($html)) {
    $clipDataObj = [Windows.Forms.Clipboard]::GetDataObject()
    $clipHtmlRaw = $clipDataObj.GetData("HTML Format", $false)

    if ($clipHtmlRaw -is [byte[]]) {
        $html = [Text.Encoding]::UTF8.GetString($clipHtmlRaw)
    }
    elseif ($clipHtmlRaw -is [IO.MemoryStream]) {
        $html = [Text.Encoding]::UTF8.GetString($clipHtmlRaw.ToArray())
    }
    else {
        $html = [string]$clipHtmlRaw
    }
}

$html = $html -replace "`0", ""
if ([string]::IsNullOrWhiteSpace($html)) {
    Write-Error "Clipboard HTML is empty."
    exit 1
}

$dir = Split-Path -Parent $OutFile
if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

[IO.File]::WriteAllText($OutFile, $html, [Text.UTF8Encoding]::new($true))

$title = [regex]::Match($html, '(?is)<title[^>]*>(.*?)</title>').Groups[1].Value
$heading = [regex]::Match($html, '(?is)<h([1-6])\b[^>]*>(.*?)</h\1>').Groups[2].Value

Write-Host "Saved: $OutFile"
if (-not [string]::IsNullOrWhiteSpace($title)) { Write-Host "Title: $title" }
if (-not [string]::IsNullOrWhiteSpace($heading)) { Write-Host "Heading: $heading" }
