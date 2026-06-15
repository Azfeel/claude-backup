# =====================================================================
# Sao luu kho Documents\claude len Git (commit + push neu co remote).
# Chay sau khi sync-claude.ps1 da cap nhat noi dung.
# An toan khi chua co remote: chi commit local, bo qua push.
# =====================================================================
$repo = Join-Path $env:USERPROFILE 'Documents\claude'
if (-not (Test-Path (Join-Path $repo '.git'))) { exit 0 }

$env:GIT_TERMINAL_PROMPT = '0'   # khong hoi mat khau (tranh treo)
Push-Location $repo
try {
  $status = git status --porcelain
  if ($status) {
    git add -A | Out-Null
    $machine = $env:COMPUTERNAME
    $stamp   = Get-Date -Format 'yyyy-MM-dd HH:mm'
    git -c commit.gpgsign=false commit -q -m "Backup tu $machine luc $stamp" 2>$null
  }
  # Chi push neu da cau hinh remote 'origin'
  $hasRemote = git remote 2>$null
  if ($hasRemote -contains 'origin') {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    git push origin $branch 2>$null
  }
} finally {
  Pop-Location
}
