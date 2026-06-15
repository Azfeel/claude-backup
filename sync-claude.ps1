# =====================================================================
# Dong bo TAT CA chat cua Claude (Claude Code CLI + Cowork desktop) vao
# Documents\claude. Chay tu dong qua hook, hoac chay tay luc nao cung duoc.
#
#   Documents\claude\
#     transcripts\<project>\<title>__<id>.jsonl  -> ban GOC day du
#     chats\<project>\<title>__<id>.md           -> ban DE DOC
#     sessions-meta\                             -> metadata phien Cowork
# =====================================================================

$projectsDir = Join-Path $env:USERPROFILE '.claude\projects'
$cowork      = Join-Path $env:APPDATA    'Claude\claude-code-sessions'
$baseDir     = Join-Path $env:USERPROFILE 'Documents\claude'
$rawDir      = Join-Path $baseDir 'transcripts'
$chatDir     = Join-Path $baseDir 'chats'
$metaDir     = Join-Path $baseDir 'sessions-meta'
New-Item -ItemType Directory -Force $rawDir, $chatDir, $metaDir | Out-Null

# --- 1. Doc tieu de tu cac phien Cowork desktop (cliSessionId -> title) ---
$titleMap = @{}
if (Test-Path $cowork) {
  foreach ($s in Get-ChildItem $cowork -Recurse -Filter *.json -File) {
    try { $j = Get-Content $s.FullName -Raw | ConvertFrom-Json } catch { continue }
    if ($j.cliSessionId -and $j.title) { $titleMap[$j.cliSessionId] = $j.title }
    Copy-Item $s.FullName (Join-Path $metaDir $s.Name) -Force   # luu metadata
  }
}

function Get-SafeName([string]$s) {
  if (-not $s) { return 'untitled' }
  $s = $s.Normalize([Text.NormalizationForm]::FormD)
  $s = ($s.ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }) -join ''
  $s = $s -replace '[^a-zA-Z0-9 _-]', '' -replace '\s+', '-'
  if ($s.Length -gt 60) { $s = $s.Substring(0, 60) }
  return $s.Trim('-')
}

if (-not (Test-Path $projectsDir)) { exit 0 }

# --- 2. Xu ly tung transcript .jsonl ---
foreach ($f in Get-ChildItem $projectsDir -Recurse -Filter *.jsonl -File) {
  $proj  = $f.Directory.Name
  $title = if ($titleMap.ContainsKey($f.BaseName)) { $titleMap[$f.BaseName] } else { $null }
  $stub  = if ($title) { (Get-SafeName $title) + '__' + $f.BaseName } else { $f.BaseName }

  # 2a. Copy ban goc (chi khi co thay doi)
  $rawProj = Join-Path $rawDir $proj; New-Item -ItemType Directory -Force $rawProj | Out-Null
  $rawCopy = Join-Path $rawProj ($stub + '.jsonl')
  if (-not (Test-Path $rawCopy) -or $f.LastWriteTime -gt (Get-Item $rawCopy).LastWriteTime) {
    Copy-Item $f.FullName $rawCopy -Force
  }

  # 2b. Xuat ban markdown de doc (chi khi co thay doi)
  $mdProj = Join-Path $chatDir $proj; New-Item -ItemType Directory -Force $mdProj | Out-Null
  $md = Join-Path $mdProj ($stub + '.md')
  if ((Test-Path $md) -and ((Get-Item $md).LastWriteTime -ge $f.LastWriteTime)) { continue }

  $files = New-Object System.Collections.Generic.HashSet[string]
  $body  = New-Object System.Collections.Generic.List[string]
  $firstUser = $null

  foreach ($line in [IO.File]::ReadLines($f.FullName, [Text.Encoding]::UTF8)) {
    try { $j = $line | ConvertFrom-Json } catch { continue }
    if ($j.type -ne 'user' -and $j.type -ne 'assistant') { continue }
    if ($j.isMeta) { continue }

    $c = $j.message.content
    $texts = @()
    if ($c -is [string]) { $texts += $c }
    else {
      foreach ($p in $c) {
        if ($p.type -eq 'text') { $texts += $p.text }
        elseif ($p.type -eq 'tool_use' -and $p.input.file_path) {
          [void]$files.Add($p.input.file_path)
          $texts += "*[Thao tac file: $($p.name) -> $($p.input.file_path)]*"
        }
      }
    }
    $text = ($texts -join "`n").Trim()
    if (-not $text) { continue }

    $text = $text -replace '[A-Za-z0-9+/=]{500,}', '[CHUOI BASE64 DA LUOC BO]'
    if ($text.Length -gt 30000) { $text = $text.Substring(0, 30000) + "`n... [da cat bot]" }

    if ($j.type -eq 'user') {
      if (-not $firstUser) { $firstUser = ($text -replace '\s+', ' ') }
      $body.Add(''); $body.Add('---'); $body.Add(''); $body.Add('## Nguoi dung'); $body.Add(''); $body.Add($text)
    } else {
      $body.Add(''); $body.Add('---'); $body.Add(''); $body.Add('## Claude'); $body.Add(''); $body.Add($text)
    }
  }

  $head = if ($title) { $title } elseif ($firstUser) { $firstUser.Substring(0, [Math]::Min(80, $firstUser.Length)) } else { $f.BaseName }
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("# $head"); $out.Add('')
  $out.Add("- Phien: $($f.BaseName)"); $out.Add("- Project: $proj")
  $out.Add("- Cap nhat: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
  if ($files.Count -gt 0) {
    $out.Add(''); $out.Add('## File da tao / sua trong phien nay')
    foreach ($fp in $files) { $out.Add("- $fp") }
  }
  $out.AddRange($body)
  [IO.File]::WriteAllLines($md, $out, (New-Object Text.UTF8Encoding($true)))
}
