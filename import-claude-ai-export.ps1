# =====================================================================
# Xu ly file Export tu claude.ai (conversations.json) -> markdown
# de doc, luu vao Documents\claude\chats\claude-ai\
#
# CACH LAY FILE:
#   claude.ai -> Settings -> Privacy -> Export data
#   Anthropic gui ve email lab@exceltech.io 1 file .zip (hoac .dms).
#   Giai nen, ben trong co conversations.json (va co the projects.json).
#
# CACH DUNG:
#   1. Chep conversations.json vao:  Documents\claude\_export\conversations.json
#   2. Chay:  powershell -ExecutionPolicy Bypass -File "Documents\claude\import-claude-ai-export.ps1"
#   (Hoac truyen duong dan khac:  -Source "D:\tai-ve\conversations.json")
# =====================================================================
param(
  [string]$Source = "$env:USERPROFILE\Documents\claude\_export\conversations.json",
  [string]$OutDir = "$env:USERPROFILE\Documents\claude\chats\claude-ai"
)

if (-not (Test-Path $Source)) {
  Write-Host "KHONG TIM THAY: $Source"
  Write-Host "Hay chep file conversations.json (tu ban Export claude.ai) vao duong dan tren,"
  Write-Host "hoac chay lai voi:  -Source 'duong\dan\toi\conversations.json'"
  exit 1
}
New-Item -ItemType Directory -Force $OutDir | Out-Null

$convos = Get-Content $Source -Raw -Encoding UTF8 | ConvertFrom-Json
if ($convos -isnot [Array]) { $convos = @($convos) }

function Get-SafeName([string]$s) {
  if (-not $s) { return 'untitled' }
  $s = $s.Normalize([Text.NormalizationForm]::FormD)
  $s = ($s.ToCharArray() | Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }) -join ''
  $s = $s -replace '[^a-zA-Z0-9 _-]', '' -replace '\s+', '-'
  if ($s.Length -gt 60) { $s = $s.Substring(0, 60) }
  $r = $s.Trim('-'); if (-not $r) { 'untitled' } else { $r }
}

# Lay text tu 1 message: uu tien field 'text', neu rong thi gom tu 'content[].text'
function Get-MsgText($m) {
  if ($m.text) { return [string]$m.text }
  $parts = @()
  foreach ($c in $m.content) {
    if ($c.type -eq 'text' -and $c.text) { $parts += $c.text }
    elseif ($c.input_json) { $parts += "*[tool input]*" }
  }
  ($parts -join "`n")
}

$count = 0
foreach ($conv in $convos) {
  $name = if ($conv.name) { $conv.name } else { 'Untitled' }
  $uuid = $conv.uuid
  $stub = (Get-SafeName $name) + '__' + $uuid
  $md   = Join-Path $OutDir ($stub + '.md')

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("# $name"); $out.Add('')
  $out.Add("- UUID: $uuid")
  if ($conv.created_at) { $out.Add("- Tao: $($conv.created_at)") }
  if ($conv.updated_at) { $out.Add("- Cap nhat: $($conv.updated_at)") }

  $msgs = @($conv.chat_messages)
  # sap xep theo thoi gian neu co
  if ($msgs.Count -and $msgs[0].created_at) { $msgs = $msgs | Sort-Object created_at }

  foreach ($m in $msgs) {
    $t = (Get-MsgText $m).Trim()
    $t = $t -replace '[A-Za-z0-9+/=]{500,}', '[CHUOI BASE64 DA LUOC BO]'
    if (-not $t) { $t = '*(khong co noi dung text)*' }
    $role = if ($m.sender -eq 'human') { '## Nguoi dung' } else { '## Claude' }
    # ghi chu file dinh kem neu co
    $att = @(); foreach ($a in $m.attachments) { if ($a.file_name) { $att += $a.file_name } }
    foreach ($fl in $m.files) { if ($fl.file_name) { $att += $fl.file_name } }
    $out.Add(''); $out.Add('---'); $out.Add(''); $out.Add($role); $out.Add('')
    if ($att.Count) { $out.Add('*Dinh kem: ' + ($att -join ', ') + '*'); $out.Add('') }
    $out.Add($t)
  }

  [IO.File]::WriteAllLines($md, $out, (New-Object Text.UTF8Encoding($true)))
  $count++
}

# Xu ly projects.json neu nam canh do
$projFile = Join-Path (Split-Path $Source) 'projects.json'
if (Test-Path $projFile) {
  $projs = Get-Content $projFile -Raw -Encoding UTF8 | ConvertFrom-Json
  $pdir = Join-Path $OutDir '_projects'; New-Item -ItemType Directory -Force $pdir | Out-Null
  foreach ($p in $projs) {
    $stub = (Get-SafeName $p.name) + '__' + $p.uuid
    $o = New-Object System.Collections.Generic.List[string]
    $o.Add("# [Project] $($p.name)"); $o.Add(''); $o.Add("- UUID: $($p.uuid)")
    if ($p.description) { $o.Add("- Mo ta: $($p.description)") }
    foreach ($d in $p.docs) { $o.Add(''); $o.Add('---'); $o.Add(''); $o.Add("## $($d.filename)"); $o.Add(''); $o.Add([string]$d.content) }
    [IO.File]::WriteAllLines((Join-Path $pdir ($stub + '.md')), $o, (New-Object Text.UTF8Encoding($true)))
  }
  Write-Host "Da xu ly them $($projs.Count) project."
}

Write-Host "XONG: da xuat $count doan chat claude.ai vao $OutDir"
