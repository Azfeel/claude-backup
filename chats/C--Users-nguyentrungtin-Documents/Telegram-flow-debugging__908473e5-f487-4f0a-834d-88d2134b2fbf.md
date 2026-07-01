# Telegram flow debugging

- Phien: 908473e5-f487-4f0a-834d-88d2134b2fbf
- Project: C--Users-nguyentrungtin-Documents
- Cap nhat: 2026-07-01 14:22

---

## Nguoi dung

Sửa lại phần này cho tôi, flow đang chưa hoạt động được, hãy check xem lý do tại sao? 

{
  "nodes": [
    {
      "parameters": {
        "operation": "sendAndWait",
        "chatId": "6587544701",
        "message": "=✏️ ID {{ $('Persist Context').first().json.ID }} — {{ $('Persist Context').first().json.Brand }}\nBạn muốn sửa gì ở ảnh ({{ $json[\"Chọn version\"] }})?",
        "responseType": "customForm",
        "formFields": {
          "values": [
            {
              "fieldLabel": "Prompt sửa",
              "fieldType": "textarea",
              "requiredField": true
            }
          ]
        },
        "options": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        6048,
        10464
      ],
      "id": "ab6179b4-bd2b-4af1-ab3d-439bc90ca195",
      "name": "Send message and wait for response3",
      "webhookId": "19460701-70db-4e9f-9eb6-8960d4b69f18",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "operation": "update",
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
        "columns": {
          "mappingMode": "defineBelow",
          "value": {
            "ID": "={{ $('Persist Context').first().json.ID }}",
            "Prompt Update": "={{ $json[\"Prompt sửa\"] }}"
          },
          "matchingColumns": [
            "ID"
          ],
          "schema": [
            {
              "id": "ID",
              "displayName": "ID",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            },
            {
              "id": "Prompt Update",
              "displayName": "Prompt Update",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            }
          ],
          "attemptToConvertTypes": false,
          "convertFieldsToString": false
        },
        "options": {}
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [
        6272,
        10464
      ],
      "id": "4fddcc9a-69e1-4986-94df-c2b95be6d96a",
      "name": "Update row in sheet4",
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "ef-retry",
              "name": "retry_count",
              "value": "={{ ($('Persist Context').first().json.retry_count || 0) + 1 }}",
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        6496,
        10464
      ],
      "id": "402fb5a8-2c77-4288-a97c-202ef5f2abfd",
      "name": "Edit Fields8"
    }
  ],
  "connections": {
    "Send message and wait for response3": {
      "main": [
        [
          {
            "node": "Update row in sheet4",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Update row in sheet4": {
      "main": [
        [
          {
            "node": "Edit Fields8",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields8": {
      "main": [
        []
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

Tôi đã xem kỹ đoạn workflow n8n này. Có **3 lỗi** khiến flow không chạy đúng:

## Lý do flow không hoạt động

**1. Sai đường dẫn dữ liệu từ form trả về (lỗi chính)**

Node Telegram với operation `sendAndWait` + `responseType: customForm` trả kết quả **lồng trong key `data`**, chứ không nằm trực tiếp ở root. Tức là output của nó có dạng:

```json
{ "data": { "Prompt sửa": "nội dung user nhập" } }
```

Nhưng node "Update row in sheet4" đang đọc `{{ $json["Prompt sửa"] }}` → luôn là `undefined`, nên cột **Prompt Update** ghi vào Sheet bị rỗng. Phải sửa thành `{{ $json.data["Prompt sửa"] }}`.

**2. Tương tự với `$json["Chọn version"]` trong message**

Trong node "Send message and wait for response3", `$json` là input từ node phía trước. Nếu node trước cũng là một node sendAndWait dạng form (chọn version), thì giá trị nằm ở `$json.data["Chọn version"]` chứ không phải `$json["Chọn version"]` — hiện message sẽ hiển thị `undefined`. (Cái này không làm flow dừng, nhưng hiển thị sai.)

**3. Flow bị đứt ở cuối — "Edit Fields8" không nối đi đâu cả**

```json
"Edit Fields8": { "main": [ [] ] }
```

Node tăng `retry_count` xong thì **dead-end**, không quay lại node generate/sửa ảnh. Vì vậy sau khi user nhập prompt sửa, Sheet được update nhưng không có gì xảy ra tiếp theo. Bạn cần nối "Edit Fields8" về node tạo ảnh lại (regenerate).

Ngoài ra một lỗi logic tiềm ẩn: `retry_count` được tính từ `$('Persist Context').first().json.retry_count` — nếu node Persist Context không được chạy lại với giá trị mới, thì mỗi vòng lặp `retry_count` luôn bằng `cũ + 1` (mãi là 1), không cộng dồn. Nên đọc từ chính item đang chạy: `{{ ($json.retry_count ?? $('Persist Context').first().json.retry_count ?? 0) + 1 }}`.

## JSON đã sửa

```json
{
  "nodes": [
    {
      "parameters": {
        "operation": "sendAndWait",
        "chatId": "6587544701",
        "message": "=✏️ ID {{ $('Persist Context').first().json.ID }} — {{ $('Persist Context').first().json.Brand }}\nBạn muốn sửa gì ở ảnh ({{ $json.data ? $json.data[\"Chọn version\"] : $json[\"Chọn version\"] }})?",
        "responseType": "customForm",
        "formFields": {
          "values": [
            {
              "fieldLabel": "Prompt sửa",
              "fieldType": "textarea",
              "requiredField": true
            }
          ]
        },
        "options": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [6048, 10464],
      "id": "ab6179b4-bd2b-4af1-ab3d-439bc90ca195",
      "name": "Send message and wait for response3",
      "webhookId": "19460701-70db-4e9f-9eb6-8960d4b69f18",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "operation": "update",
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
        "columns": {
          "mappingMode": "defineBelow",
          "value": {
            "ID": "={{ $('Persist Context').first().json.ID }}",
            "Prompt Update": "={{ $json.data[\"Prompt sửa\"] }}"
          },
          "matchingColumns": ["ID"],
          "schema": [
            {
              "id": "ID",
              "displayName": "ID",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            },
            {
              "id": "Prompt Update",
              "displayName": "Prompt Update",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            }
          ],
          "attemptToConvertTypes": false,
          "convertFieldsToString": false
        },
        "options": {}
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [6272, 10464],
      "id": "4fddcc9a-69e1-4986-94df-c2b95be6d96a",
      "name": "Update row in sheet4",
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "ef-retry",
              "name": "retry_count",
              "value": "={{ ($json.retry_count ?? $('Persist Context').first().json.retry_count ?? 0) + 1 }}",
              "type": "number"
            },
            {
              "id": "ef-prompt",
              "name": "prompt_update",
              "value": "={{ $('Send message and wait for response3').first().json.data[\"Prompt sửa\"] }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [6496, 10464],
      "id": "402fb5a8-2c77-4288-a97c-202ef5f2abfd",
      "name": "Edit Fields8"
    }
  ],
  "connections": {
    "Send message and wait for response3": {
      "main": [
        [
          {
            "node": "Update row in sheet4",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Update row in sheet4": {
      "main": [
        [
          {
            "node": "Edit Fields8",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields8": {
      "main": [
        [
          {
            "node": "TÊN_NODE_GENERATE_ẢNH_CỦA_BẠN",
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

**Lưu ý khi paste:** thay `TÊN_NODE_GENERATE_ẢNH_CỦA_BẠN` bằng tên node tạo/sửa ảnh thật trong workflow đầy đủ của bạn (đoạn bạn gửi chỉ là 3 node cuối nên tôi không biết tên chính xác). Tôi cũng thêm field `prompt_update` vào Edit Fields8 để node generate phía sau lấy prompt sửa dễ dàng hơn.

## Checklist thêm nếu vẫn không chạy

- **Form không mở được từ điện thoại:** `customForm` của sendAndWait gửi một link form qua Telegram — link này trỏ về `WEBHOOK_URL` của n8n. Nếu n8n chạy localhost hoặc URL nội bộ, user bấm vào sẽ không mở được → flow treo mãi ở trạng thái "Waiting". Kiểm tra biến môi trường `WEBHOOK_URL` phải là URL public (https).
- **Kiểm tra execution log:** mở execution bị lỗi trong n8n, xem node nào màu đỏ/treo — nếu node Telegram đứng ở "Waiting" mãi thì là vấn đề webhook URL ở trên; nếu Sheets ghi rỗng thì là lỗi `$json.data` đã sửa ở trên.

---

## Nguoi dung

Chỗ này bị lỗi rồi, check lại, ngay từ bước đầu tiên đã sai rồi
Flow sẽ là gửi tin nhắn kêu điền prompt, sau đó get prompt đó về lại trong node over loop, rồi chạy lại toàn bộ flow

---

## Claude

Để tôi kiểm tra lại chính xác format output của node Telegram `sendAndWait` trong n8n trước, vì đó là điểm quyết định flow chạy hay không.

---

## Claude

Đã xác minh xong từ source code n8n — giờ tôi hiểu rõ vấn đề rồi. Có 2 lỗi chính, và tôi đã kiểm tra trực tiếp code của n8n để chắc chắn:

## Lỗi 1 — Bước đầu tiên: đọc sai output của node Telegram

Tôi đã đọc [source code sendAndWait của n8n](https://github.com/n8n-io/n8n/blob/master/packages/nodes-base/utils/sendAndWait/utils.ts) và xác nhận: với `responseType: customForm`, output **luôn bị bọc trong key `data`**:

```js
// code thật trong n8n:
returnItem.json = { data: json }   // json = các field của form
```

Tức là sau khi user điền form, node trả về:
```json
{ "data": { "Prompt sửa": "nội dung user nhập" } }
```

Nên mọi chỗ đọc `$json["Prompt sửa"]` đều ra `undefined`. Ngoài ra, trong message của node đầu tiên, `{{ $json["Chọn version"] }}` đọc từ input của node — field này không tồn tại ở root nên hiển thị `undefined` (nếu node trước cũng là sendAndWait thì nó nằm ở `$json.data["Chọn version"]`).

## Lỗi 2 — Vòng lặp bị đứt: Edit Fields8 không nối về đâu cả

`"Edit Fields8": { "main": [[]] }` — sau khi lấy prompt xong, flow **dừng luôn tại đó**, không quay về node Loop Over Items nên không bao giờ chạy lại flow.

## JSON đã sửa theo đúng flow bạn mô tả

Gửi tin nhắn hỏi prompt → lấy prompt từ form → ghi vào Sheet → quay về loop để chạy lại:

```json
{
  "nodes": [
    {
      "parameters": {
        "operation": "sendAndWait",
        "chatId": "6587544701",
        "message": "=✏️ ID {{ $('Persist Context').first().json.ID }} — {{ $('Persist Context').first().json.Brand }}\nBạn muốn sửa gì ở ảnh này? Bấm nút bên dưới để điền prompt sửa.",
        "responseType": "customForm",
        "formFields": {
          "values": [
            {
              "fieldLabel": "Prompt sửa",
              "fieldType": "textarea",
              "requiredField": true
            }
          ]
        },
        "options": {
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [6048, 10464],
      "id": "ab6179b4-bd2b-4af1-ab3d-439bc90ca195",
      "name": "Send message and wait for response3",
      "webhookId": "19460701-70db-4e9f-9eb6-8960d4b69f18",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "operation": "update",
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
        "columns": {
          "mappingMode": "defineBelow",
          "value": {
            "ID": "={{ $('Persist Context').first().json.ID }}",
            "Prompt Update": "={{ $json.data['Prompt sửa'] }}"
          },
          "matchingColumns": ["ID"],
          "schema": [
            {
              "id": "ID",
              "displayName": "ID",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            },
            {
              "id": "Prompt Update",
              "displayName": "Prompt Update",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            }
          ],
          "attemptToConvertTypes": false,
          "convertFieldsToString": false
        },
        "options": {}
      },
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [6272, 10464],
      "id": "4fddcc9a-69e1-4986-94df-c2b95be6d96a",
      "name": "Update row in sheet4",
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "ef-id",
              "name": "ID",
              "value": "={{ $('Persist Context').first().json.ID }}",
              "type": "string"
            },
            {
              "id": "ef-prompt",
              "name": "Prompt Update",
              "value": "={{ $('Send message and wait for response3').first().json.data['Prompt sửa'] }}",
              "type": "string"
            },
            {
              "id": "ef-retry",
              "name": "retry_count",
              "value": "={{ ($('Persist Context').first().json.retry_count || 0) + 1 }}",
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [6496, 10464],
      "id": "402fb5a8-2c77-4288-a97c-202ef5f2abfd",
      "name": "Edit Fields8"
    }
  ],
  "connections": {
    "Send message and wait for response3": {
      "main": [
        [
          {
            "node": "Update row in sheet4",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Update row in sheet4": {
      "main": [
        [
          {
            "node": "Edit Fields8",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields8": {
      "main": [
        [
          {
            "node": "Loop Over Items",
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

Thay `"Loop Over Items"` ở connection cuối bằng **tên chính xác** của node loop trong workflow của bạn.

## ⚠️ Một điểm quan trọng về cách Loop Over Items hoạt động

Node Loop Over Items (Split In Batches) khi nhận tín hiệu quay về input sẽ **nhả item TIẾP THEO trong hàng đợi**, chứ không chạy lại item hiện tại — nó bỏ qua dữ liệu bạn gửi về. Nghĩa là:

- Nếu ý bạn là **"sửa xong thì xử lý lại chính ảnh này với prompt mới"** → đừng nối về Loop Over Items, mà nối Edit Fields8 về **node đầu tiên bên trong vòng lặp** (node ngay sau output "loop" của Loop Over Items, ví dụ node generate ảnh). Vì Prompt Update đã được ghi vào Sheet, node generate chỉ cần đọc lại từ đó.
- Nếu ý bạn là **"ghi prompt vào Sheet rồi chuyển sang item kế tiếp"** → nối về Loop Over Items như JSON trên là đúng.

Nếu sửa xong mà node Telegram vẫn treo ở trạng thái "Waiting" mãi không nhận được form, thì kiểm tra biến `WEBHOOK_URL` của n8n phải là URL public — form mà customForm gửi qua Telegram mở trên trình duyệt điện thoại, localhost sẽ không mở được. Cũng có [issue đã biết](https://github.com/n8n-io/n8n/issues/23662) là sau khi bấm Submit, trang form đôi khi quay vòng mãi nhưng dữ liệu **vẫn được chuyển sang node tiếp theo** bình thường — cứ đóng tab là được.

Sources:
- [n8n sendAndWait utils source code](https://github.com/n8n-io/n8n/blob/master/packages/nodes-base/utils/sendAndWait/utils.ts)
- [GitHub issue #23662 — Telegram custom form loading after submit](https://github.com/n8n-io/n8n/issues/23662)
- [n8n Docs — Telegram message operations](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.telegram/message-operations/)

---

## Nguoi dung

Giải thích cho tôi vì sao cùng 1 brief, khi cho chạy lại, thì 1 cái lại ra rất đúng ý khi lấy được toàn bộ concept tổng thể, 1 cái lại lấy những chi tiết rất dư thừa. làm sao để có thể láy được concept tổng thể giống như này đối với tất cả các lần chạy tạo ảnh, chỉ sửa lại các chi tiết nhỏ? Đây là do mạc wdidnhj hay do phần code prompt đang chưa tốt?

---

## Claude

Câu trả lời ngắn gọn: **do cả hai, nhưng gốc rễ là cách pipeline của bạn đang vận hành** — mỗi lần chạy lại là một lần "tạo mới từ đầu", nên model có quyền tự do diễn giải lại brief, và sự ngẫu nhiên của model làm phần còn lại.

## Vì sao cùng 1 brief mà kết quả lúc đúng lúc sai

**1. Model sinh ảnh vốn dĩ ngẫu nhiên (stochastic)**

Mỗi lần generate, model khởi tạo từ một seed nhiễu khác nhau. Cùng một prompt, hai seed khác nhau sẽ cho hai bố cục khác nhau. Đây là bản chất của model, không phải lỗi — bạn không bao giờ loại bỏ được 100%, chỉ có thể **thu hẹp không gian diễn giải** của nó.

**2. Prompt đang "mở" quá nên model tự điền chỗ trống**

Đây là phần bạn kiểm soát được. Nhìn ảnh Ver 1 (các khối hộp chữ nhật bay lơ lửng vô nghĩa quanh ly cà phê) so với Ver 2 (các card album nhạc bay quanh ly + tay cầm AirPod — đúng concept "nhạc + cà phê"): gần như chắc chắn trong prompt có cụm kiểu *"floating elements/objects around the cup"* mà **không nói rõ object đó là gì**. Khi đó:

- Lần chạy may mắn: model "đoán" ra album cards → đúng ý.
- Lần chạy khác: model điền bừa bằng các khối hộp generic → chi tiết dư thừa.

Prompt càng mơ hồ ở phần nào, phương sai giữa các lần chạy càng lớn ở phần đó.

**3. Nếu flow của bạn có node AI viết prompt từ brief** (Agent/LLM node trước node generate) thì còn một tầng ngẫu nhiên nữa: mỗi vòng loop, LLM viết ra một prompt *khác nhau* từ cùng brief. Bạn đang nhân đôi độ ngẫu nhiên: prompt khác nhau × seed khác nhau.

## Cách để giữ concept tổng thể, chỉ sửa chi tiết nhỏ

Đây là điểm quan trọng nhất, và nó liên quan trực tiếp đến vòng loop "Prompt sửa" bạn đang xây:

**① Đừng regenerate — hãy EDIT ảnh đã chọn.** Khi user đã chọn được version ưng ý (Ver 2) và chỉ muốn sửa chi tiết, flow **không nên chạy lại text-to-image từ brief**. Thay vào đó, node generate trong vòng retry phải chuyển sang chế độ **image-to-image / edit**: gửi kèm **ảnh gốc đã chọn** + câu lệnh sửa ("Prompt sửa" user vừa điền). Các model hỗ trợ tốt việc này: Gemini 2.5 Flash Image (nano-banana), gpt-image-1 (endpoint edits), Flux Kontext. Khi có ảnh gốc làm neo, model giữ nguyên bố cục, ánh sáng, concept — chỉ thay đổi phần được yêu cầu. Đây chính xác là thứ bạn đang muốn.

Trong n8n: lưu URL/file ảnh đã chọn vào Sheet (cột kiểu `Selected Image URL`), vòng retry đọc URL đó, tải ảnh về và đưa vào node edit cùng với `Prompt Update` — thay vì quay lại node text-to-image ban đầu.

**② Khóa prompt lại sau khi đã duyệt.** Nếu vẫn cần generate mới, đừng để LLM viết lại prompt từ brief mỗi vòng. Lưu prompt của lần ra ảnh đẹp vào Sheet, các lần sau chỉ **nối thêm** yêu cầu sửa vào prompt đã duyệt, không viết lại từ đầu. Nếu dùng LLM viết prompt, hạ temperature xuống (0–0.3).

**③ Viết prompt đặc tả thay vì gợi ý.** Sửa template prompt để mọi thành phần thị giác đều được gọi tên cụ thể:

- ❌ "surrounded by floating elements, dynamic composition"
- ✅ "surrounded by exactly 8 floating vintage rock album cards (Bon Jovi, The Doors style), coffee beans and two small coffee splashes, a hand holding a single white earbud at bottom center, no other objects"

Thêm cả ràng buộc phủ định: *"no random geometric blocks, no unrelated products, no text overlays"*.

**④ Dùng seed nếu API hỗ trợ.** Một số API cho phép truyền `seed` — cùng prompt + cùng seed sẽ ra ảnh gần như giống hệt, hữu ích khi muốn tái tạo lại đúng ảnh cũ với chỉnh sửa nhỏ trong prompt. (Lưu ý: Gemini image hiện không expose seed, gpt-image-1 cũng không; Flux/SD qua Replicate hay fal.ai thì có.)

## Tóm lại

| Nguyên nhân | Tỷ trọng | Sửa được không |
|---|---|---|
| Model ngẫu nhiên theo bản chất | một phần | Không loại bỏ được, chỉ giảm bằng seed/ảnh neo |
| Prompt mơ hồ, để model tự điền | phần lớn | Sửa được — đặc tả cụ thể + negative constraints |
| Pipeline regenerate từ đầu thay vì edit ảnh đã chọn | **quyết định nhất** | Sửa được — chuyển vòng retry sang image-to-image edit |

Nếu bạn cho tôi xem prompt template hiện tại (hoặc node LLM đang viết prompt trong flow), tôi có thể sửa trực tiếp nó theo hướng ③ cho bạn.

---

## Nguoi dung

Khoan, flow đã chạy được phần update prompt, tôi cần bạn chạy thêm để có thể chạy được loop. Vì flow báo nhận thông tin xong, nhưng ko tự chạy được. Tôi sẽ gửi bạn proimpt ở phần loop over items{
  "nodes": [
    {
      "parameters": {
        "options": {}
      },
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [
        2736,
        10176
      ],
      "id": "fa18cb16-4bb7-41df-b5a0-f19d1628a0d1",
      "name": "Loop Over Items7"
    },
    {
      "parameters": {
        "jsCode": "const item = $input.first().json;\n\nlet brandGuideline = item.brand_guideline;\nif ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {\n  try {\n    let raw = String(item.content || item.message?.content)\n      .replace(/^```json\\s*/i, '').replace(/```\\s*$/i, '').trim();\n    brandGuideline = JSON.parse(raw);\n  } catch (e) { brandGuideline = brandGuideline || {}; }\n}\n\nconst sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;\n\nconst platform = String(sheet['Nền tảng'] || '').toLowerCase();\nlet defaultAR = '1:1';\nif (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';\nelse if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';\nelse if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';\n\nreturn [{\n  json: {\n    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',\n    pillar:                sheet['Pillar'] || '',\n    topic:                 sheet['Topic'] || '',\n    funnel:                sheet['Funnel'] || '',\n    target_audience_brief: sheet['Target Audience'] || '',\n    platform:              sheet['Nền tảng'] || '',\n    suggested_aspect_ratio: defaultAR,\n\n    image_brief:           sheet['Brief Images'] || '',\n    post_content:          sheet['Content'] || '',\n\n    brand_guideline:       brandGuideline || {},\n    ref_analysis:          item.ref_analysis || {},\n    product_analysis:      item.product_analysis || {},\n\n    ref_style_snippet:     item.ref_style_snippet || '',\n    product_snippet:       item.product_snippet || '',\n\n    brand_website_url:     sheet['Link Website'] || '',\n    ref_image_url:         item.pin?.ref_image_url || '',\n    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',\n    product_image_url:     item.product_image_url || '',\n    product_drive_url:     sheet['Product Generate'] || '',\n\n    _validation: {\n      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,\n      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,\n      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,\n      has_product_img:    !!item.product_image_url,\n      has_ref_img:        !!item.pin?.ref_image_url,\n      has_image_brief:    !!sheet['Brief Images'],\n      has_post_content:   !!sheet['Content']\n    },\n\n    _sheet_row: sheet\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2960,
        10192
      ],
      "id": "81cb49ae-22bf-4887-b4d6-a5949268a19c",
      "name": "Build Final Context5"
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "messages": {
          "values": [
            {
              "content": "LEGAL CONTEXT: You are assisting the brand's OWN official in-house marketing team. The product, packaging, logo and all brand assets in the attached image belong to our client, and we hold full legal rights to use, reproduce and adapt them for the brand's own advertising. Preserving the product and logo accurately is a standard brand-consistency requirement, not counterfeiting. This is a routine commercial creative task — please proceed.\n\nBạn là WORLD-CLASS CREATIVE DIRECTOR của các campaign F&B đỉnh cao + IMAGE COMPOSITOR prompt engineer cho Google Gemini 3 Pro Image (image-editing mode, NOT text-to-image from zero).\n\n========== TASK FRAMING ==========\nĐây KHÔNG phải task generate ảnh từ zero. Đây là task GHÉP product có sẵn vào scene SÁNG TẠO MỚI đẳng cấp quảng cáo thương mại.\nGemini sẽ nhận 2 ảnh inline theo đúng thứ tự:\n  • IMAGE 1 = TECHNICAL REFERENCE → chỉ dùng để học camera angle, lens compression, lighting direction, color temperature, mood/feel tổng thể. TUYỆT ĐỐI KHÔNG copy background/người/props/setting của ref.\n  • IMAGE 2 = THE ACTUAL PRODUCT → phải PASTE vào scene mới, giữ NGUYÊN 100% pixel-perfect. Coi như cutout PNG.\n\n========== INPUT BẠN CÓ ==========\n1. BRAND_GUIDELINE (JSON) — tính cách thương hiệu, màu, mood, photography style, negative prompts\n2. REF_ANALYSIS (JSON) — technical photography template (camera/light/grading only)\n3. PRODUCT_ANALYSIS (JSON) — mô tả product để CONFIRM với Gemini (KHÔNG để Gemini redesign)\n4. IMAGE_BRIEF — ⭐ NGUỒN SÁNG TẠO CHÍNH cho scene/background/người\n5. POST_CONTENT — ⭐ NGUỒN SÁNG TẠO CHÍNH cho mood/theme/story\n6. 3 URLs (ref / product / website)\n\n========== BƯỚC 0 — CHỌN CREATIVE MODE ==========\nĐọc PILLAR + IMAGE_BRIEF + POST_CONTENT để phân loại mục tiêu truyền thông rồi chọn mode:\n• MODE A — BOLD COMMERCIAL KEY VISUAL (dùng khi promotion / launch / menu hero / lễ hội): product hero chiếm 40-60% khung hình, nguyên liệu ĐÚNG VỊ của product bay lơ lửng, splash chất lỏng đóng băng chuyển động, đá viên lơ lửng, condensation chi tiết, backdrop kịch tính (bầu trời xanh rực + sunburst / hoàng hôn cháy / landscape siêu thực), bố cục trung tâm hoặc đường chéo mạnh, độ chi tiết CGI-grade như poster campaign Pepsi/Starbucks.\n• MODE B — CINEMATIC LIFESTYLE (dùng khi storytelling / community / văn hóa / cảm xúc): môi trường thật có hơi ấm con người và câu chuyện (đường phố, cafe, chợ, biển...), chiều sâu phân lớp foreground-midground-background, golden hour hoặc ánh sáng moody, film stock cụ thể, năng lượng editorial tự nhiên.\nNêu rõ mode đã chọn trong scene_creative_ideas.\n\n========== QUY TẮC TUYỆT ĐỐI ==========\n\n[A] PRODUCT LOCK (priority #1 — vi phạm = fail):\n- Treat IMAGE 2 as a fixed visual asset. PASTE it in. DO NOT redraw, restyle, recolor, retouch, smooth, beautify, reinterpret, or 'improve' bất kỳ chi tiết nào.\n- Preserve pixel-perfect: container shape, transparency, ALL printed label text, logo placement & color, drink color layers, foam, toppings, garnish, ice density, condensation, opacity, proportions.\n- KHÔNG được phép phóng đại / minh hoạ / cách điệu hoá product (scale to khung hình được, nhưng product giữ nguyên hình dạng).\n- Nếu scene có tay người cầm product → tay KHÔNG được che logo chính.\n\n[B] TECHNICAL REFERENCE (priority #2 — chỉ mượn KỸ THUẬT từ IMAGE 1):\n- Từ IMAGE 1 CHỈ mượn: camera angle, framing tightness, focal length feel, lens compression, lighting direction, shadow softness, color temperature, mood/vibe.\n- TUYỆT ĐỐI KHÔNG copy: background, environment, người mẫu, outfit, gesture, props, setting, layout của ref.\n\n[C] CREATIVE SCENE (priority #3 — SCENE PHẢI MỚI HOÀN TOÀN VÀ ĐẲNG CẤP):\n- Background, environment, props, model, gesture, pose, outfit, setting phải được SÁNG TẠO MỚI dựa CHỦ YẾU vào IMAGE_BRIEF + POST_CONTENT, theo MODE đã chọn ở Bước 0.\n- BẮT BUỘC mô tả trong prompt: (1) COMPOSITION GEOMETRY — product nằm đâu trong khung, scale bao nhiêu %, các lớp foreground/midground/background, leading lines; (2) NEGATIVE SPACE — chừa MỘT vùng sạch (1/3 trên hoặc một bên) nền đơn giản để designer thêm typography SAU, ảnh tự thân không có chữ; (3) ATMOSPHERE FX vật lý thật và đúng vị product: splash arcs, droplets, condensation, steam, garnish bay, ice shatter; (4) COLOR STORY neo vào brand palette + dominant colors HEX của product; (5) LIGHTING SETUP đầy đủ: key direction & quality, rim, fill, practicals, haze/god rays.\n- ELEVATE: cinematic depth-of-field, atmospheric layers, premium production value — ảnh phải ấn tượng hơn hẳn ref.\n\n[D] NO TEXT (strict):\n- Zero captions, headlines, typography, watermark, sticker text, hashtags, graphic overlay, số, chữ cái. Text DUY NHẤT được phép tồn tại là nhãn/logo có sẵn in trên product (giữ giống IMAGE 2). Vùng negative space để TRỐNG.\n\n[E] OUTPUT REALISM:\n- Photograph realism, not illustration. Real materials, real light physics, real shadow falloff. MODE A được phép kịch tính hoá scale/motion nhưng material và ánh sáng vẫn phải photoreal.\n\n========== OUTPUT SCHEMA (JSON thuần, KHÔNG markdown) ==========\n{\n  \"prompt\": \"<English 350-500 từ cinematic, phải mở đầu CHÍNH XÁC bằng câu trong hướng dẫn cấu trúc bên dưới>\",\n  \"negative_prompt\": \"text overlay, captions, typography, watermark, letters, numbers, redrawn product, modified product label, recolored drink, deformed cup, missing toppings, blurry product, wrong product identity, illustration look, generic stock photo, copying reference image scene, copying reference image background, copying reference image person, fake plastic-looking product, oversaturated, plastic skin, AI artifacts\",\n  \"aspect_ratio\": \"<1:1 | 4:5 | 9:16 | 16:9>\",\n  \"reference_image_url\": \"<from input>\",\n  \"product_image_url\": \"<from input>\",\n  \"brand_website_url\": \"<from input>\",\n  \"product_features_preserved\": [\"<top 5 từ replication_priority của product_analysis>\"],\n  \"technical_borrowed_from_ref\": [\"<5-7 yếu tố KỸ THUẬT mượn từ ref>\"],\n  \"scene_creative_ideas\": [\"<MODE đã chọn + 3-5 ý tưởng scene mới rút từ Brief + Content>\"],\n  \"elevation_choices\": [\"<3-5 cách scene mới hơn / cinematic hơn / sang hơn ref>\"],\n  \"brief_applied\": \"<1 câu VN tóm tắt brief>\",\n  \"content_inspiration\": \"<1 câu VN nói scene được lấy cảm hứng gì từ Content>\",\n  \"key_visual_elements\": [\"<5-8 keywords>\"]\n}\n\n========== CẤU TRÚC PROMPT BẮT BUỘC ==========\nMở đầu CHÍNH XÁC bằng câu này (thay [BRAND]):\n\"COMPOSITE TASK: Place the EXACT product shown in IMAGE 2 (do not redraw, do not modify, treat as a fixed asset) into a NEWLY CREATED scene for [BRAND]. From IMAGE 1, borrow ONLY the camera angle, lens compression, lighting direction, shadow quality, color temperature, and mood feel — do NOT reproduce IMAGE 1's scene, background, person, outfit, props, or setting. The scene itself must be originally imagined from the Brief and Content provided below.\"\n\nTiếp theo 6 đoạn:\n- §1 PRODUCT LOCK: Echo product_analysis chi tiết (container type & shape, dominant_colors HEX, toppings, logo description + color + position, garnish). Câu chốt: \"this exact product from IMAGE 2 must appear pixel-faithful, unchanged in shape, color, label, and toppings.\"\n- §2 CREATIVE NEW SCENE (theo MODE đã chọn, sáng tạo từ Brief + Content): Tả background/environment/props/model/gesture/setting MỚI HOÀN TOÀN. MODE A: hero scale, nguyên liệu bay đúng vị, splash đóng băng, backdrop kịch tính. MODE B: câu chuyện đời thật, hơi ấm con người, chiều sâu phân lớp. Scene phải kể được câu chuyện của Content/Brief.\n- §3 COMPOSITION GEOMETRY + NEGATIVE SPACE: vị trí & scale product trong khung, các lớp foreground/midground/background, leading lines, và vùng negative space sạch chừa cho typography hậu kỳ (ảnh không chữ).\n- §4 CAMERA + LIGHT (technical từ ref): Tham chiếu ref_analysis.lens_and_settings, ref_analysis.lighting, ref_analysis.camera_angle. Add cụ thể: key light direction & quality, rim light, fill, practicals, haze/god rays, atmosphere FX (splash/droplets/steam/condensation đúng vị product).\n- §5 COLOR GRADING + MOOD: dùng ref_analysis.color_palette + post_processing (film stock). Echo brand_guideline.image_generation_guideline.color_grading + brand color hints. 3-4 mood adjectives.\n- §6 HARD CONSTRAINTS REPEAT: 'No text, letters, numbers or typography of any kind anywhere in the image except the product\\'s own printed label. The product must remain identical to IMAGE 2. The scene must be newly created from the Brief and Content — do not reproduce IMAGE 1\\'s background, person, or setting.'"
            },
            {
              "content": "=BRAND: {{ $json.brand_name }}\nPILLAR: {{ $json.pillar }}\nTOPIC: {{ $json.topic }}\nPLATFORM: {{ $json.platform }}\nASPECT RATIO: {{ $json.suggested_aspect_ratio }}\nTARGET AUDIENCE: {{ $json.target_audience_brief }}\n\n========== ⭐ IMAGE_BRIEF (team request) ==========\n{{ $json.image_brief || '(none)' }}\n\n========== ⭐ POST_CONTENT ==========\n{{ $json.post_content || '(none)' }}\n\n========== 🎨 BRAND_GUIDELINE ==========\n{{ JSON.stringify($json.brand_guideline, null, 2) }}\n\n========== 📸 REF_ANALYSIS (style only — NOT subject) ==========\n{{ JSON.stringify($json.ref_analysis, null, 2) }}\n\nRef snippet: {{ $json.ref_style_snippet }}\n\n========== 🥤 PRODUCT_ANALYSIS (must be preserved pixel-perfect) ==========\n{{ JSON.stringify($json.product_analysis, null, 2) }}\n\nProduct snippet:\n{{ $json.product_snippet }}\n\n========== 🔗 URLs ==========\n- reference_image_url: {{ $json.ref_image_url }}\n- product_image_url: {{ $json.product_image_url }}\n- brand_website_url: {{ $json.brand_website_url }}\n\n========== VALIDATION ==========\n{{ JSON.stringify($json._validation) }}\n\nGenerate MASTER COMPOSITOR PROMPT theo schema bắt buộc."
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.4
        }
      },
      "id": "c19f9622-a7b4-42ef-8e0b-079954ae9d34",
      "name": "Generate Final Prompt6",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        3152,
        10192
      ],
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    }
  ],
  "connections": {
    "Loop Over Items7": {
      "main": [
        [],
        [
          {
            "node": "Build Final Context5",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Build Final Context5": {
      "main": [
        [
          {
            "node": "Generate Final Prompt6",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Generate Final Prompt6": {
      "main": [
        []
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

Tôi đã tìm ra lý do flow "nhận thông tin xong nhưng không tự chạy tiếp", và có 1 lỗi tiềm ẩn nữa nhìn thấy ngay trong screenshot của bạn.

## Vì sao loop không tự chạy

Nhìn connections của fragment bạn gửi:

```json
"Loop Over Items7": {
  "main": [
    [],                                      ← output "done" : KHÔNG nối đi đâu
    [ { "node": "Build Final Context5" } ]   ← output "loop" : vào flow generate
  ]
}
```

Node **Loop Over Items (Split In Batches) khi nhận tín hiệu quay về input sẽ KHÔNG xử lý lại item bạn gửi về** — nó chỉ hiểu là "cho tôi batch tiếp theo". Vì item duy nhất đã được xử lý xong từ vòng đầu, hàng đợi rỗng → nó nhả ra output **"done"** — mà output done đang nối vào **khoảng trống**. Execution kết thúc êm ru, không lỗi, không chạy gì. Đó chính xác là hiện tượng bạn thấy.

**Cách sửa đúng:** nối `Edit Fields9` **bỏ qua Loop Over Items7**, đổ thẳng vào `Build Final Context5` (node đầu tiên trong thân loop). Nhưng có một vấn đề kéo theo: `Build Final Context5` đọc `$input.first().json` và mong đợi cả row data (brand_guideline, ref_analysis, Brief Images…), trong khi `Edit Fields9` chỉ có 3 field `ID / Prompt Update / retry_count` → context sẽ rỗng hết. Nên phải sửa code của Build Final Context5 để khi là vòng retry thì **tự lấy lại context gốc từ Persist Context**.

## 3 thứ cần sửa

### ① Connections — xóa dây Edit Fields9 → Loop Over Items7 (nếu có), nối như sau

```json
"Edit Fields9": {
  "main": [
    [
      { "node": "Build Final Context5", "type": "main", "index": 0 }
    ]
  ]
}
```

Giữ nguyên `Loop Over Items7` output "loop" → `Build Final Context5` như cũ (node này giờ có 2 nguồn vào: vòng đầu từ loop, vòng sửa từ Edit Fields9).

### ② Thay toàn bộ code của "Build Final Context5"

```javascript
const input = $input.first().json;

// ===== RETRY MODE =====
// Vòng sửa ảnh: Edit Fields9 đổ thẳng vào đây với { ID, Prompt Update, retry_count }.
// Khi đó lấy lại toàn bộ context gốc từ Persist Context rồi đè field mới lên.
const promptUpdate = input['Prompt Update'] || input.prompt_update || '';
const isRetry = promptUpdate !== '';

let item = input;
if (isRetry) {
  const persisted = Object.assign({}, ...$('Persist Context').all().map(i => i.json));
  item = { ...persisted, ...input };
}

let brandGuideline = item.brand_guideline;
if ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {
  try {
    let raw = String(item.content || item.message?.content)
      .replace(/^```json\s*/i, '').replace(/```\s*$/i, '').trim();
    brandGuideline = JSON.parse(raw);
  } catch (e) { brandGuideline = brandGuideline || {}; }
}

const sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;

const platform = String(sheet['Nền tảng'] || '').toLowerCase();
let defaultAR = '1:1';
if (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';
else if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';
else if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';

// Vòng sửa: nếu Persist Context có lưu URL ảnh đã generate/đã chọn,
// dùng nó làm reference để giữ nguyên bố cục — đổi tên field cho khớp dữ liệu của bạn.
const retryRefImage = item.selected_image_url || item.generated_image_url || '';

return [{
  json: {
    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',
    pillar:                sheet['Pillar'] || '',
    topic:                 sheet['Topic'] || '',
    funnel:                sheet['Funnel'] || '',
    target_audience_brief: sheet['Target Audience'] || '',
    platform:              sheet['Nền tảng'] || '',
    suggested_aspect_ratio: defaultAR,

    image_brief:           sheet['Brief Images'] || '',
    post_content:          sheet['Content'] || '',

    prompt_update:         promptUpdate,
    is_retry:              isRetry,
    retry_count:           item.retry_count || 0,

    brand_guideline:       brandGuideline || {},
    ref_analysis:          item.ref_analysis || {},
    product_analysis:      item.product_analysis || {},

    ref_style_snippet:     item.ref_style_snippet || '',
    product_snippet:       item.product_snippet || '',

    brand_website_url:     sheet['Link Website'] || '',
    ref_image_url:         (isRetry && retryRefImage) ? retryRefImage : (item.pin?.ref_image_url || ''),
    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',
    product_image_url:     item.product_image_url || '',
    product_drive_url:     sheet['Product Generate'] || '',

    _validation: {
      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,
      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,
      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,
      has_product_img:    !!item.product_image_url,
      has_ref_img:        !!(item.pin?.ref_image_url || retryRefImage),
      has_image_brief:    !!sheet['Brief Images'],
      has_prompt_update:  isRetry,
      has_post_content:   !!sheet['Content']
    },

    _sheet_row: sheet
  }
}];
```

### ③ "Generate Final Prompt6" — dạy LLM biết đây là vòng sửa

**Thêm vào CUỐI system prompt** (message đầu tiên):

```
========== ✏️ EDIT MODE (khi USER EDIT REQUEST ≠ none) ==========
Nếu input có USER EDIT REQUEST: đây là vòng SỬA ảnh đã duyệt, KHÔNG phải sáng tạo lại từ đầu.
- GIỮ NGUYÊN concept tổng thể, bố cục, scene, lighting đã mô tả từ IMAGE_BRIEF + POST_CONTENT như lần trước.
- CHỈ thay đổi đúng những điểm user yêu cầu trong EDIT REQUEST, không thêm ý tưởng mới ngoài yêu cầu.
- Nếu EDIT REQUEST mâu thuẫn với IMAGE_BRIEF → EDIT REQUEST thắng.
- Vẫn tuân thủ tuyệt đối PRODUCT LOCK, NO TEXT, OUTPUT REALISM.
```

**Thêm vào user message** (message thứ hai), ngay dưới dòng TARGET AUDIENCE:

```
========== ✏️ USER EDIT REQUEST (vòng sửa — ưu tiên cao nhất) ==========
{{ $json.prompt_update || '(none — first generation)' }}
RETRY COUNT: {{ $json.retry_count || 0 }}
```

## ⚠️ Lỗi tiềm ẩn nhìn thấy trong screenshot: `"ID": null`

Output của Edit Fields9 đang là `"ID": null` — tức `$('Persist Context').first().json.ID` không có giá trị. Persist Context của bạn có **2 items**, rất có thể ID nằm ở item thứ hai. Nếu ID null thì node Update row in sheet5 match sai dòng (hoặc không match). Sửa expression ID trong Edit Fields9 thành dạng quét cả 2 items:

```
{{ $('Persist Context').all().map(i => i.json.ID).find(id => id) }}
```

(Code Build Final Context5 ở trên đã dùng `Object.assign({}, ...all())` nên tự gộp cả 2 items, không bị lỗi này.)

## Một gợi ý để "giữ background và cách cầm ly" thật sự hiệu quả

Prompt sửa của bạn ("Giữ background và cách cầm ly nước trên…") đang chỉ là **chữ** — model generate mới sẽ không biết "background trên" trông như thế nào. Cách ăn chắc: ở vòng retry, **dùng chính ảnh đã chọn làm IMAGE 1 (reference)** thay cho ref Pinterest gốc — code ở trên đã chuẩn bị sẵn qua biến `retryRefImage`, bạn chỉ cần đảm bảo Persist Context (hoặc node "Chọn ver Image/Edit & Wait3") lưu URL ảnh version user đã chọn vào field `selected_image_url`. Khi đó Gemini nhìn thấy đúng background/cách cầm ly cũ và chỉ sửa chi tiết — đúng mong muốn "giữ concept tổng thể, chỉ sửa chi tiết nhỏ" bạn hỏi ở câu trước.

---

## Nguoi dung

Vòng loop, chỗ done có cần nối vô chỗ build final context ko? Hay nên vẽ ra cái mới

---

## Claude

Câu trả lời ngắn gọn: **KHÔNG nối "done" vào Build Final Context5.** Để trống hoặc vẽ nhánh mới làm việc kết thúc (ví dụ gửi Telegram báo "đã xong hết").

## Vai trò của 2 output này khác nhau hoàn toàn

```
Loop Over Items7
├── done  → chỉ bắn 1 LẦN DUY NHẤT khi đã xử lý HẾT tất cả các row
│           → dùng cho việc "kết thúc": báo cáo tổng kết, gửi noti "✅ Hoàn tất"
│           → để trống cũng được, flow tự kết thúc
│
└── loop  → bắn ra TỪNG row một → Build Final Context5 → generate → ... (như hiện tại, đúng rồi)
```

Nếu bạn nối **done → Build Final Context5**, điều xảy ra là: sau khi xử lý xong row cuối cùng, output done sẽ nhả ra item lần nữa và **chạy lại toàn bộ flow generate thêm một lần thừa** — tốn tiền API và tạo ảnh trùng. Tệ hơn, nếu phía cuối nhánh đó lại quay về Loop Over Items7 thì có nguy cơ lặp vô hạn.

## Sơ đồ nối đúng cho cả 3 luồng

Dựa trên screenshot của bạn (Switch10 có các nhánh ver1 / ver2 / edit_ver1 / edit_ver2):

| Luồng | Nối từ đâu → đâu | Ý nghĩa |
|---|---|---|
| Chạy item mới | `Loop Over Items7 (loop)` → `Build Final Context5` | ✅ đang đúng, giữ nguyên |
| User chọn OK (ver1/ver2) | cuối nhánh approve (sau khi lưu kết quả) → **quay về input của `Loop Over Items7`** | báo loop "item này xong, nhả item tiếp theo" |
| User yêu cầu sửa (edit_ver1/edit_ver2) | `Edit Fields9` → **thẳng vào `Build Final Context5`** (bỏ qua loop node) | chạy lại chính item này với Prompt Update — như đã sửa ở bước trước |
| Hết tất cả items | `Loop Over Items7 (done)` → node Telegram mới "✅ Đã xử lý xong toàn bộ" (hoặc để trống) | kết thúc workflow |

Điểm dễ nhầm nhất: **chỉ duy nhất nhánh "approve xong item" mới quay về input của Loop Over Items7**. Nhánh sửa ảnh tuyệt đối không đi qua loop node (vì loop sẽ nhảy sang item kế tiếp thay vì chạy lại item hiện tại), và done thì không bao giờ quay ngược vào thân loop.

Nếu bạn muốn có tổng kết đẹp ở cuối, vẽ thêm 1 node Telegram nối vào done với message kiểu:

```
=✅ Hoàn tất! Đã xử lý {{ $items().length }} ảnh trong batch này.
```

---

## Nguoi dung

Vậy check lại nguyên bộ Json này, xem có cần update thêm phần nào ko? (update phần prompt sửa bổ sung vào ấy,). Chỗ nào ko cần sửa thì cứ để nguyên, báo cho tôi beiets từng chỗ update là gì

{
  "nodes": [
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "p1-id",
              "name": "ID",
              "value": "={{ $('Build Final Context5').first().json._sheet_row['ID'] }}",
              "type": "string"
            },
            {
              "id": "p1-brand",
              "name": "Brand",
              "value": "={{ $('Build Final Context5').first().json._sheet_row['Brand'] || $('Build Final Context5').first().json.brand_name }}",
              "type": "string"
            },
            {
              "id": "p1-content",
              "name": "post_content",
              "value": "={{ $('Build Final Context5').first().json.post_content }}",
              "type": "string"
            },
            {
              "id": "p1-brief",
              "name": "image_brief",
              "value": "={{ $('Build Final Context5').first().json.image_brief }}",
              "type": "string"
            },
            {
              "id": "p1-topic",
              "name": "topic",
              "value": "={{ $('Build Final Context5').first().json.topic }}",
              "type": "string"
            },
            {
              "id": "p1-pillar",
              "name": "pillar",
              "value": "={{ $('Build Final Context5').first().json.pillar }}",
              "type": "string"
            },
            {
              "id": "p1-retry",
              "name": "retry_count",
              "value": "={{ $('Prep Gemini Input7').first().json.retry_count || 0 }}",
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        5344,
        10192
      ],
      "id": "884a0cdf-7cd0-4fa8-ba3d-68b6f44688fd",
      "name": "Persist Context"
    },
    {
      "parameters": {
        "options": {}
      },
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [
        2736,
        10176
      ],
      "id": "fa18cb16-4bb7-41df-b5a0-f19d1628a0d1",
      "name": "Loop Over Items7"
    },
    {
      "parameters": {
        "jsCode": "const item = $input.first().json;\n\nlet brandGuideline = item.brand_guideline;\nif ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {\n  try {\n    let raw = String(item.content || item.message?.content)\n      .replace(/^```json\\s*/i, '').replace(/```\\s*$/i, '').trim();\n    brandGuideline = JSON.parse(raw);\n  } catch (e) { brandGuideline = brandGuideline || {}; }\n}\n\nconst sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;\n\nconst platform = String(sheet['Nền tảng'] || '').toLowerCase();\nlet defaultAR = '1:1';\nif (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';\nelse if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';\nelse if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';\n\nreturn [{\n  json: {\n    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',\n    pillar:                sheet['Pillar'] || '',\n    topic:                 sheet['Topic'] || '',\n    funnel:                sheet['Funnel'] || '',\n    target_audience_brief: sheet['Target Audience'] || '',\n    platform:              sheet['Nền tảng'] || '',\n    suggested_aspect_ratio: defaultAR,\n\n    image_brief:           sheet['Brief Images'] || '',\n    post_content:          sheet['Content'] || '',\n\n    brand_guideline:       brandGuideline || {},\n    ref_analysis:          item.ref_analysis || {},\n    product_analysis:      item.product_analysis || {},\n\n    ref_style_snippet:     item.ref_style_snippet || '',\n    product_snippet:       item.product_snippet || '',\n\n    brand_website_url:     sheet['Link Website'] || '',\n    ref_image_url:         item.pin?.ref_image_url || '',\n    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',\n    product_image_url:     item.product_image_url || '',\n    product_drive_url:     sheet['Product Generate'] || '',\n\n    _validation: {\n      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,\n      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,\n      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,\n      has_product_img:    !!item.product_image_url,\n      has_ref_img:        !!item.pin?.ref_image_url,\n      has_image_brief:    !!sheet['Brief Images'],\n      has_post_content:   !!sheet['Content']\n    },\n\n    _sheet_row: sheet\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2960,
        10192
      ],
      "id": "81cb49ae-22bf-4887-b4d6-a5949268a19c",
      "name": "Build Final Context5"
    },
    {
      "parameters": {
        "url": "={{ $('Parse Pinterest Data (Update)3').item.json.pin.ref_image_url }}",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file",
              "outputPropertyName": "ref_image"
            }
          },
          "timeout": 30000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        3760,
        10192
      ],
      "id": "5e562050-7e79-44ed-a21d-7c44858cca6c",
      "name": "DL Ref Image4",
      "alwaysOutputData": true,
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "continueOnFail": true
    },
    {
      "parameters": {
        "url": "={{ $json.product_image_url }}",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file",
              "outputPropertyName": "product_image"
            }
          },
          "timeout": 30000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        3952,
        10192
      ],
      "id": "b03af783-dae0-48de-a1db-ba29a4daba93",
      "name": "DL Product Image4",
      "alwaysOutputData": true,
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "continueOnFail": true
    },
    {
      "parameters": {
        "jsCode": "const item = $input.first();\n\nif (!item.binary?.ref_image) {\n  throw new Error(\"Missing binary ref_image\");\n}\n\nif (!item.binary?.product_image) {\n  throw new Error(\"Missing binary product_image\");\n}\n\nconst refBuffer = await this.helpers.getBinaryDataBuffer(0, \"ref_image\");\nconst productBuffer = await this.helpers.getBinaryDataBuffer(0, \"product_image\");\n\nconst basePrompt    = item.json.full_prompt_text    || item.json.prompt || \"\";\nconst variantPrompt = item.json.full_prompt_variant || basePrompt;\n\nconst refMime     = item.binary.ref_image.mimeType     || \"image/jpeg\";\nconst productMime = item.binary.product_image.mimeType || \"image/png\";\n\nconst refB64     = refBuffer.toString(\"base64\");\nconst productB64 = productBuffer.toString(\"base64\");\n\nconst buildBody = (promptText) => ({\n  contents: [\n    {\n      role: \"user\",\n      parts: [\n        { text: promptText },\n        { inline_data: { mime_type: refMime,     data: refB64 } },\n        { inline_data: { mime_type: productMime, data: productB64 } }\n      ]\n    }\n  ],\n  generationConfig: {\n    candidateCount: 1,\n    responseModalities: [\"TEXT\", \"IMAGE\"]\n  }\n});\n\nreturn [\n  {\n    json: {\n      full_prompt_text:    basePrompt,\n      full_prompt_variant: variantPrompt,\n      ref_mime:            refMime,\n      product_mime:        productMime,\n      gemini_body:         buildBody(basePrompt),\n      gemini_body_variant: buildBody(variantPrompt)\n    }\n  }\n];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4160,
        10192
      ],
      "id": "8511aaf3-a963-4a4c-b3ba-c96c49b262e8",
      "name": "Prepare Gemini Images2"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ $json.gemini_body }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        4448,
        10096
      ],
      "id": "916d35e7-7fb2-4cce-b9c5-1bfa2a83b2da",
      "name": "Call Gemini v6",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ $json.gemini_body_variant }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        4448,
        10288
      ],
      "id": "9253a6f0-6266-4ea4-80dd-8499f04bbf5f",
      "name": "Call Gemini v7",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const res = $input.first().json;\n\nif (res.error) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: res.error.message || JSON.stringify(res.error),\n    raw: res\n  } }];\n}\n\nconst candidates = res.candidates || [];\nif (candidates.length === 0) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: 'No candidates',\n    block_reason: res.promptFeedback?.blockReason || null,\n    safety_ratings: res.promptFeedback?.safetyRatings || null,\n    raw: res\n  } }];\n}\n\nconst cand = candidates[0];\nconst parts = cand.content?.parts || [];\n\nconst imagePart  = parts.find(p => p.inlineData || p.inline_data);\nconst inlineData = imagePart?.inlineData || imagePart?.inline_data;\n\nif (!inlineData?.data) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: 'No image in response',\n    finish_reason: cand.finishReason || null,\n    text_parts: parts.filter(p => p.text).map(p => p.text),\n    raw: res\n  } }];\n}\n\nconst base64Data = inlineData.data;\nconst mimeType   = inlineData.mimeType || inlineData.mime_type || 'image/png';\nconst ext        = mimeType.split('/')[1]?.split('+')[0] || 'png';\nconst fileName   = `gemini_v1_${Date.now()}.${ext}`;\nconst sizeKB     = Math.round(base64Data.length * 0.75 / 1024);\n\nreturn [{\n  json: {\n    success: true,\n    variant: 'v1',\n    mime_type:     mimeType,\n    file_name:     fileName,\n    size_kb:       sizeKB,\n    finish_reason: cand.finishReason || 'STOP'\n  },\n  binary: {\n    data: {\n      data: base64Data,\n      mimeType,\n      fileName\n    }\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4672,
        10096
      ],
      "id": "01817e44-58e2-4e40-b333-585c539bf9de",
      "name": "Extract Image v3"
    },
    {
      "parameters": {
        "jsCode": "const res = $input.first().json;\n\nif (res.error) {\n  return [{ json: { success: false, variant: 'v2', error: res.error.message || JSON.stringify(res.error), raw: res } }];\n}\n\nconst candidates = res.candidates || [];\nif (candidates.length === 0) {\n  return [{ json: { success: false, variant: 'v2', error: 'No candidates', finish_reason: res.promptFeedback?.blockReason || null, raw: res } }];\n}\n\nconst cand = candidates[0];\nconst parts = cand.content?.parts || [];\nconst imagePart = parts.find(p => p.inlineData || p.inline_data);\nconst inlineData = imagePart?.inlineData || imagePart?.inline_data;\n\nif (!inlineData?.data) {\n  return [{ json: { success: false, variant: 'v2', error: 'No image data', finish_reason: cand.finishReason || null, text_parts: parts.filter(p => p.text).map(p => p.text), raw: res } }];\n}\n\nconst base64Data = inlineData.data;\nconst mimeType = inlineData.mimeType || inlineData.mime_type || 'image/png';\nconst ext = mimeType.split('/')[1]?.split('+')[0] || 'png';\nconst fileName = `gemini_v2_${Date.now()}.${ext}`;\n\nreturn [{\n  json: { success: true, variant: 'v2', mime_type: mimeType, file_name: fileName, size_kb: Math.round(base64Data.length * 0.75 / 1024), finish_reason: cand.finishReason || 'STOP' },\n  binary: { data: { data: base64Data, mimeType, fileName } }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4672,
        10288
      ],
      "id": "d4ea1ee5-21f1-4d7e-837f-be1e30bf8024",
      "name": "Extract Image v7"
    },
    {
      "parameters": {
        "operation": "sendPhoto",
        "chatId": "6587544701",
        "binaryData": true,
        "additionalFields": {
          "caption": "=Ver 1 — {{ $('Build Final Context5').first().json._sheet_row['Brand'] || '' }} / ID {{ $('Build Final Context5').first().json._sheet_row['ID'] || '' }}"
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        4912,
        10096
      ],
      "id": "b7b9250f-a0c5-47a0-b0f8-e78faebd93ca",
      "name": "Send Photo Gemini 8",
      "webhookId": "841aa126-85c7-47eb-ac9d-2178667c1222",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "operation": "sendPhoto",
        "chatId": "6587544701",
        "binaryData": true,
        "additionalFields": {
          "caption": "=Ver 2 — {{ $('Build Final Context5').first().json._sheet_row['Brand'] || '' }} / ID {{ $('Build Final Context5').first().json._sheet_row['ID'] || '' }}"
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        4912,
        10288
      ],
      "id": "4c277346-0de8-4d74-ab8b-c64a95fd316a",
      "name": "Send Photo Gemini 9",
      "webhookId": "2f7aa04f-28f8-4fa8-9fa1-4dcb8d3eae48",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {},
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        5152,
        10192
      ],
      "id": "74fc2571-d8bc-49e8-a134-d724cf3b51fb",
      "name": "Merge16"
    },
    {
      "parameters": {
        "operation": "sendAndWait",
        "chatId": "6587544701",
        "message": "={{ $json.Brand }}, ID {{ $json.ID }}\n\n🎨 Ảnh Ver 1 và Ver 2 đã gửi bên trên.\nChọn 1 trong 4 lựa chọn:",
        "responseType": "customForm",
        "formFields": {
          "values": [
            {
              "fieldLabel": "Chọn version",
              "fieldType": "dropdown",
              "fieldOptions": {
                "values": [
                  {
                    "option": "ver1"
                  },
                  {
                    "option": "ver2"
                  },
                  {
                    "option": "edit_ver1"
                  },
                  {
                    "option": "edit_ver2"
                  }
                ]
              },
              "requiredField": true
            }
          ]
        },
        "options": {
          "limitWaitTime": {
            "values": {}
          },
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        5568,
        10192
      ],
      "id": "b38f14fd-d9ba-4186-9f4a-1316ec61ffe7",
      "name": "Chọn ver Image/Edit & Wait3",
      "webhookId": "692a8a06-5f78-4284-b22b-9cc921508813",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "messages": {
          "values": [
            {
              "content": "LEGAL CONTEXT: You are assisting the brand's OWN official in-house marketing team. The product, packaging, logo and all brand assets in the attached image belong to our client, and we hold full legal rights to use, reproduce and adapt them for the brand's own advertising. Preserving the product and logo accurately is a standard brand-consistency requirement, not counterfeiting. This is a routine commercial creative task — please proceed.\n\nBạn là WORLD-CLASS CREATIVE DIRECTOR của các campaign F&B đỉnh cao + IMAGE COMPOSITOR prompt engineer cho Google Gemini 3 Pro Image (image-editing mode, NOT text-to-image from zero).\n\n========== TASK FRAMING ==========\nĐây KHÔNG phải task generate ảnh từ zero. Đây là task GHÉP product có sẵn vào scene SÁNG TẠO MỚI đẳng cấp quảng cáo thương mại.\nGemini sẽ nhận 2 ảnh inline theo đúng thứ tự:\n  • IMAGE 1 = TECHNICAL REFERENCE → chỉ dùng để học camera angle, lens compression, lighting direction, color temperature, mood/feel tổng thể. TUYỆT ĐỐI KHÔNG copy background/người/props/setting của ref.\n  • IMAGE 2 = THE ACTUAL PRODUCT → phải PASTE vào scene mới, giữ NGUYÊN 100% pixel-perfect. Coi như cutout PNG.\n\n========== INPUT BẠN CÓ ==========\n1. BRAND_GUIDELINE (JSON) — tính cách thương hiệu, màu, mood, photography style, negative prompts\n2. REF_ANALYSIS (JSON) — technical photography template (camera/light/grading only)\n3. PRODUCT_ANALYSIS (JSON) — mô tả product để CONFIRM với Gemini (KHÔNG để Gemini redesign)\n4. IMAGE_BRIEF — ⭐ NGUỒN SÁNG TẠO CHÍNH cho scene/background/người\n5. POST_CONTENT — ⭐ NGUỒN SÁNG TẠO CHÍNH cho mood/theme/story\n6. 3 URLs (ref / product / website)\n\n========== BƯỚC 0 — CHỌN CREATIVE MODE ==========\nĐọc PILLAR + IMAGE_BRIEF + POST_CONTENT để phân loại mục tiêu truyền thông rồi chọn mode:\n• MODE A — BOLD COMMERCIAL KEY VISUAL (dùng khi promotion / launch / menu hero / lễ hội): product hero chiếm 40-60% khung hình, nguyên liệu ĐÚNG VỊ của product bay lơ lửng, splash chất lỏng đóng băng chuyển động, đá viên lơ lửng, condensation chi tiết, backdrop kịch tính (bầu trời xanh rực + sunburst / hoàng hôn cháy / landscape siêu thực), bố cục trung tâm hoặc đường chéo mạnh, độ chi tiết CGI-grade như poster campaign Pepsi/Starbucks.\n• MODE B — CINEMATIC LIFESTYLE (dùng khi storytelling / community / văn hóa / cảm xúc): môi trường thật có hơi ấm con người và câu chuyện (đường phố, cafe, chợ, biển...), chiều sâu phân lớp foreground-midground-background, golden hour hoặc ánh sáng moody, film stock cụ thể, năng lượng editorial tự nhiên.\nNêu rõ mode đã chọn trong scene_creative_ideas.\n\n========== QUY TẮC TUYỆT ĐỐI ==========\n\n[A] PRODUCT LOCK (priority #1 — vi phạm = fail):\n- Treat IMAGE 2 as a fixed visual asset. PASTE it in. DO NOT redraw, restyle, recolor, retouch, smooth, beautify, reinterpret, or 'improve' bất kỳ chi tiết nào.\n- Preserve pixel-perfect: container shape, transparency, ALL printed label text, logo placement & color, drink color layers, foam, toppings, garnish, ice density, condensation, opacity, proportions.\n- KHÔNG được phép phóng đại / minh hoạ / cách điệu hoá product (scale to khung hình được, nhưng product giữ nguyên hình dạng).\n- Nếu scene có tay người cầm product → tay KHÔNG được che logo chính.\n\n[B] TECHNICAL REFERENCE (priority #2 — chỉ mượn KỸ THUẬT từ IMAGE 1):\n- Từ IMAGE 1 CHỈ mượn: camera angle, framing tightness, focal length feel, lens compression, lighting direction, shadow softness, color temperature, mood/vibe.\n- TUYỆT ĐỐI KHÔNG copy: background, environment, người mẫu, outfit, gesture, props, setting, layout của ref.\n\n[C] CREATIVE SCENE (priority #3 — SCENE PHẢI MỚI HOÀN TOÀN VÀ ĐẲNG CẤP):\n- Background, environment, props, model, gesture, pose, outfit, setting phải được SÁNG TẠO MỚI dựa CHỦ YẾU vào IMAGE_BRIEF + POST_CONTENT, theo MODE đã chọn ở Bước 0.\n- BẮT BUỘC mô tả trong prompt: (1) COMPOSITION GEOMETRY — product nằm đâu trong khung, scale bao nhiêu %, các lớp foreground/midground/background, leading lines; (2) NEGATIVE SPACE — chừa MỘT vùng sạch (1/3 trên hoặc một bên) nền đơn giản để designer thêm typography SAU, ảnh tự thân không có chữ; (3) ATMOSPHERE FX vật lý thật và đúng vị product: splash arcs, droplets, condensation, steam, garnish bay, ice shatter; (4) COLOR STORY neo vào brand palette + dominant colors HEX của product; (5) LIGHTING SETUP đầy đủ: key direction & quality, rim, fill, practicals, haze/god rays.\n- ELEVATE: cinematic depth-of-field, atmospheric layers, premium production value — ảnh phải ấn tượng hơn hẳn ref.\n\n[D] NO TEXT (strict):\n- Zero captions, headlines, typography, watermark, sticker text, hashtags, graphic overlay, số, chữ cái. Text DUY NHẤT được phép tồn tại là nhãn/logo có sẵn in trên product (giữ giống IMAGE 2). Vùng negative space để TRỐNG.\n\n[E] OUTPUT REALISM:\n- Photograph realism, not illustration. Real materials, real light physics, real shadow falloff. MODE A được phép kịch tính hoá scale/motion nhưng material và ánh sáng vẫn phải photoreal.\n\n========== OUTPUT SCHEMA (JSON thuần, KHÔNG markdown) ==========\n{\n  \"prompt\": \"<English 350-500 từ cinematic, phải mở đầu CHÍNH XÁC bằng câu trong hướng dẫn cấu trúc bên dưới>\",\n  \"negative_prompt\": \"text overlay, captions, typography, watermark, letters, numbers, redrawn product, modified product label, recolored drink, deformed cup, missing toppings, blurry product, wrong product identity, illustration look, generic stock photo, copying reference image scene, copying reference image background, copying reference image person, fake plastic-looking product, oversaturated, plastic skin, AI artifacts\",\n  \"aspect_ratio\": \"<1:1 | 4:5 | 9:16 | 16:9>\",\n  \"reference_image_url\": \"<from input>\",\n  \"product_image_url\": \"<from input>\",\n  \"brand_website_url\": \"<from input>\",\n  \"product_features_preserved\": [\"<top 5 từ replication_priority của product_analysis>\"],\n  \"technical_borrowed_from_ref\": [\"<5-7 yếu tố KỸ THUẬT mượn từ ref>\"],\n  \"scene_creative_ideas\": [\"<MODE đã chọn + 3-5 ý tưởng scene mới rút từ Brief + Content>\"],\n  \"elevation_choices\": [\"<3-5 cách scene mới hơn / cinematic hơn / sang hơn ref>\"],\n  \"brief_applied\": \"<1 câu VN tóm tắt brief>\",\n  \"content_inspiration\": \"<1 câu VN nói scene được lấy cảm hứng gì từ Content>\",\n  \"key_visual_elements\": [\"<5-8 keywords>\"]\n}\n\n========== CẤU TRÚC PROMPT BẮT BUỘC ==========\nMở đầu CHÍNH XÁC bằng câu này (thay [BRAND]):\n\"COMPOSITE TASK: Place the EXACT product shown in IMAGE 2 (do not redraw, do not modify, treat as a fixed asset) into a NEWLY CREATED scene for [BRAND]. From IMAGE 1, borrow ONLY the camera angle, lens compression, lighting direction, shadow quality, color temperature, and mood feel — do NOT reproduce IMAGE 1's scene, background, person, outfit, props, or setting. The scene itself must be originally imagined from the Brief and Content provided below.\"\n\nTiếp theo 6 đoạn:\n- §1 PRODUCT LOCK: Echo product_analysis chi tiết (container type & shape, dominant_colors HEX, toppings, logo description + color + position, garnish). Câu chốt: \"this exact product from IMAGE 2 must appear pixel-faithful, unchanged in shape, color, label, and toppings.\"\n- §2 CREATIVE NEW SCENE (theo MODE đã chọn, sáng tạo từ Brief + Content): Tả background/environment/props/model/gesture/setting MỚI HOÀN TOÀN. MODE A: hero scale, nguyên liệu bay đúng vị, splash đóng băng, backdrop kịch tính. MODE B: câu chuyện đời thật, hơi ấm con người, chiều sâu phân lớp. Scene phải kể được câu chuyện của Content/Brief.\n- §3 COMPOSITION GEOMETRY + NEGATIVE SPACE: vị trí & scale product trong khung, các lớp foreground/midground/background, leading lines, và vùng negative space sạch chừa cho typography hậu kỳ (ảnh không chữ).\n- §4 CAMERA + LIGHT (technical từ ref): Tham chiếu ref_analysis.lens_and_settings, ref_analysis.lighting, ref_analysis.camera_angle. Add cụ thể: key light direction & quality, rim light, fill, practicals, haze/god rays, atmosphere FX (splash/droplets/steam/condensation đúng vị product).\n- §5 COLOR GRADING + MOOD: dùng ref_analysis.color_palette + post_processing (film stock). Echo brand_guideline.image_generation_guideline.color_grading + brand color hints. 3-4 mood adjectives.\n- §6 HARD CONSTRAINTS REPEAT: 'No text, letters, numbers or typography of any kind anywhere in the image except the product\\'s own printed label. The product must remain identical to IMAGE 2. The scene must be newly created from the Brief and Content — do not reproduce IMAGE 1\\'s background, person, or setting.'"
            },
            {
              "content": "=BRAND: {{ $json.brand_name }}\nPILLAR: {{ $json.pillar }}\nTOPIC: {{ $json.topic }}\nPLATFORM: {{ $json.platform }}\nASPECT RATIO: {{ $json.suggested_aspect_ratio }}\nTARGET AUDIENCE: {{ $json.target_audience_brief }}\n\n========== ⭐ IMAGE_BRIEF (team request) ==========\n{{ $json.image_brief || '(none)' }}\n\n========== ⭐ POST_CONTENT ==========\n{{ $json.post_content || '(none)' }}\n\n========== 🎨 BRAND_GUIDELINE ==========\n{{ JSON.stringify($json.brand_guideline, null, 2) }}\n\n========== 📸 REF_ANALYSIS (style only — NOT subject) ==========\n{{ JSON.stringify($json.ref_analysis, null, 2) }}\n\nRef snippet: {{ $json.ref_style_snippet }}\n\n========== 🥤 PRODUCT_ANALYSIS (must be preserved pixel-perfect) ==========\n{{ JSON.stringify($json.product_analysis, null, 2) }}\n\nProduct snippet:\n{{ $json.product_snippet }}\n\n========== 🔗 URLs ==========\n- reference_image_url: {{ $json.ref_image_url }}\n- product_image_url: {{ $json.product_image_url }}\n- brand_website_url: {{ $json.brand_website_url }}\n\n========== VALIDATION ==========\n{{ JSON.stringify($json._validation) }}\n\nGenerate MASTER COMPOSITOR PROMPT theo schema bắt buộc."
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.4
        }
      },
      "id": "c19f9622-a7b4-42ef-8e0b-079954ae9d34",
      "name": "Generate Final Prompt6",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        3152,
        10192
      ],
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst llmContent = input.message?.content ?? input.content ?? input;\nlet spec;\nif (typeof llmContent === 'string') {\n  try {\n    spec = JSON.parse(\n      String(llmContent)\n        .replace(/^```json\\s*/i, '')\n        .replace(/```\\s*$/i, '')\n        .trim()\n    );\n  } catch (e) {\n    spec = { prompt: String(llmContent), _parse_error: e.message };\n  }\n} else {\n  spec = llmContent || {};\n}\n\n// FIX QUAN TRỌNG: tên node context đúng là 'Build Final Context5' (trước đây ghi nhầm '...4' nên ctx luôn RỖNG\n// → Gemini không nhận được brand_guideline / ref_analysis / product_analysis)\nconst CTX_NODE_NAME = 'Build Final Context5';\n\nlet ctx = {};\ntry {\n  ctx = $(CTX_NODE_NAME).first().json || {};\n} catch (e) {\n  ctx = {};\n}\n\nconst sheet = ctx._sheet_row || ctx || {};\nconst updatePrompt = sheet['Prompt Update'] || 'Không có';\n\nconst isHttp = (s) => typeof s === 'string' && /^https?:\\/\\//i.test(s.trim());\n\nconst findImageByRole = (role) =>\n  (spec.input_images || []).find((i) => i.role === role)?.url || '';\n\nconst firstHttp = (cands) => {\n  for (const [k, v] of Object.entries(cands)) {\n    const val = String(v || '').trim();\n    if (isHttp(val)) return { url: val, source: k };\n  }\n  return { url: '', source: 'none' };\n};\n\nconst pickFromSheet = (...keys) => {\n  for (const k of keys) {\n    const v = sheet?.[k];\n    if (v != null && String(v).trim() !== '') return String(v).trim();\n  }\n  return '';\n};\n\nconst refCandidates = {\n  'ctx.ref_image_url':               ctx.ref_image_url || '',\n  'spec.input_images[ref_role]':     findImageByRole('reference_style_composition'),\n  'spec.reference_image_url':        spec.reference_image_url || '',\n  'sheet[Link Ref Image 1]':         sheet['Link Ref Image 1'] || '',\n  'sheet[Link Ref Image 2]':         sheet['Link Ref Image 2'] || '',\n  'sheet[Link Ref Image (origin)]':  sheet['Link Ref Image (origin)'] || ''\n};\n\nconst productCandidates = {\n  'ctx.product_image_url':        ctx.product_image_url || '',\n  'spec.input_images[prod_role]': findImageByRole('product_to_feature'),\n  'spec.product_image_url':       spec.product_image_url || '',\n  'sheet[Product Generate]':      sheet['Product Generate'] || ''\n};\n\nlet { url: refImageUrl,     source: refSource }     = firstHttp(refCandidates);\nlet { url: productImageUrl, source: productSource } = firstHttp(productCandidates);\n\nconst PLACEHOLDER_URL = 'https://placehold.co/1024x1024.png';\nlet skipGeneration = false;\n\nif (!refImageUrl && productImageUrl) {\n  refImageUrl = productImageUrl;\n  refSource =
... [da cat bot]

---

## Claude

Tôi đã rà toàn bộ JSON. Kết luận: **9 node giữ nguyên, 5 chỗ cần update**, và có **1 bug đang hiện rõ ngay trên Telegram của bạn** (caption "Ver 1 — / ID" bị trống Brand và ID) cần kiểm tra dữ liệu.

## Tổng quan: giữ gì, sửa gì

| Node | Kết luận |
|---|---|
| Loop Over Items7 | ✅ Giữ nguyên |
| DL Product Image4, Prepare Gemini Images2 | ✅ Giữ nguyên |
| Call Gemini v6/v7, Extract Image v3/v7 | ✅ Giữ nguyên |
| Send Photo Gemini 8/9, Merge16, Chọn ver & Wait3 | ✅ Giữ nguyên |
| **Build Final Context5** | 🔧 Update — code mới có RETRY MODE (quan trọng nhất) |
| **Persist Context** | 🔧 Update — sửa nguồn retry_count + lưu thêm 2 URL ảnh |
| **Prep Gemini Input7** | 🔧 Update — 2 dòng (sửa nguồn Prompt Update + retry_count) |
| **Generate Final Prompt6** | 🔧 Update — thêm EDIT MODE vào 2 message |
| **DL Ref Image4** | 🔧 Update — đổi URL expression (sẽ gãy ở vòng retry nếu giữ nguyên) |

---

## UPDATE 1 — Build Final Context5 (thay toàn bộ code)

Code hiện tại chưa có retry mode. Khi Edit Fields9 đổ vào với chỉ `{ID, Prompt Update, retry_count}`, context sẽ rỗng hết → Gemini mất brand_guideline/ref/product. Code mới tự khôi phục context gốc từ Loop Over Items7 + Persist Context:

```javascript
const input = $input.first().json;

// ===== RETRY MODE: Edit Fields9 đổ vào đây với { ID, Prompt Update, retry_count } =====
const promptUpdate = input['Prompt Update'] || input.prompt_update || '';
const isRetry = promptUpdate !== '';

// loại bỏ giá trị null/rỗng để không đè mất dữ liệu gốc
const clean = (o) => Object.fromEntries(
  Object.entries(o || {}).filter(([, v]) => v !== null && v !== undefined && v !== '')
);

let item = input;
if (isRetry) {
  let base = {};
  try { base = $('Loop Over Items7').first().json || {}; } catch (e) {}
  let persisted = {};
  try { persisted = Object.assign({}, ...$('Persist Context').all().map(i => i.json)); } catch (e) {}
  item = { ...base, ...clean(persisted), ...clean(input) };
}

let brandGuideline = item.brand_guideline;
if ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {
  try {
    let raw = String(item.content || item.message?.content)
      .replace(/^```json\s*/i, '').replace(/```\s*$/i, '').trim();
    brandGuideline = JSON.parse(raw);
  } catch (e) { brandGuideline = brandGuideline || {}; }
}

const sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;

const platform = String(sheet['Nền tảng'] || '').toLowerCase();
let defaultAR = '1:1';
if (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';
else if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';
else if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';

return [{
  json: {
    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',
    pillar:                sheet['Pillar'] || '',
    topic:                 sheet['Topic'] || '',
    funnel:                sheet['Funnel'] || '',
    target_audience_brief: sheet['Target Audience'] || '',
    platform:              sheet['Nền tảng'] || '',
    suggested_aspect_ratio: defaultAR,

    image_brief:           sheet['Brief Images'] || '',
    post_content:          sheet['Content'] || '',

    prompt_update:         promptUpdate,
    is_retry:              isRetry,
    retry_count:           Number(input.retry_count || item.retry_count || 0),

    brand_guideline:       brandGuideline || {},
    ref_analysis:          item.ref_analysis || {},
    product_analysis:      item.product_analysis || {},

    ref_style_snippet:     item.ref_style_snippet || '',
    product_snippet:       item.product_snippet || '',

    brand_website_url:     sheet['Link Website'] || '',
    ref_image_url:         item.pin?.ref_image_url || item.ref_image_url || '',
    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',
    product_image_url:     item.product_image_url || '',
    product_drive_url:     sheet['Product Generate'] || '',

    _validation: {
      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,
      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,
      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,
      has_product_img:    !!item.product_image_url,
      has_ref_img:        !!(item.pin?.ref_image_url || item.ref_image_url),
      has_image_brief:    !!sheet['Brief Images'],
      has_prompt_update:  isRetry,
      has_post_content:   !!sheet['Content']
    },

    _sheet_row: sheet
  }
}];
```

## UPDATE 2 — Persist Context (sửa 1 field + thêm 2 field)

**Sửa** `p1-retry`: nguồn hiện tại (`Prep Gemini Input7`) chỉ trả 0/1 cứng nên retry_count không bao giờ cộng dồn. Đổi value thành:

```
={{ $('Build Final Context5').first().json.retry_count || 0 }}
```

**Thêm 2 assignments mới** — bắt buộc, vì ở vòng retry các node download ảnh cần lại 2 URL này (chúng vốn nằm trong item của loop, Edit Fields9 không mang theo):

```json
{
  "id": "p1-refimg",
  "name": "ref_image_url",
  "value": "={{ $('Prep Gemini Input7').first().json.reference_image_url }}",
  "type": "string"
},
{
  "id": "p1-prodimg",
  "name": "product_image_url",
  "value": "={{ $('Prep Gemini Input7').first().json.product_image_url }}",
  "type": "string"
}
```

## UPDATE 3 — Prep Gemini Input7 (sửa 2 dòng trong code)

Dòng `const updatePrompt = sheet['Prompt Update'] || 'Không có';` có bug ngầm: cột "Prompt Update" trên Sheet **tồn tại vĩnh viễn** sau lần sửa đầu, nên những lần generate sau (kể cả row mới chạy lần đầu) sẽ bị inject nhầm revision note cũ. Đổi thành đọc từ context (chỉ có giá trị khi đúng là vòng retry):

```javascript
const updatePrompt = ctx.prompt_update || 'Không có';
```

Và dòng retry_count trong return đổi thành:

```javascript
'retry_count': ctx.retry_count || 0,
```

Phần `[REVISION NOTE FROM HUMAN]` đã có sẵn trong code này — giữ nguyên, nó sẽ tự hoạt động.

## UPDATE 4 — Generate Final Prompt6 (thêm 2 đoạn text)

**Cuối system prompt** (message 1), thêm:

```
========== ✏️ EDIT MODE (khi USER EDIT REQUEST ≠ none) ==========
Nếu input có USER EDIT REQUEST: đây là vòng SỬA ảnh đã duyệt, KHÔNG phải sáng tạo lại từ đầu.
- GIỮ NGUYÊN concept tổng thể, bố cục, scene, mode (A/B), lighting như đã làm từ IMAGE_BRIEF + POST_CONTENT.
- CHỈ thay đổi đúng những điểm user yêu cầu trong EDIT REQUEST, không thêm ý tưởng mới ngoài yêu cầu.
- Nếu EDIT REQUEST mâu thuẫn với IMAGE_BRIEF → EDIT REQUEST thắng.
- Vẫn tuân thủ tuyệt đối PRODUCT LOCK, NO TEXT, OUTPUT REALISM.
```

**Trong user message** (message 2), ngay dưới dòng `TARGET AUDIENCE: ...`, thêm:

```
========== ✏️ USER EDIT REQUEST (vòng sửa — ưu tiên cao nhất) ==========
{{ $json.prompt_update || '(none — first generation)' }}
RETRY COUNT: {{ $json.retry_count || 0 }}
```

## UPDATE 5 — DL Ref Image4 (đổi URL expression)

URL hiện tại trỏ tới `$('Parse Pinterest Data (Update)3').item...` — kiểu tham chiếu `.item` này dựa vào item-linking, **sẽ gãy hoặc lấy sai item ở vòng retry** (vì đường chạy retry không đi qua node đó). Trong khi `Prep Gemini Input7` (node ngay trước) đã resolve sẵn URL với đầy đủ fallback. Đổi URL thành:

```
={{ $json.reference_image_url }}
```

`DL Product Image4` đã dùng `{{ $json.product_image_url }}` đúng kiểu này rồi — giữ nguyên.

## Connections cần bổ sung (nằm ngoài JSON này, kiểm tra lại)

- `Edit Fields9` → `Build Final Context5` (nhánh sửa, bỏ qua loop node)
- Nhánh approve (ver1/ver2 sau Switch10, sau khi lưu kết quả) → quay về input `Loop Over Items7`
- `Loop Over Items7` output **done** → node Telegram báo hoàn tất (hoặc để trống) — **không** nối vào Build Final Context5

## ⚠️ Bug cần bạn tự kiểm tra: ID và Brand đang RỖNG

Nhìn lại screenshot Telegram bạn gửi trước: caption hiện *"Ver 1 — / ID"* — tức `_sheet_row['Brand']` và `_sheet_row['ID']` đều rỗng ngay từ vòng đầu. Hệ quả dây chuyền: Persist Context lưu ID null → Update row in sheet5 match theo ID sẽ ghi sai dòng hoặc append dòng rác. Cách check: chạy flow, mở output của **Build Final Context5**, xem trong `_sheet_row` key thật sự tên là gì (có thể là `Id`, ` ID ` có khoảng trắng, hay nằm trong `item.sheet`). Sau đó sửa đúng tên key trong Persist Context và caption của 2 node Send Photo. Nếu bạn dán cho tôi output JSON của Build Final Context5 (tab JSON), tôi chỉ ra chính xác chỗ sửa ngay.

---

## Nguoi dung

M viết thành file Json hết cho t đi. Json của từng node, t đấu vô thôi là đc

---

## Claude

OK, đây là file JSON hoàn chỉnh gồm **17 nodes** (16 node cũ + Edit Fields9 đã sửa luôn lỗi ID null) với tất cả 5 update đã áp sẵn. Bạn copy nguyên khối, làm theo 3 bước:

1. **Xóa các node cũ trùng tên** trên canvas trước (nếu không n8n sẽ tự đổi tên bản paste thành `...1` và làm gãy hết các expression `$('Build Final Context5')`).
2. Paste JSON vào canvas (Ctrl/Cmd+V).
3. **Nối lại 4 dây biên** (nằm ngoài bộ này): node nguồn items → `Loop Over Items7` • `Chọn ver Image/Edit & Wait3` → `Switch10` • `Update row in sheet5` → `Edit Fields9` • (tuỳ chọn) output **done** của `Loop Over Items7` → node Telegram báo hoàn tất.

```json
{
  "nodes": [
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "p1-id",
              "name": "ID",
              "value": "={{ $('Build Final Context5').first().json._sheet_row['ID'] }}",
              "type": "string"
            },
            {
              "id": "p1-brand",
              "name": "Brand",
              "value": "={{ $('Build Final Context5').first().json._sheet_row['Brand'] || $('Build Final Context5').first().json.brand_name }}",
              "type": "string"
            },
            {
              "id": "p1-content",
              "name": "post_content",
              "value": "={{ $('Build Final Context5').first().json.post_content }}",
              "type": "string"
            },
            {
              "id": "p1-brief",
              "name": "image_brief",
              "value": "={{ $('Build Final Context5').first().json.image_brief }}",
              "type": "string"
            },
            {
              "id": "p1-topic",
              "name": "topic",
              "value": "={{ $('Build Final Context5').first().json.topic }}",
              "type": "string"
            },
            {
              "id": "p1-pillar",
              "name": "pillar",
              "value": "={{ $('Build Final Context5').first().json.pillar }}",
              "type": "string"
            },
            {
              "id": "p1-retry",
              "name": "retry_count",
              "value": "={{ $('Build Final Context5').first().json.retry_count || 0 }}",
              "type": "number"
            },
            {
              "id": "p1-refimg",
              "name": "ref_image_url",
              "value": "={{ $('Prep Gemini Input7').first().json.reference_image_url }}",
              "type": "string"
            },
            {
              "id": "p1-prodimg",
              "name": "product_image_url",
              "value": "={{ $('Prep Gemini Input7').first().json.product_image_url }}",
              "type": "string"
            }
          ]
        },
        "options": {}
      },
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [
        5344,
        10192
      ],
      "id": "884a0cdf-7cd0-4fa8-ba3d-68b6f44688fd",
      "name": "Persist Context"
    },
    {
      "parameters": {
        "options": {}
      },
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [
        2736,
        10176
      ],
      "id": "fa18cb16-4bb7-41df-b5a0-f19d1628a0d1",
      "name": "Loop Over Items7"
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\n// ===== RETRY MODE: Edit Fields9 đổ vào đây với { ID, Prompt Update, retry_count } =====\nconst promptUpdate = input['Prompt Update'] || input.prompt_update || '';\nconst isRetry = promptUpdate !== '';\n\n// loại bỏ giá trị null/rỗng để không đè mất dữ liệu gốc khi merge\nconst clean = (o) => Object.fromEntries(\n  Object.entries(o || {}).filter(([, v]) => v !== null && v !== undefined && v !== '')\n);\n\nlet item = input;\nif (isRetry) {\n  let base = {};\n  try { base = $('Loop Over Items7').first().json || {}; } catch (e) {}\n  let persisted = {};\n  try { persisted = Object.assign({}, ...$('Persist Context').all().map(i => i.json)); } catch (e) {}\n  item = { ...base, ...clean(persisted), ...clean(input) };\n}\n\nlet brandGuideline = item.brand_guideline;\nif ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {\n  try {\n    let raw = String(item.content || item.message?.content)\n      .replace(/^```json\\s*/i, '').replace(/```\\s*$/i, '').trim();\n    brandGuideline = JSON.parse(raw);\n  } catch (e) { brandGuideline = brandGuideline || {}; }\n}\n\nconst sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;\n\nconst platform = String(sheet['Nền tảng'] || '').toLowerCase();\nlet defaultAR = '1:1';\nif (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';\nelse if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';\nelse if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';\n\nreturn [{\n  json: {\n    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',\n    pillar:                sheet['Pillar'] || '',\n    topic:                 sheet['Topic'] || '',\n    funnel:                sheet['Funnel'] || '',\n    target_audience_brief: sheet['Target Audience'] || '',\n    platform:              sheet['Nền tảng'] || '',\n    suggested_aspect_ratio: defaultAR,\n\n    image_brief:           sheet['Brief Images'] || '',\n    post_content:          sheet['Content'] || '',\n\n    prompt_update:         promptUpdate,\n    is_retry:              isRetry,\n    retry_count:           Number(input.retry_count || item.retry_count || 0),\n\n    brand_guideline:       brandGuideline || {},\n    ref_analysis:          item.ref_analysis || {},\n    product_analysis:      item.product_analysis || {},\n\n    ref_style_snippet:     item.ref_style_snippet || '',\n    product_snippet:       item.product_snippet || '',\n\n    brand_website_url:     sheet['Link Website'] || '',\n    ref_image_url:         item.pin?.ref_image_url || item.ref_image_url || '',\n    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',\n    product_image_url:     item.product_image_url || '',\n    product_drive_url:     sheet['Product Generate'] || '',\n\n    _validation: {\n      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,\n      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,\n      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,\n      has_product_img:    !!item.product_image_url,\n      has_ref_img:        !!(item.pin?.ref_image_url || item.ref_image_url),\n      has_image_brief:    !!sheet['Brief Images'],\n      has_prompt_update:  isRetry,\n      has_post_content:   !!sheet['Content']\n    },\n\n    _sheet_row: sheet\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2960,
        10192
      ],
      "id": "81cb49ae-22bf-4887-b4d6-a5949268a19c",
      "name": "Build Final Context5"
    },
    {
      "parameters": {
        "url": "={{ $json.reference_image_url }}",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file",
              "outputPropertyName": "ref_image"
            }
          },
          "timeout": 30000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        3760,
        10192
      ],
      "id": "5e562050-7e79-44ed-a21d-7c44858cca6c",
      "name": "DL Ref Image4",
      "alwaysOutputData": true,
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "continueOnFail": true
    },
    {
      "parameters": {
        "url": "={{ $json.product_image_url }}",
        "options": {
          "response": {
            "response": {
              "responseFormat": "file",
              "outputPropertyName": "product_image"
            }
          },
          "timeout": 30000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        3952,
        10192
      ],
      "id": "b03af783-dae0-48de-a1db-ba29a4daba93",
      "name": "DL Product Image4",
      "alwaysOutputData": true,
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "continueOnFail": true
    },
    {
      "parameters": {
        "jsCode": "const item = $input.first();\n\nif (!item.binary?.ref_image) {\n  throw new Error(\"Missing binary ref_image\");\n}\n\nif (!item.binary?.product_image) {\n  throw new Error(\"Missing binary product_image\");\n}\n\nconst refBuffer = await this.helpers.getBinaryDataBuffer(0, \"ref_image\");\nconst productBuffer = await this.helpers.getBinaryDataBuffer(0, \"product_image\");\n\nconst basePrompt    = item.json.full_prompt_text    || item.json.prompt || \"\";\nconst variantPrompt = item.json.full_prompt_variant || basePrompt;\n\nconst refMime     = item.binary.ref_image.mimeType     || \"image/jpeg\";\nconst productMime = item.binary.product_image.mimeType || \"image/png\";\n\nconst refB64     = refBuffer.toString(\"base64\");\nconst productB64 = productBuffer.toString(\"base64\");\n\nconst buildBody = (promptText) => ({\n  contents: [\n    {\n      role: \"user\",\n      parts: [\n        { text: promptText },\n        { inline_data: { mime_type: refMime,     data: refB64 } },\n        { inline_data: { mime_type: productMime, data: productB64 } }\n      ]\n    }\n  ],\n  generationConfig: {\n    candidateCount: 1,\n    responseModalities: [\"TEXT\", \"IMAGE\"]\n  }\n});\n\nreturn [\n  {\n    json: {\n      full_prompt_text:    basePrompt,\n      full_prompt_variant: variantPrompt,\n      ref_mime:            refMime,\n      product_mime:        productMime,\n      gemini_body:         buildBody(basePrompt),\n      gemini_body_variant: buildBody(variantPrompt)\n    }\n  }\n];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4160,
        10192
      ],
      "id": "8511aaf3-a963-4a4c-b3ba-c96c49b262e8",
      "name": "Prepare Gemini Images2"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ $json.gemini_body }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        4448,
        10096
      ],
      "id": "916d35e7-7fb2-4cce-b9c5-1bfa2a83b2da",
      "name": "Call Gemini v6",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ $json.gemini_body_variant }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        4448,
        10288
      ],
      "id": "9253a6f0-6266-4ea4-80dd-8499f04bbf5f",
      "name": "Call Gemini v7",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const res = $input.first().json;\n\nif (res.error) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: res.error.message || JSON.stringify(res.error),\n    raw: res\n  } }];\n}\n\nconst candidates = res.candidates || [];\nif (candidates.length === 0) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: 'No candidates',\n    block_reason: res.promptFeedback?.blockReason || null,\n    safety_ratings: res.promptFeedback?.safetyRatings || null,\n    raw: res\n  } }];\n}\n\nconst cand = candidates[0];\nconst parts = cand.content?.parts || [];\n\nconst imagePart  = parts.find(p => p.inlineData || p.inline_data);\nconst inlineData = imagePart?.inlineData || imagePart?.inline_data;\n\nif (!inlineData?.data) {\n  return [{ json: {\n    success: false,\n    variant: 'v1',\n    error: 'No image in response',\n    finish_reason: cand.finishReason || null,\n    text_parts: parts.filter(p => p.text).map(p => p.text),\n    raw: res\n  } }];\n}\n\nconst base64Data = inlineData.data;\nconst mimeType   = inlineData.mimeType || inlineData.mime_type || 'image/png';\nconst ext        = mimeType.split('/')[1]?.split('+')[0] || 'png';\nconst fileName   = `gemini_v1_${Date.now()}.${ext}`;\nconst sizeKB     = Math.round(base64Data.length * 0.75 / 1024);\n\nreturn [{\n  json: {\n    success: true,\n    variant: 'v1',\n    mime_type:     mimeType,\n    file_name:     fileName,\n    size_kb:       sizeKB,\n    finish_reason: cand.finishReason || 'STOP'\n  },\n  binary: {\n    data: {\n      data: base64Data,\n      mimeType,\n      fileName\n    }\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4672,
        10096
      ],
      "id": "01817e44-58e2-4e40-b333-585c539bf9de",
      "name": "Extract Image v3"
    },
    {
      "parameters": {
        "jsCode": "const res = $input.first().json;\n\nif (res.error) {\n  return [{ json: { success: false, variant: 'v2', error: res.error.message || JSON.stringify(res.error), raw: res } }];\n}\n\nconst candidates = res.candidates || [];\nif (candidates.length === 0) {\n  return [{ json: { success: false, variant: 'v2', error: 'No candidates', finish_reason: res.promptFeedback?.blockReason || null, raw: res } }];\n}\n\nconst cand = candidates[0];\nconst parts = cand.content?.parts || [];\nconst imagePart = parts.find(p => p.inlineData || p.inline_data);\nconst inlineData = imagePart?.inlineData || imagePart?.inline_data;\n\nif (!inlineData?.data) {\n  return [{ json: { success: false, variant: 'v2', error: 'No image data', finish_reason: cand.finishReason || null, text_parts: parts.filter(p => p.text).map(p => p.text), raw: res } }];\n}\n\nconst base64Data = inlineData.data;\nconst mimeType = inlineData.mimeType || inlineData.mime_type || 'image/png';\nconst ext = mimeType.split('/')[1]?.split('+')[0] || 'png';\nconst fileName = `gemini_v2_${Date.now()}.${ext}`;\n\nreturn [{\n  json: { success: true, variant: 'v2', mime_type: mimeType, file_name: fileName, size_kb: Math.round(base64Data.length * 0.75 / 1024), finish_reason: cand.finishReason || 'STOP' },\n  binary: { data: { data: base64Data, mimeType, fileName } }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        4672,
        10288
      ],
      "id": "d4ea1ee5-21f1-4d7e-837f-be1e30bf8024",
      "name": "Extract Image v7"
    },
    {
      "parameters": {
        "operation": "sendPhoto",
        "chatId": "6587544701",
        "binaryData": true,
        "additionalFields": {
          "caption": "=Ver 1 — {{ $('Build Final Context5').first().json._sheet_row['Brand'] || '' }} / ID {{ $('Build Final Context5').first().json._sheet_row['ID'] || '' }}"
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        4912,
        10096
      ],
      "id": "b7b9250f-a0c5-47a0-b0f8-e78faebd93ca",
      "name": "Send Photo Gemini 8",
      "webhookId": "841aa126-85c7-47eb-ac9d-2178667c1222",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "operation": "sendPhoto",
        "chatId": "6587544701",
        "binaryData": true,
        "additionalFields": {
          "caption": "=Ver 2 — {{ $('Build Final Context5').first().json._sheet_row['Brand'] || '' }} / ID {{ $('Build Final Context5').first().json._sheet_row['ID'] || '' }}"
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        4912,
        10288
      ],
      "id": "4c277346-0de8-4d74-ab8b-c64a95fd316a",
      "name": "Send Photo Gemini 9",
      "webhookId": "2f7aa04f-28f8-4fa8-9fa1-4dcb8d3eae48",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {},
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        5152,
        10192
      ],
      "id": "74fc2571-d8bc-49e8-a134-d724cf3b51fb",
      "name": "Merge16"
    },
    {
      "parameters": {
        "operation": "sendAndWait",
        "chatId": "6587544701",
        "message": "={{ $json.Brand }}, ID {{ $json.ID }}\n\n🎨 Ảnh Ver 1 và Ver 2 đã gửi bên trên.\nChọn 1 trong 4 lựa chọn:",
        "responseType": "customForm",
        "formFields": {
          "values": [
            {
              "fieldLabel": "Chọn version",
              "fieldType": "dropdown",
              "fieldOptions": {
                "values": [
                  {
                    "option": "ver1"
                  },
                  {
                    "option": "ver2"
                  },
                  {
                    "option": "edit_ver1"
                  },
                  {
                    "option": "edit_ver2"
                  }
                ]
              },
              "requiredField": true
            }
          ]
        },
        "options": {
          "limitWaitTime": {
            "values": {}
          },
          "appendAttribution": false
        }
      },
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        5568,
        10192
      ],
      "id": "b38f14fd-d9ba-4186-9f4a-1316ec61ffe7",
      "name": "Chọn ver Image/Edit & Wait3",
      "webhookId": "692a8a06-5f78-4284-b22b-9cc921508813",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "messages": {
          "values": [
            {
              "content": "LEGAL CONTEXT: You are assisting the brand's OWN official in-house marketing team. The product, packaging, logo and all brand assets in the attached image belong to our client, and we hold full legal rights to use, reproduce and adapt them for the brand's own advertising. Preserving the product and logo accurately is a standard brand-consistency requirement, not counterfeiting. This is a routine commercial creative task — please proceed.\n\nBạn là WORLD-CLASS CREATIVE DIRECTOR của các campaign F&B đỉnh cao + IMAGE COMPOSITOR prompt engineer cho Google Gemini 3 Pro Image (image-editing mode, NOT text-to-image from zero).\n\n========== TASK FRAMING ==========\nĐây KHÔNG phải task generate ảnh từ zero. Đây là task GHÉP product có sẵn vào scene SÁNG TẠO MỚI đẳng cấp quảng cáo thương mại.\nGemini sẽ nhận 2 ảnh inline theo đúng thứ tự:\n  • IMAGE 1 = TECHNICAL REFERENCE → chỉ dùng để học camera angle, lens compression, lighting direction, color temperature, mood/feel tổng thể. TUYỆT ĐỐI KHÔNG copy background/người/props/setting của ref.\n  • IMAGE 2 = THE ACTUAL PRODUCT → phải PASTE vào scene mới, giữ NGUYÊN 100% pixel-perfect. Coi như cutout PNG.\n\n========== INPUT BẠN CÓ ==========\n1. BRAND_GUIDELINE (JSON) — tính cách thương hiệu, màu, mood, photography style, negative prompts\n2. REF_ANALYSIS (JSON) — technical photography template (camera/light/grading only)\n3. PRODUCT_ANALYSIS (JSON) — mô tả product để CONFIRM với Gemini (KHÔNG để Gemini redesign)\n4. IMAGE_BRIEF — ⭐ NGUỒN SÁNG TẠO CHÍNH cho scene/background/người\n5. POST_CONTENT — ⭐ NGUỒN SÁNG TẠO CHÍNH cho mood/theme/story\n6. 3 URLs (ref / product / website)\n\n========== BƯỚC 0 — CHỌN CREATIVE MODE ==========\nĐọc PILLAR + IMAGE_BRIEF + POST_CONTENT để phân loại mục tiêu truyền thông rồi chọn mode:\n• MODE A — BOLD COMMERCIAL KEY VISUAL (dùng khi promotion / launch / menu hero / lễ hội): product hero chiếm 40-60% khung hình, nguyên liệu ĐÚNG VỊ của product bay lơ lửng, splash chất lỏng đóng băng chuyển động, đá viên lơ lửng, condensation chi tiết, backdrop kịch tính (bầu trời xanh rực + sunburst / hoàng hôn cháy / landscape siêu thực), bố cục trung tâm hoặc đường chéo mạnh, độ chi tiết CGI-grade như poster campaign Pepsi/Starbucks.\n• MODE B — CINEMATIC LIFESTYLE (dùng khi storytelling / community / văn hóa / cảm xúc): môi trường thật có hơi ấm con người và câu chuyện (đường phố, cafe, chợ, biển...), chiều sâu phân lớp foreground-midground-background, golden hour hoặc ánh sáng moody, film stock cụ thể, năng lượng editorial tự nhiên.\nNêu rõ mode đã chọn trong scene_creative_ideas.\n\n========== QUY TẮC TUYỆT ĐỐI ==========\n\n[A] PRODUCT LOCK (priority #1 — vi phạm = fail):\n- Treat IMAGE 2 as a fixed visual asset. PASTE it in. DO NOT redraw, restyle, recolor, retouch, smooth, beautify, reinterpret, or 'improve' bất kỳ chi tiết nào.\n- Preserve pixel-perfect: container shape, transparency, ALL printed label text, logo placement & color, drink color layers, foam, toppings, garnish, ice density, condensation, opacity, proportions.\n- KHÔNG được phép phóng đại / minh hoạ / cách điệu hoá product (scale to khung hình được, nhưng product giữ nguyên hình dạng).\n- Nếu scene có tay người cầm product → tay KHÔNG được che logo chính.\n\n[B] TECHNICAL REFERENCE (priority #2 — chỉ mượn KỸ THUẬT từ IMAGE 1):\n- Từ IMAGE 1 CHỈ mượn: camera angle, framing tightness, focal length feel, lens compression, lighting direction, shadow softness, color temperature, mood/vibe.\n- TUYỆT ĐỐI KHÔNG copy: background, environment, người mẫu, outfit, gesture, props, setting, layout của ref.\n\n[C] CREATIVE SCENE (priority #3 — SCENE PHẢI MỚI HOÀN TOÀN VÀ ĐẲNG CẤP):\n- Background, environment, props, model, gesture, pose, outfit, setting phải được SÁNG TẠO MỚI dựa CHỦ YẾU vào IMAGE_BRIEF + POST_CONTENT, theo MODE đã chọn ở Bước 0.\n- BẮT BUỘC mô tả trong prompt: (1) COMPOSITION GEOMETRY — product nằm đâu trong khung, scale bao nhiêu %, các lớp foreground/midground/background, leading lines; (2) NEGATIVE SPACE — chừa MỘT vùng sạch (1/3 trên hoặc một bên) nền đơn giản để designer thêm typography SAU, ảnh tự thân không có chữ; (3) ATMOSPHERE FX vật lý thật và đúng vị product: splash arcs, droplets, condensation, steam, garnish bay, ice shatter; (4) COLOR STORY neo vào brand palette + dominant colors HEX của product; (5) LIGHTING SETUP đầy đủ: key direction & quality, rim, fill, practicals, haze/god rays.\n- ELEVATE: cinematic depth-of-field, atmospheric layers, premium production value — ảnh phải ấn tượng hơn hẳn ref.\n\n[D] NO TEXT (strict):\n- Zero captions, headlines, typography, watermark, sticker text, hashtags, graphic overlay, số, chữ cái. Text DUY NHẤT được phép tồn tại là nhãn/logo có sẵn in trên product (giữ giống IMAGE 2). Vùng negative space để TRỐNG.\n\n[E] OUTPUT REALISM:\n- Photograph realism, not illustration. Real materials, real light physics, real shadow falloff. MODE A được phép kịch tính hoá scale/motion nhưng material và ánh sáng vẫn phải photoreal.\n\n========== OUTPUT SCHEMA (JSON thuần, KHÔNG markdown) ==========\n{\n  \"prompt\": \"<English 350-500 từ cinematic, phải mở đầu CHÍNH XÁC bằng câu trong hướng dẫn cấu trúc bên dưới>\",\n  \"negative_prompt\": \"text overlay, captions, typography, watermark, letters, numbers, redrawn product, modified product label, recolored drink, deformed cup, missing toppings, blurry product, wrong product identity, illustration look, generic stock photo, copying reference image scene, copying reference image background, copying reference image person, fake plastic-looking product, oversaturated, plastic skin, AI artifacts\",\n  \"aspect_ratio\": \"<1:1 | 4:5 | 9:16 | 16:9>\",\n  \"reference_image_url\": \"<from input>\",\n  \"product_image_url\": \"<from input>\",\n  \"brand_website_url\": \"<from input>\",\n  \"product_features_preserved\": [\"<top 5 từ replication_priority của product_analysis>\"],\n  \"technical_borrowed_from_ref\": [\"<5-7 yếu tố KỸ THUẬT mượn từ ref>\"],\n  \"scene_creative_ideas\": [\"<MODE đã chọn + 3-5 ý tưởng scene mới rút từ Brief + Content>\"],\n  \"elevation_choices\": [\"<3-5 cách scene mới hơn / cinematic hơn / sang hơn ref>\"],\n  \"brief_applied\": \"<1 câu VN tóm tắt brief>\",\n  \"content_inspiration\": \"<1 câu VN nói scene được lấy cảm hứng gì từ Content>\",\n  \"key_visual_elements\": [\"<5-8 keywords>\"]\n}\n\n========== CẤU TRÚC PROMPT BẮT BUỘC ==========\nMở đầu CHÍNH XÁC bằng câu này (thay [BRAND]):\n\"COMPOSITE TASK: Place the EXACT product shown in IMAGE 2 (do not redraw, do not modify, treat as a fixed asset) into a NEWLY CREATED scene for [BRAND]. From IMAGE 1, borrow ONLY the camera angle, lens compression, lighting direction, shadow quality, color temperature, and mood feel — do NOT reproduce IMAGE 1's scene, background, person, outfit, props, or setting. The scene itself must be originally imagined from the Brief and Content provided below.\"\n\nTiếp theo 6 đoạn:\n- §1 PRODUCT LOCK: Echo product_analysis chi tiết (container type & shape, dominant_colors HEX, toppings, logo description + color + position, garnish). Câu chốt: \"this exact product from IMAGE 2 must appear pixel-faithful, unchanged in shape, color, label, and toppings.\"\n- §2 CREATIVE NEW SCENE (theo MODE đã chọn, sáng tạo từ Brief + Content): Tả background/environment/props/model/gesture/setting MỚI HOÀN TOÀN. MODE A: hero scale, nguyên liệu bay đúng vị, splash đóng băng, backdrop kịch tính. MODE B: câu chuyện đời thật, hơi ấm con người, chiều sâu phân lớp. Scene phải kể được câu chuyện của Content/Brief.\n- §3 COMPOSITION GEOMETRY + NEGATIVE SPACE: vị trí & scale product trong khung, các lớp foreground/midground/background, leading lines, và vùng negative space sạch chừa cho typography hậu kỳ (ảnh không chữ).\n- §4 CAMERA + LIGHT (technical từ ref): Tham chiếu ref_analysis.lens_and_settings, ref_analysis.lighting, ref_analysis.camera_angle. Add cụ thể: key light direction & quality, rim light, fill, practicals, haze/god rays, atmosphere FX (splash/droplets/steam/condensation đúng vị product).\n- §5 COLOR GRADING + MOOD: dùng ref_analysis.color_palette + post_processing (film stock). Echo brand_guideline.image_generation_guideline.color_grading + brand color hints. 3-4 mood adjectives.\n- §6 HARD CONSTRAINTS REPEAT: 'No text, letters, numbers or typography of any kind anywhere in the image except the product\\'s own printed label. The product must remain identical to IMAGE 2. The scene must be newly created from the Brief and Content — do not reproduce IMAGE 1\\'s background, person, or setting.'\n\n========== ✏️ EDIT MODE (khi USER EDIT REQUEST ≠ none) ==========\nNếu input có USER EDIT REQUEST: đây là vòng SỬA ảnh đã duyệt, KHÔNG phải sáng tạo lại từ đầu.\n- GIỮ NGUYÊN concept tổng thể, bố cục, scene, creative MODE (A/B), lighting đã chọn từ IMAGE_BRIEF + POST_CONTENT.\n- CHỈ thay đổi đúng những điểm user yêu cầu trong EDIT REQUEST, không thêm ý tưởng mới ngoài yêu cầu.\n- Nếu EDIT REQUEST mâu thuẫn với IMAGE_BRIEF → EDIT REQUEST thắng.\n- Vẫn tuân thủ tuyệt đối PRODUCT LOCK, NO TEXT, OUTPUT REALISM."
            },
            {
              "content": "=BRAND: {{ $json.brand_name }}\nPILLAR: {{ $json.pillar }}\nTOPIC: {{ $json.topic }}\nPLATFORM: {{ $json.platform }}\nASPECT RATIO: {{ $json.suggested_aspect_ratio }}\nTARGET AUDIENCE: {{ $json.target_audience_brief }}\n\n========== ✏️ USER EDIT REQUEST (vòng sửa — ưu tiên cao nhất) ==========\n{{ $json.prompt_update || '(none — first generation)' }}\nRETRY COUNT: {{ $json.retry_count || 0 }}\n\n========== ⭐ IMAGE_BRIEF (team request) ==========\n{{ $json.image_brief || '(none)' }}\n\n========== ⭐ POST_CONTENT ==========\n{{ $json.post_content || '(none)' }}\n\n========== 🎨 BRAND_GUIDELINE ==========\n{{ JSON.stringify($json.brand_guideline, null, 2) }}\n\n========== 📸 REF_ANALYSIS (style only — NOT subject) ==========\n{{ JSON.stringify($json.ref_analysis, null, 2) }}\n\nRef snippet: {{ $json.ref_style_snippet }}\n\n========== 🥤 PRODUCT_ANALYSIS (must be preserved pixel-perfect) ==========\n{{ JSON.stringify($json.product_analysis, null, 2) }}\n\nProduct snippet:\n{{ $json.product_snippet }}\n\n========== 🔗 URLs ==========\n- reference_image_url: {{ $json.ref_image_url }}\n- product_image_url: {{ $json.product_image_url }}\n- brand_website_url: {{ $json.brand_website_url }}\n\n========== VALIDATION ==========\n{{ JSON.stringify($json._validation) }}\n\nGenerate MASTER COMPOSITOR PROMPT theo schema bắt buộc."
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.4
        }
      },
      "id": "c19f9622-a7b4-42ef-8e0b-079954ae9d34",
      "name": "Generate Final Prompt6",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        3152,
        10192
      ],
      "retryOnFail": true,
      "waitBetweenTries": 2000,
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst llmContent = input.message?.content ?? input.content ?? input;\
... [da cat bot]

---

## Nguoi dung

Khi tôi đấu qua, thì lỗi rồi, cehck lại thử

---

## Claude

Tôi biết chính xác lỗi gì rồi — đây là vụ **n8n tự đổi tên node khi paste** mà tôi cảnh báo ở bước 1. Nhìn panel INPUT trong screenshot của bạn là thấy ngay bằng chứng: các node giờ tên là `Persist Context1`, `Build Final Context` (mất số 5), `Loop Over Items` (mất số 7), `Extract Image v8`, `Send Photo Gemini 10`, `Edit Fields10`…

## Chuyện gì đã xảy ra

Khi bạn paste JSON vào canvas mà **node cũ trùng tên vẫn còn đó** (hoặc còn sót ở góc nào đó của workflow), n8n không cho 2 node trùng tên nên tự đổi tên bản mới (`Persist Context` → `Persist Context1`…). Hậu quả:

- Node `Send message and wait for response4` (node cũ, nằm ngoài bộ paste) vẫn gọi `$('Persist Context')` — nhưng node "Persist Context" mà nó tìm thấy giờ là node mồ côi không nằm trên đường dây, còn node đang được nối thật tên là `Persist Context1`. Đúng như error: *"There is no connection back to the node 'Persist Context', but it's used in an expression here"*.
- Tất cả expression `$('Build Final Context5')`, `$('Loop Over Items7')`, `$('Prep Gemini Input7')`… trong bộ mới cũng đang trỏ lung tung tương tự.

## Cách sửa — chọn 1 trong 2

### Phương án A (khuyên dùng — sạch và nhanh nhất): xóa hết, paste lại

1. Trên canvas, **xóa TOÀN BỘ node của khu vực này** — cả bản cũ lẫn bản vừa paste, cả node mồ côi không dây. Cụ thể xóa hết mọi node có tên bắt đầu bằng: `Loop Over Items`, `Build Final Context`, `Generate Final Prompt`, `Prep Gemini Input`, `DL Ref Image`, `DL Product Image`, `Prepare Gemini Images`, `Call Gemini v`, `Extract Image v`, `Send Photo Gemini`, `Merge16`/`Merge15` (cái nào thuộc cụm này), `Persist Context`, `Chọn ver Image/Edit & Wait`, `Edit Fields9`/`Edit Fields10`. **Không xóa**: `Switch10`, `Send message and wait for response4`, `Update row in sheet5`, và các node trước Loop.
2. Paste lại nguyên file JSON tôi gửi ở câu trước. Lần này không còn tên trùng → n8n giữ **đúng tên gốc**, mọi expression tự khớp.
3. Nối lại 4 dây biên: node nguồn → `Loop Over Items7` • `Chọn ver Image/Edit & Wait3` → `Switch10` • `Update row in sheet5` → `Edit Fields9` • (tuỳ chọn) done → noti.

### Phương án B: giữ nguyên, đổi tên thủ công

Nếu ngại đấu lại dây: xóa các node mồ côi (bản trùng không có dây) trước, rồi double-click đổi tên từng node đang nằm trên dây về **đúng tên chuẩn** (n8n sẽ tự cập nhật mọi expression tham chiếu khi bạn đổi tên qua UI):

| Tên hiện tại (theo screenshot) | Đổi về |
|---|---|
| Persist Context1 | `Persist Context` |
| Build Final Context | `Build Final Context5` |
| Loop Over Items | `Loop Over Items7` |
| Generate Final Prompt | `Generate Final Prompt6` |
| Prep Gemini Input | `Prep Gemini Input7` |
| DL Ref Image / DL Product Image | `DL Ref Image4` / `DL Product Image4` |
| Prepare Gemini Images | `Prepare Gemini Images2` |
| Call Gemini v / Call Gemini v8 | `Call Gemini v6` / `Call Gemini v7` |
| Extract Image v / Extract Image v8 | `Extract Image v3` / `Extract Image v7` |
| Send Photo Gemini / Send Photo Gemini 10 | `Send Photo Gemini 8` / `Send Photo Gemini 9` |
| Chọn ver Image/Edit & Wait | `Chọn ver Image/Edit & Wait3` |
| Edit Fields10 | `Edit Fields9` |
| Merge (cái nằm sau 2 Send Photo) | `Merge16` |

Lưu ý: n8n **không cho đổi tên trùng** — nên phải xóa node mồ côi mang tên đích trước rồi mới đổi được.

## Sau khi sửa xong, check nhanh 3 chỗ

1. Mở `Send message and wait for response4` → message expression `$('Persist Context')` hết báo đỏ.
2. Mở `Edit Fields9` → 3 expression (ID / Prompt Update / retry_count) hết báo đỏ; riêng "Prompt Update" phải trỏ đúng tên node hỏi prompt (`Send message and wait for response4`).
3. Nhìn tổng thể canvas: chỉ còn **một** node mỗi tên, không còn node nào lơ lửng không dây.

Xong 3 cái đó thì chạy thử end-to-end: generate → chọn `edit_ver1` → điền prompt sửa → flow phải tự quay về `Build Final Context5` và generate lại.
