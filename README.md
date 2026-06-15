# Kho backup chat Claude

Thư mục này là **trung tâm sao lưu mọi cuộc trò chuyện với Claude** trên các máy của bạn,
dùng làm nơi backup + nguồn dữ liệu train AI.

## Cấu trúc

```
Documents\claude\
├── chats\           # Bản DỄ ĐỌC (markdown), đã lược base64
│   ├── <project>\               <- Claude Code / Cowork
│   └── claude-ai\               <- chat claude.ai (sau khi import)
├── transcripts\     # Bản GỐC đầy đủ (.jsonl) của Claude Code/Cowork
├── sessions-meta\   # Metadata phiên Cowork (tiêu đề, thời gian)
├── _export\         # (KHÔNG commit) nơi bỏ conversations.json từ claude.ai
├── sync-claude.ps1            # quét .claude\projects -> chats + transcripts
├── backup-push.ps1            # git commit + push (nếu có remote)
├── import-claude-ai-export.ps1# xử lý file Export claude.ai -> markdown
└── remind-export.ps1          # popup nhắc Export hàng tuần
```

## Hai nguồn dữ liệu (QUAN TRỌNG)

| Loại | Nằm ở đâu | Cách lấy |
|---|---|---|
| **Claude Code / Cowork** | File `.jsonl` ngay trên máy chạy | Tự động qua `sync-claude.ps1` |
| **Chat claude.ai** | **Chỉ trên cloud Anthropic** | Export thủ công → `import-claude-ai-export.ps1` |

Chat claude.ai **không** lưu nội dung xuống ổ cứng → bắt buộc Export, không có cách auto-pull.

## Tự động hoá (hook Claude Code)

- **Stop** (mỗi lượt trả lời): chạy `sync-claude.ps1` → cập nhật chats/transcripts.
- **SessionEnd** (đóng phiên): chạy `sync-claude.ps1` + `backup-push.ps1` → commit & push.

> ⚠️ Phần auto-push lúc đóng phiên cần bạn tự bật trong `~/.claude/settings.json`
> (xem mục "Bật auto-push" bên dưới) vì nó tự chạy `git push` ngầm.

## Thiết lập remote Git (làm 1 lần)

1. Tạo 1 repo **riêng tư** trên GitHub/GitLab, ví dụ `claude-backup` (KHÔNG thêm README).
2. Trong thư mục này chạy:
   ```powershell
   cd $env:USERPROFILE\Documents\claude
   git remote add origin <URL-repo-rieng-tu-cua-ban>
   git push -u origin master
   ```

## Bật auto-push (tùy chọn)

Thêm vào `~/.claude/settings.json`, mục `hooks.SessionEnd`, lệnh:
```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\nguyentrungtin\Documents\claude\backup-push.ps1"
```
(chạy SAU lệnh sync-claude.ps1 đã có sẵn).

## Máy ở nhà (trung tâm backup)

```powershell
cd $env:USERPROFILE\Documents
git clone <URL-repo-rieng-tu> claude
```
Sau đó mỗi lần muốn cập nhật bản mới nhất từ các máy:
```powershell
cd $env:USERPROFILE\Documents\claude
git pull
```
(Có thể đặt một Scheduled Task chạy `git pull` mỗi sáng để luôn có bản mới.)

## Lấy chat claude.ai

1. claude.ai → Settings → Privacy → **Export data** (file gửi về email).
2. Giải nén, chép `conversations.json` (và `projects.json` nếu có) vào `_export\`.
3. Chạy:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\claude\import-claude-ai-export.ps1"
   ```
Lịch nhắc tự bật hàng tuần (Task Scheduler: "Claude - Nhac Export chat").
