# N8N bot workflow configuration

- Phien: 8f580c7e-1557-4766-a363-b9eeb3aade18
- Project: C--Users-nguyentrungtin-Documents
- Cap nhat: 2026-06-17 16:33

---

## Nguoi dung

Dựa vào đoạn json này, hãy kiểm tra lại cho tôi:

* Cú pháp tôi cần để gọi đúng bot này là gì?
* Vì sao khi tôi gọi thì có cùng lúc nhiều model cùng chạy mà tôi ko xác định được chính xác là bot nào -> Hãy sửa lại cho tôi khi chạy, sẽ lấy tên của workspace trên n8n hoặc trên node được ko? Vì dụ như hình 1, lấy tên của My workflow 2 copy hoặc ## Workflow AI Auto - Make Product Better's Version
* Cuối cùng, hãy update thêm cho tôi 1 prompt, khi flow chạy đến đâu cũng sẽ update cho user biết trên telegram mà ko làm ảnh hưởng chi phí quá nhiều (có thể ko cần lấy hết mà thông báo ở những node quan trọng có output thay đổi rõ rẹt. Hãy kiểm tra lại phần này và hco tôi biết nên làm gì trc khi băt sđầu

{
  "nodes": [
    {
      "parameters": {
        "documentId": {
          "__rl": true,
          "value": "13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU",
          "mode": "list",
          "cachedResultName": "Meta_Automation_GGSheet_Template",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit?usp=drivesdk"
        },
        "sheetName": {
          "__rl": true,
          "value": 2029473150,
          "mode": "list",
          "cachedResultName": "01_Genarated Images",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit#gid=2029473150"
        },
        "filtersUI": {
          "values": []
        },
        "options": {
          "returnFirstMatch": false
        }
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [
        880,
        752
      ],
      "id": "9397d928-07c4-4387-841e-0a2711219089",
      "name": "Get row(s) in sheet",
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 3
          },
          "conditions": [
            {
              "id": "4415ed8b-32a8-416d-9526-9ca772d21440",
              "leftValue": "={{ $json[\"Status\"] }}",
              "rightValue": "Generating",
              "operator": {
                "type": "string",
                "operation": "equals",
                "name": "filter.operator.equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.filter",
      "typeVersion": 2.3,
      "position": [
        1088,
        752
      ],
      "id": "3dd5f682-afa6-4ce3-91d4-e187d28c80ce",
      "name": "Filter"
    },
    {
      "parameters": {
        "jsCode": "const pillar = $input.first().json[\"Link FB & Website\"] || \"\";\nconst links = pillar.split(/[|,\\n]/).map(s => s.trim()).filter(s => s.startsWith(\"http\"));\nconst fb = links.find(l => l.includes(\"facebook.com\")) || \"\";\nconst web = links.find(l => !l.includes(\"facebook.com\")) || \"\";\nreturn [{\n  json: {\n    ...$input.first().json,\n    fb_link: fb,\n    web_link: web\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1280,
        752
      ],
      "id": "dc604f22-4fb2-4a0a-8882-78fb5c472d2c",
      "name": "Code in JavaScript"
    },
    {
      "parameters": {
        "updates": [
          "message"
        ],
        "additionalFields": {}
      },
      "type": "n8n-nodes-base.telegramTrigger",
      "typeVersion": 1.2,
      "position": [
        224,
        672
      ],
      "id": "6684901a-4d42-4699-965c-a66a8c62967c",
      "name": "Telegram Trigger",
      "webhookId": "a1b2c3d4-tg-trigger-0001",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": false,
            "leftValue": "",
            "typeValidation": "loose",
            "version": 2
          },
          "conditions": [
            {
              "id": "cmd-run-code",
              "leftValue": "={{ ($('Telegram Trigger').first().json.message?.text || '').toString().toLowerCase().trim().split(' ')[0] }}",
              "rightValue": "={{ ('/run_' + ($('Bot Config').first().json.bot_code || '')).toLowerCase() }}",
              "operator": {
                "type": "string",
                "operation": "equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.filter",
      "typeVersion": 2.2,
      "position": [
        624,
        672
      ],
      "id": "74f06901-950c-4dce-848b-2a9b10f9cceb",
      "name": "Filter Start Command"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "cfg-bot-code",
              "name": "bot_code",
              "value": "20KV4",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        400,
        672
      ],
      "id": "68a42b74-7dcd-4419-9c9c-3cbc3d050605",
      "name": "Bot Config"
    }
  ],
  "connections": {
    "Get row(s) in sheet": {
      "main": [
        [
          {
            "node": "Filter",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filter": {
      "main": [
        [
          {
            "node": "Code in JavaScript",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript": {
      "main": [
        []
      ]
    },
    "Telegram Trigger": {
      "main": [
        [
          {
            "node": "Bot Config",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filter Start Command": {
      "main": [
        [
          {
            "node": "Get row(s) in sheet",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Bot Config": {
      "main": [
        [
          {
            "node": "Filter Start Command",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "instanceId": "8a4e48e787c983353ccccf9e62bc7a8c245cc3f8f7803eef68ee4bc03c68182a"
  }
}

---

## Claude

Tôi đã đọc kỹ đoạn JSON. Đây là phần đầu của một workflow n8n: **Telegram Trigger → Bot Config → Filter Start Command → Get row(s) in sheet → Filter (Status=Generating) → Code in JavaScript**. Dưới đây là phân tích từng câu hỏi.

---

## 1. Cú pháp gọi đúng bot

Logic nằm ở node **Filter Start Command**:

- Vế trái: lấy **từ đầu tiên** của tin nhắn → `message.text` → `.toLowerCase().trim().split(' ')[0]`
- Vế phải: `'/run_' + bot_code` rồi `.toLowerCase()`, với `bot_code = "20KV4"` (trong **Bot Config**)

→ Chuỗi cần khớp là **`/run_20kv4`**.

**Vậy bạn gõ:**
```
/run_20kv4
```

Lưu ý:
- **Không phân biệt hoa/thường** (cả 2 vế đều `.toLowerCase()`), nên `/run_20KV4` cũng được.
- Vì chỉ so khớp **từ đầu tiên** (`split(' ')[0]`), bạn có thể gõ thêm chữ phía sau, ví dụ `/run_20kv4 start` vẫn chạy.
- **Sai nếu**: có dấu cách (`/run 20kv4`), dùng gạch ngang (`/run-20kv4`), hoặc thiếu dấu `_`.

---

## 2. Vì sao nhiều bot/flow cùng chạy & cách định danh

**Nguyên nhân khả dĩ (theo thứ tự hay gặp):**

1. **Nhiều workflow dùng chung 1 Telegram bot token** (cùng credential *"Telegram account"*). Mọi tin nhắn gửi tới con bot đó → mọi workflow đang active đều nhận trigger và chạy phần đầu.
2. **Bạn nhân bản workflow** ("My workflow 2 copy") nhưng **quên đổi `bot_code`** — nên nhiều bản cùng khớp `/run_20kv4` và cùng pass filter.
3. **Phản hồi không tự ghi danh** → bạn không biết bản nào vừa chạy.

**Cách sửa — định danh khi chạy:**

Trong n8n bạn truy cập được tên workflow bằng biểu thức:
- `{{ $workflow.name }}` → trả về **"My workflow 2 copy"** (tên thật của workflow)
- `{{ $workflow.id }}` → ID duy nhất

⚠️ **Quan trọng:** Dòng tiêu đề *"Workflow AI Auto - Make Product Better's Version"* mà bạn thấy chỉ là **Sticky Note** (ghi chú trên canvas) → **KHÔNG** lấy được bằng biểu thức. Muốn dùng tên đẹp này, bạn có 2 lựa chọn:

- **Cách A (khuyến nghị):** thêm 1 field `bot_name` ngay trong node **Bot Config** để bạn tự kiểm soát tên hiển thị, độc lập với tên workflow:

```
Bot Config (Set node):
  bot_code = "20KV4"
  bot_name = "Workflow AI Auto - Make Product Better's Version"
```
Rồi dùng `{{ $('Bot Config').first().json.bot_name }}` trong mọi tin nhắn.

- **Cách B:** đổi tên workflow trong n8n thành tên đẹp đó, rồi dùng `{{ $workflow.name }}`.

**Đồng thời:** với mỗi bản workflow nhân bản, đặt **`bot_code` khác nhau** (vd `20KV4`, `20KV5`…) để mỗi lệnh `/run_xxx` chỉ kích đúng 1 bot.

---

## 3. Thông báo tiến trình trên Telegram — kiểm tra trước khi làm

**Đính chính về chi phí:** Gửi tin nhắn qua **Telegram Bot API là MIỄN PHÍ** và không giới hạn (chỉ giới hạn tốc độ ~30 tin/giây). Phần tốn tiền là các node **AI/sinh ảnh** ở phía sau, **không phải** việc gửi thông báo. Nên:
- Nếu dùng **mẫu tin tĩnh + biến** (interpolation) → **chi phí ≈ 0**.
- Chỉ tốn token **nếu** bạn nhờ AI viết câu thông báo → **không cần**, hãy dùng template.

Vậy vấn đề thật sự cần tránh là **spam/khó đọc**, không phải tiền. Khuyến nghị chỉ báo ở các mốc có output thay đổi rõ:

| Mốc | Vị trí chèn | Nội dung gợi ý |
|---|---|---|
| ▶️ Bắt đầu | sau **Filter Start Command** | tên bot + giờ chạy |
| 📊 Đọc dữ liệu | sau **Filter (Status=Generating)** | số dòng đọc được / số dòng "Generating" |
| 🔧 Xử lý nặng | trước/sau node AI–sinh ảnh (nếu có) | đang xử lý item nào |
| ✅ Hoàn tất | node cuối | tổng số item đã xử lý |
| ⚠️ Lỗi | qua **Error Trigger** | node nào lỗi + message |

**Mẫu tin (không tốn token):**
```
chat_id:  ={{ $('Telegram Trigger').first().json.message.chat.id }}

text (mốc bắt đầu):
=▶️ {{ $('Bot Config').first().json.bot_name }} ({{ $workflow.name }})
⏱ {{ $now.format('yyyy-MM-dd HH:mm:ss') }}
Bắt đầu xử lý...

text (mốc đọc dữ liệu):
=📊 {{ $('Bot Config').first().json.bot_name }}
Đã đọc: {{ $('Get row(s) in sheet').all().length }} dòng
Status=Generating: {{ $('Filter').all().length }} dòng
```

**⚠️ Lưu ý kỹ thuật quan trọng (để không làm hỏng flow):**
Node *"Send a text message"* của Telegram sẽ **thay output `$json`** bằng response của Telegram. Nếu chèn thẳng giữa chuỗi, các node sau sẽ mất dữ liệu gốc. Có 2 cách an toàn:
- **Cách 1 (khuyến nghị):** **rẽ nhánh** — node nguồn nối tới **cả** node xử lý tiếp theo **lẫn** node Telegram (chạy song song). Thông báo không chen vào luồng dữ liệu chính.
- **Cách 2:** nếu chèn nối tiếp, các node sau phải tham chiếu theo tên `$('Tên node').item.json...` thay vì `$json`.

---

## Trước khi bắt đầu, tôi cần xác nhận:

1. **Bạn muốn tôi xuất luôn file JSON đã chỉnh** (thêm `bot_name`, định danh, các node thông báo) để bạn import lại không?
2. **JSON bạn gửi chỉ có 6 node** và node *Code in JavaScript* đang nối vào hư không. Nếu workflow thật còn các node AI/sinh ảnh phía sau, **bạn gửi tôi full JSON** để tôi gắn thông báo đúng các mốc đó (nếu không, tôi chỉ gắn được trong phạm vi 6 node này).
3. **Tên hiển thị** dùng theo **Cách A** (`bot_name` trong Bot Config) hay **Cách B** (đổi tên workflow)?

Bạn trả lời 3 ý trên (lý tưởng là dán full JSON), tôi sẽ dựng bản hoàn chỉnh ngay.

---

## Nguoi dung

Rồi, giờ cho tôi bộ node json được sửa lại để paste vào chạy test

---

## Claude

Vì bạn chỉ gửi 6 node nên tôi dựng bản chỉnh trong phạm vi 6 node này, đã thêm:

- `bot_name` vào **Bot Config**
- 2 node Telegram thông báo, **rẽ nhánh song song** (không chèn vào luồng dữ liệu nên không làm hỏng flow):
  - **Notify: Start** — rẽ từ *Filter Start Command*
  - **Notify: Data Loaded** — nối sau *Code in JavaScript*
- Mọi tin nhắn đều tự ghi danh bằng `bot_name` + `$workflow.name` + `$workflow.id`

Copy nguyên khối dưới đây rồi **paste thẳng vào canvas n8n** (Ctrl/Cmd+V):

```json
{
  "nodes": [
    {
      "parameters": {
        "updates": [
          "message"
        ],
        "additionalFields": {}
      },
      "type": "n8n-nodes-base.telegramTrigger",
      "typeVersion": 1.2,
      "position": [
        224,
        672
      ],
      "id": "6684901a-4d42-4699-965c-a66a8c62967c",
      "name": "Telegram Trigger",
      "webhookId": "a1b2c3d4-tg-trigger-0001",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "cfg-bot-code",
              "name": "bot_code",
              "value": "20KV4",
              "type": "string"
            },
            {
              "id": "cfg-bot-name",
              "name": "bot_name",
              "value": "Workflow AI Auto - Make Product Better's Version",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        400,
        672
      ],
      "id": "68a42b74-7dcd-4419-9c9c-3cbc3d050605",
      "name": "Bot Config"
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": false,
            "leftValue": "",
            "typeValidation": "loose",
            "version": 2
          },
          "conditions": [
            {
              "id": "cmd-run-code",
              "leftValue": "={{ ($('Telegram Trigger').first().json.message?.text || '').toString().toLowerCase().trim().split(' ')[0] }}",
              "rightValue": "={{ ('/run_' + ($('Bot Config').first().json.bot_code || '')).toLowerCase() }}",
              "operator": {
                "type": "string",
                "operation": "equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.filter",
      "typeVersion": 2.2,
      "position": [
        624,
        672
      ],
      "id": "74f06901-950c-4dce-848b-2a9b10f9cceb",
      "name": "Filter Start Command"
    },
    {
      "parameters": {
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "text": "=▶️ {{ $('Bot Config').first().json.bot_name }}\n🏷 Workflow: {{ $workflow.name }} | ID: {{ $workflow.id }}\n🔑 Lệnh: {{ $('Telegram Trigger').first().json.message.text }}\n⏱ {{ $now.format('yyyy-MM-dd HH:mm:ss') }}\n⏳ Bắt đầu xử lý...",
        "additionalFields": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        880,
        960
      ],
      "id": "b1f3a201-0001-4a10-9c01-notifystart01",
      "name": "Notify: Start",
      "webhookId": "a1b2c3d4-tg-notify-0001",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "documentId": {
          "__rl": true,
          "value": "13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU",
          "mode": "list",
          "cachedResultName": "Meta_Automation_GGSheet_Template",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit?usp=drivesdk"
        },
        "sheetName": {
          "__rl": true,
          "value": 2029473150,
          "mode": "list",
          "cachedResultName": "01_Genarated Images",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit#gid=2029473150"
        },
        "filtersUI": {
          "values": []
        },
        "options": {
          "returnFirstMatch": false
        }
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [
        880,
        752
      ],
      "id": "9397d928-07c4-4387-841e-0a2711219089",
      "name": "Get row(s) in sheet",
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict",
            "version": 3
          },
          "conditions": [
            {
              "id": "4415ed8b-32a8-416d-9526-9ca772d21440",
              "leftValue": "={{ $json[\"Status\"] }}",
              "rightValue": "Generating",
              "operator": {
                "type": "string",
                "operation": "equals",
                "name": "filter.operator.equals"
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "type": "n8n-nodes-base.filter",
      "typeVersion": 2.3,
      "position": [
        1088,
        752
      ],
      "id": "3dd5f682-afa6-4ce3-91d4-e187d28c80ce",
      "name": "Filter"
    },
    {
      "parameters": {
        "jsCode": "const pillar = $input.first().json[\"Link FB & Website\"] || \"\";\nconst links = pillar.split(/[|,\\n]/).map(s => s.trim()).filter(s => s.startsWith(\"http\"));\nconst fb = links.find(l => l.includes(\"facebook.com\")) || \"\";\nconst web = links.find(l => !l.includes(\"facebook.com\")) || \"\";\nreturn [{\n  json: {\n    ...$input.first().json,\n    fb_link: fb,\n    web_link: web\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1280,
        752
      ],
      "id": "dc604f22-4fb2-4a0a-8882-78fb5c472d2c",
      "name": "Code in JavaScript"
    },
    {
      "parameters": {
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "text": "=📊 {{ $('Bot Config').first().json.bot_name }}\n✅ Đã đọc sheet: {{ $('Get row(s) in sheet').all().length }} dòng\n🟡 Status=Generating: {{ $('Filter').all().length }} dòng\n🔗 Đã tách link FB/Web xong.\n⏱ {{ $now.format('HH:mm:ss') }}",
        "additionalFields": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        1480,
        752
      ],
      "id": "c2e4b302-0002-4b20-9d02-notifydata0002",
      "name": "Notify: Data Loaded",
      "webhookId": "a1b2c3d4-tg-notify-0002",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    }
  ],
  "connections": {
    "Telegram Trigger": {
      "main": [
        [
          {
            "node": "Bot Config",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Bot Config": {
      "main": [
        [
          {
            "node": "Filter Start Command",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filter Start Command": {
      "main": [
        [
          {
            "node": "Get row(s) in sheet",
            "type": "main",
            "index": 0
          },
          {
            "node": "Notify: Start",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get row(s) in sheet": {
      "main": [
        [
          {
            "node": "Filter",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filter": {
      "main": [
        [
          {
            "node": "Code in JavaScript",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript": {
      "main": [
        [
          {
            "node": "Notify: Data Loaded",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "instanceId": "8a4e48e787c983353ccccf9e62bc7a8c245cc3f8f7803eef68ee4bc03c68182a"
  }
}
```

### Cách test
1. Paste vào canvas → kiểm tra 2 node **Notify** đã có credential *Telegram account* (đã trỏ sẵn id cũ).
2. Bấm **Execute workflow** rồi gửi `/run_20kv4` cho bot → bạn sẽ nhận **tin "▶️ Start"** ngay, và **tin "📊 Data Loaded"** sau khi đọc/lọc sheet.

### Lưu ý quan trọng
- **Notify: Data Loaded chỉ gửi nếu có ≥1 dòng `Status=Generating`** (vì nó nằm sau *Code*, mà *Code* không chạy khi Filter ra 0 item). Nếu bạn muốn báo cả trường hợp "0 dòng", nói tôi tách thêm 1 nhánh báo riêng.
- **Mỗi bản workflow nhân bản nhớ đổi `bot_code`** (vd `20KV5`) để không bị nhiều bot cùng ăn 1 lệnh.
- Nếu workflow thật còn các node **AI / sinh ảnh** phía sau *Code in JavaScript*, hãy gửi tôi full JSON để tôi gắn thêm mốc "🔧 đang xử lý" và "✅ hoàn tất" đúng chỗ.

Bạn có muốn tôi thêm node **báo lỗi (Error Trigger)** để khi flow fail cũng nhắn về Telegram kèm tên bot không?
