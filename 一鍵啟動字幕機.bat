@echo off
chcp 65001 >nul
title TranslaShen Subtitle 本機免安裝伺服器
cd /d "%~dp0"

echo ==================================================
echo   TranslaShen Subtitle 即時多國語言字幕顯示系統
echo   正在啟動本機安全環境 http://localhost:8765
echo   (解除 Chrome 本機檔案麥克風限制並啟用置頂字幕)
echo   使用完畢後直接關閉此視窗即可停止
echo ==================================================
echo.

start "" "http://localhost:8765"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$root = (Get-Location).Path; " ^
  "$listener = New-Object System.Net.HttpListener; " ^
  "$listener.Prefixes.Add('http://localhost:8765/'); " ^
  "$listener.Start(); " ^
  "Write-Host '伺服器運行中：http://localhost:8765 (請保持此視窗開啟)'; " ^
  "while ($listener.IsListening) { " ^
  "  $ctx = $listener.GetContext(); " ^
  "  $reqPath = $ctx.Request.Url.AbsolutePath; " ^
  "  if ($reqPath -eq '/') { $reqPath = '/index.html'; } " ^
  "  $file = Join-Path $root ($reqPath.TrimStart('/').Replace('/', '\')); " ^
  "  if (Test-Path $file -PathType Leaf) { " ^
  "    $ext = [System.IO.Path]::GetExtension($file).ToLower(); " ^
  "    $mime = switch ($ext) { '.html' {'text/html; charset=utf-8'} '.svg' {'image/svg+xml'} '.css' {'text/css; charset=utf-8'} '.js' {'application/javascript; charset=utf-8'} '.png' {'image/png'} default {'application/octet-stream'} }; " ^
  "    $bytes = [System.IO.File]::ReadAllBytes($file); " ^
  "    $ctx.Response.ContentType = $mime; " ^
  "    $ctx.Response.ContentLength64 = $bytes.Length; " ^
  "    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length); " ^
  "  } else { " ^
  "    $ctx.Response.StatusCode = 404; " ^
  "  } " ^
  "  $ctx.Response.Close(); " ^
  "}"
