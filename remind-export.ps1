# Hien thong bao nhac Export du lieu chat tu claude.ai
Add-Type -AssemblyName System.Windows.Forms
$msg = @"
Da den luc sao luu chat claude.ai!

1. Vao claude.ai -> Settings -> Privacy -> Export data
2. Doi email gui ve lab@exceltech.io, tai .zip va giai nen
3. Chep conversations.json vao:
   $env:USERPROFILE\Documents\claude\_export\
4. Chay: import-claude-ai-export.ps1

(Chat Claude Code/Cowork da tu dong sao luu, khong can lam gi.)
"@
[System.Windows.Forms.MessageBox]::Show($msg, 'Claude Backup - Nhac Export', 'OK', 'Information') | Out-Null
