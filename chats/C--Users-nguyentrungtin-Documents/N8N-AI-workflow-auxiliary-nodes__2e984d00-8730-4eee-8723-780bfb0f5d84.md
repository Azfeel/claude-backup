# N8N AI workflow auxiliary nodes

- Phien: 2e984d00-8730-4eee-8723-780bfb0f5d84
- Project: C--Users-nguyentrungtin-Documents
- Cap nhat: 2026-06-15 14:55

## File da tao / sua trong phien nay
- C:\Users\nguyentrungtin\.claude\projects\C--Users-nguyentrungtin-Documents\2e984d00-8730-4eee-8723-780bfb0f5d84\tool-results\toolu_01WfDttQmTfbH6u3C3PoXDKs.json

---

## Nguoi dung

Tôi đang triển khai workflow AI trên N8N. Và cần 1 bộ node phụ chạy chung với bộ node chính để thu thập dữ liệu, từ fđó giúp chất lượng hình ảnh được tốt hơn. Hãy kiểm tra cho tôi có thể build ntn? Đưa cho tô logic để treienr khai

---

## Claude

Câu hỏi của bạn là về kiến trúc workflow, nên tôi sẽ đưa ra thiết kế logic hoàn chỉnh. Để hình dung dễ hơn, tôi vẽ sơ đồ trước.

---

## Claude

*[Thao tac file: Read -> C:\Users\nguyentrungtin\.claude\projects\C--Users-nguyentrungtin-Documents\2e984d00-8730-4eee-8723-780bfb0f5d84\tool-results\toolu_01WfDttQmTfbH6u3C3PoXDKs.json]*

---

## Claude

Logic triển khai chi tiết như sau.

## Nguyên tắc cốt lõi

Vòng lặp cải thiện **khép kín qua database, không nối trực tiếp** giữa các workflow: bộ phụ ghi dữ liệu vào DB, còn workflow chính chỉ đọc DB lúc build prompt. Nhờ vậy workflow chính không bao giờ bị chậm hay lỗi vì bộ phụ — đây là điểm quan trọng nhất của thiết kế.

## Workflow A — tạo ảnh (workflow chính của bạn)

1. **Trigger** (webhook/form/app như hiện tại).
2. **Postgres/Supabase node** — đọc bảng `prompt_insights` lấy các "quy tắc tốt" đang active (ví dụ theo category của yêu cầu).
3. **AI Agent / LLM node — Build prompt**: ghép yêu cầu người dùng + insights thành prompt cuối. System prompt kiểu: *"Viết prompt tạo ảnh từ yêu cầu sau. Áp dụng các quy tắc đã được chứng minh hiệu quả: {{insights}}"*.
4. **Node tạo ảnh** (Flux/DALL·E/SD API).
5. **Execute Workflow node → gọi Workflow B**, tắt tùy chọn **"Wait for Sub-Workflow Completion"** — đây chính là cách chạy "bộ node phụ song song" trong n8n: fire-and-forget, A trả kết quả ngay không chờ B.
6. **Trả kết quả** cho người dùng, kèm một `generation_id` (dùng `{{ $execution.id }}` hoặc UUID) để sau này gắn feedback.

Payload gửi sang B: `generation_id`, prompt gốc của user, prompt cuối cùng, model + params (size, steps, seed…), **URL ảnh** (đừng gửi binary qua Execute Workflow — upload ảnh lên S3/Drive trước rồi gửi link), timestamp.

## Workflow B — thu thập & chấm điểm (chạy nền)

1. **Execute Workflow Trigger** — nhận payload từ A.
2. **Chấm điểm tự động bằng vision model** (Claude/GPT vision): gửi ảnh + prompt gốc, yêu cầu trả JSON:
```json
{
  "prompt_adherence": 8,      // ảnh đúng yêu cầu không
  "aesthetic": 7,             // bố cục, ánh sáng, màu
  "defects": ["bàn tay 6 ngón", "chữ bị méo"],
  "overall": 7.5
}
```
3. **Postgres node** — insert một dòng vào `image_logs`.

Ngoài ra thêm một **webhook riêng nhận feedback người dùng** (nút like/dislike, regenerate ở app của bạn) — nó `UPDATE image_logs SET user_rating = ... WHERE generation_id = ...`. Hành vi "bấm tạo lại" là tín hiệu chê rất giá trị, nên log cả nó.

## Database — 2 bảng

- `image_logs`: `generation_id, user_request, final_prompt, model, params(jsonb), image_url, ai_scores(jsonb), defects(jsonb), user_rating, regenerated(bool), category, created_at`
- `prompt_insights`: `id, category, rule_text, evidence_count, avg_score, active(bool), updated_at`

Chưa có Postgres thì bắt đầu bằng Google Sheets/Airtable cũng chạy được y nguyên logic này; ổn định rồi hãy chuyển sang Supabase (free tier đủ dùng).

## Workflow C — tổng hợp định kỳ (khép vòng lặp)

1. **Schedule Trigger** — mỗi ngày 1 lần (đủ dữ liệu mới chạy, ví dụ ≥30 ảnh mới).
2. **Postgres node** — query ảnh 7 ngày gần nhất, tách nhóm điểm cao (overall ≥ 8 hoặc user like) và nhóm điểm thấp (≤ 5, dislike, regenerate).
3. **LLM node — phân tích**: đưa 2 nhóm prompt vào, yêu cầu: *"So sánh các prompt cho ảnh tốt và ảnh kém. Rút ra tối đa 5 quy tắc viết prompt cụ thể, mỗi quy tắc kèm số ảnh làm bằng chứng. Liệt kê cả lỗi lặp lại (defects) và đề xuất negative prompt / param khắc phục."*
4. **Postgres node — upsert vào `prompt_insights`**: quy tắc mới thêm vào, quy tắc cũ không còn đúng thì set `active = false`.

Từ đây Workflow A ở lần chạy sau tự đọc được insights mới — chất lượng ảnh cải thiện dần mà không phải sửa tay workflow.

## Lưu ý triển khai

- **Thứ tự build**: A thêm node Execute Workflow → B chỉ cần nhận + ghi log (chưa cần chấm điểm) → có ~50–100 dòng dữ liệu thì thêm node chấm điểm vision → cuối cùng mới build C. Đừng build cả 3 cùng lúc.
- Gắn **Error Workflow** cho B và C để lỗi nền không bị nuốt im lặng (gửi cảnh báo Telegram/Slack).
- Chi phí chấm điểm vision: nếu lượng ảnh lớn, chỉ chấm mẫu ngẫu nhiên 20–30% (node IF với `Math.random() < 0.3`) — vẫn đủ dữ liệu cho C.
- Khi đã chạy ổn, bạn có thể nâng cấp C thành **A/B testing**: sinh 2 biến thể insights, gắn tag vào mỗi generation, so điểm trung bình sau một tuần rồi giữ biến thể thắng.

Nếu bạn cho tôi biết model tạo ảnh đang dùng và nơi lưu dữ liệu hiện có (Sheets, Supabase…?), tôi có thể viết luôn JSON của 3 workflow này để bạn import thẳng vào n8n.

---

## Nguoi dung

Rồi giờ cho luôn phân tích tương tự như vậy, nhưng dành cho Xây bộ MND ghi nhận personal branding cho từng doanh nghiệp

* Tức flow của tôi sẽ là: MND personal để tôi update liên tục các working file/file tài liệu đã làm việc với client, phần trên update flow để ghi nhớ kết qảu đã làm trong tgian máy chạy để có thể thông minh hơn. Và flow để chạy AI Auto

---

## Claude

Bài toán này cùng khung tư duy với bộ workflow ảnh, nhưng có một khác biệt cốt lõi: MND (bộ nhớ thương hiệu) cần **hai loại bộ nhớ tách biệt** — bộ nhớ có cấu trúc (brand profile: tone, USP, điều cấm kỵ…) và bộ nhớ phi cấu trúc (kho tài liệu vector để RAG) — và phải **tách theo từng client** ngay từ thiết kế. Sơ đồ:

---

## Claude

Logic triển khai chi tiết:

## Cấu trúc MND — trái tim của hệ thống

MND của mỗi client gồm 3 lớp, **tất cả dùng chung một database, tách nhau bằng cột `client_id`** (đừng tạo DB riêng cho từng client — không scale được):

- **`brand_profile`** (bộ nhớ có cấu trúc — "sự thật" về thương hiệu): mỗi client 1 dòng, cột `profile` kiểu jsonb:
```json
{
  "tone_of_voice": "thân thiện, không dùng từ Hán Việt nặng",
  "usp": [...], "target_audience": {...},
  "do": ["luôn kết bài bằng CTA mềm"],
  "dont": ["không emoji", "không so sánh trực tiếp đối thủ"],
  "visual_style": {...}, "banned_words": [...],
  "version": 12, "updated_at": "..."
}
```
- **Vector store** (bộ nhớ phi cấu trúc — toàn bộ working file): chunks của tài liệu, metadata `{client_id, file_id, doc_type, version, date}`. Dùng Supabase pgvector hoặc Qdrant — cả hai đều có node n8n chính thức.
- **`run_logs`**: mỗi lần AI Auto chạy ghi 1 dòng — input, ngữ cảnh đã dùng, output, profile version, và sau đó là feedback (client duyệt/sửa gì).

Tách structured và unstructured là điểm quyết định chất lượng: facts như "không dùng emoji" mà chỉ nằm rải rác trong vector thì RAG sẽ lúc lấy được lúc không; nằm trong profile thì **lần nào cũng được nạp vào prompt**.

## Flow A — nạp MND (bạn update liên tục)

1. **Trigger đa nguồn**: Google Drive Trigger (mỗi client 1 folder, tên folder = client_id), webhook upload, hoặc Telegram bot để bạn ném nhanh ghi chú sau buổi họp.
2. **Extract from File node** — PDF/docx/xlsx → text.
3. **LLM rút fact thương hiệu**: đưa text mới + profile hiện tại, yêu cầu trả JSON: *"Liệt kê fact mới về thương hiệu, fact cần cập nhật, và fact mâu thuẫn với profile hiện có."* Fact mới/cập nhật → upsert vào `brand_profile`, tăng `version`. Fact mâu thuẫn → gửi bạn duyệt qua Telegram trước khi ghi (human-in-the-loop, tránh tài liệu cũ ghi đè quyết định mới).
4. **Chunk + embed → vector store**. Quy tắc quan trọng: khi một file được **update**, phải `DELETE` toàn bộ vector cũ theo `file_id` trước khi insert bản mới — không làm bước này thì MND sẽ trả về cả nội dung lỗi thời lẫn nội dung mới và "ngu dần" theo thời gian.

## Flow B — AI Auto (flow chạy chính)

1. **Trigger** — lịch đăng bài, hoặc yêu cầu mới từ form/chat.
2. **Nạp ngữ cảnh** (2 node song song): đọc `brand_profile` của client + Vector Store node query top 5–8 chunks **có filter `client_id`** (bắt buộc — thiếu filter là nội dung client A lẫn sang client B, lỗi nghiêm trọng nhất của hệ multi-tenant).
3. **AI Agent tạo nội dung**: system prompt = profile (tone, do/don't, banned words), context = chunks RAG, task = yêu cầu cụ thể.
4. **Giao kết quả** (đăng, hoặc gửi duyệt) + **Execute Workflow async** ghi vào `run_logs` — y hệt cơ chế fire-and-forget ở bộ workflow ảnh, B không bao giờ chờ việc ghi log.

## Flow C — ghi nhớ kết quả để máy thông minh hơn

Đây là phần "update flow để ghi nhớ kết quả đã làm" của bạn, gồm 2 nửa:

- **Webhook feedback (realtime)**: khi client/bạn sửa bài trước khi đăng, gửi bản sửa về webhook → node so sánh (diff) bản AI viết với bản đã sửa → `UPDATE run_logs`. Bản diff này là dữ liệu học giá trị nhất trong toàn hệ thống.
- **Consolidation (cron hàng ngày hoặc sau mỗi N lần chạy)**: query `run_logs` chưa xử lý theo từng client → LLM phân tích: *"Từ các lần sửa của client, rút ra quy tắc lặp lại (ví dụ: client luôn xóa câu mở đầu dạng câu hỏi). Trả về fact cần thêm vào do/dont."* → upsert vào `brand_profile`, đánh dấu logs đã học. Đồng thời dọn bộ nhớ: gộp fact trùng, hạ ưu tiên tài liệu quá cũ.

Vòng lặp khép lại giống hệt hệ thống ảnh: **C ghi vào profile, B tự đọc profile ở lần chạy sau** — không workflow nào gọi trực tiếp vào workflow nào.

## Thứ tự build và lưu ý

1. Tuần 1: dựng `brand_profile` + Flow A bản tối giản (Drive → extract → rút fact → upsert). Chưa cần vector.
2. Tuần 2: thêm vector store vào A, dựng Flow B đọc profile + RAG.
3. Tuần 3: thêm node ghi log async vào B, dựng webhook feedback.
4. Tuần 4: dựng cron consolidation (Flow C) khi đã có vài chục logs.

Ba lưu ý vận hành: mọi thay đổi `brand_profile` do máy đề xuất nên qua bước bạn approve trên Telegram ít nhất trong 1–2 tháng đầu; version hóa profile (lưu bản cũ vào bảng `profile_history`) để rollback được khi máy học sai; và gắn Error Workflow cho A và C như bộ trước.

Nếu bạn cho biết hiện đang quản lý bao nhiêu client, tài liệu nằm ở đâu (Drive? Notion?), và Flow B tạo loại nội dung gì (bài social, ảnh, hay cả hai), tôi sẽ viết JSON workflow cụ thể để import vào n8n.
