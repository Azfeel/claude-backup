# N8N JSON workflow merge for image generation (fork)

- Phien: 2a890b7a-9c34-40a4-9927-c0535a7c679f
- Project: C--Users-nguyentrungtin-Documents
- Cap nhat: 2026-06-15 14:55

## File da tao / sua trong phien nay
- C:\Users\nguyentrungtin\Documents\n8n-hybrid-image-workflow.json
- C:\Users\nguyentrungtin\Documents\n8n-hybrid-image-workflow-v2.json

---

## Nguoi dung

Tôi có 2 bộ code Json sau, 1 cái dùng để làm chi tiết hình ảnh nhưng ko tạo ra được ảnh referrent mà tôi muốn
1 cái tạo được theo ảnh referrence nhungw lại ko chi tiết và chất lượng ko đồng đều
Hãy phân tích 2 bộ code này và đưa  tôi đề xuất có thể colleb lại gì để tạo ra bộ code có cấu trúc giống vậy nhưng khắc phục hết nhược điểmcủa 2 bộ trên workfflow build AI automation N8N

Bộ Json 1: 
{
  "nodes": [
    {
      "parameters": {
        "options": {}
      },
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [
        2432,
        12640
      ],
      "id": "126c81ef-c3bf-4f9c-af51-57aa920236c0",
      "name": "Loop Over Items7"
    },
    {
      "parameters": {
        "url": "={{ $json['Link Ref Image (origin)'] }}",
        "authentication": "genericCredentialType",
        "genericAuthType": "oAuth2Api",
        "sendQuery": true,
        "queryParameters": {
          "parameters": [
            {
              "name": "pin_metrics",
              "value": "false"
            }
          ]
        },
        "options": {
          "redirect": {
            "redirect": {}
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1200,
        12640
      ],
      "id": "5acbcd5e-6d9e-473e-bf93-145df23c4117",
      "name": "Fetch Pinterest Pin",
      "retryOnFail": true,
      "waitBetweenTries": 3000,
      "alwaysOutputData": true,
      "credentials": {
        "httpHeaderAuth": {
          "id": "lOso8FUQbncw5DDT",
          "name": "Header Auth account 5"
        },
        "oAuth2Api": {
          "id": "uPyoL6xmVR3EujSJ",
          "name": "Unnamed credential 2"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const html = String($input.first().json.data || $input.first().json.body || $input.first().json || '');\n\nlet loop = {};\ntry {\n  loop = $('Code in JavaScript').first().json || {};\n} catch (e) {\n  loop = {};\n}\n\nconst matches = [...html.matchAll(\n  /<script[^>]+type=\"application\\/ld\\+json\"[^>]*>([\\s\\S]*?)<\\/script>/g\n)];\n\nconst decodeHtml = (str) =>\n  str.replace(/&quot;/g, '\"').replace(/&#x27;/g, \"'\")\n     .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>');\n\nlet ld = null;\nfor (const m of matches) {\n  try {\n    const parsed = JSON.parse(decodeHtml(m[1]));\n    if (parsed.image || parsed.headline) {\n      ld = parsed;\n      break;\n    }\n  } catch (e) { /* skip */ }\n}\n\nlet fallbackImage = null;\nif (!ld?.image) {\n  const ogMatch = html.match(/<meta[^>]+property=\"og:image\"[^>]+content=\"([^\"]+)\"/);\n  fallbackImage = ogMatch ? ogMatch[1] : null;\n}\n\nconst imageUrl = ld?.image || fallbackImage || '';\n\nreturn [{\n  json: {\n    pin: {\n      ref_image_url:  imageUrl,\n      title:          ld?.headline || '',\n      description:    ld?.articleBody || '',\n      author_name:    ld?.author?.name || '',\n      author_url:     ld?.author?.url || '',\n      source_url:     ld?.sharedContent?.url || '',\n      date_published: ld?.datePublished || '',\n      saves:          ld?.interactionStatistic?.[0]?.userInteractionCount || 0,\n      parse_ok:       !!imageUrl\n    },\n    sheet: loop\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1408,
        12640
      ],
      "id": "bd1380c3-8a30-4947-bf70-a0f7f92c8726",
      "name": "Parse Pinterest Data (Update)"
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst raw =\n  input.content ||\n  input.message?.content ||\n  input.choices?.[0]?.message?.content ||\n  input.text ||\n  '{}';\n\nconst cleaned = String(raw)\n  .replace(/^```json\\s*/i, '')\n  .replace(/^```\\s*/i, '')\n  .replace(/```\\s*$/i, '')\n  .trim();\n\nlet ref_analysis = {};\nlet parse_error = null;\n\ntry {\n  ref_analysis = JSON.parse(cleaned);\n} catch (e) {\n  parse_error = e.message;\n  ref_analysis = { _raw: cleaned, _parse_failed: true };\n}\n\nconst requiredKeys = ['composition', 'framing', 'camera_angle', 'lighting', 'color_palette', 'mood', 'props_environment', 'subject_position', 'photography_style', 'post_processing', 'lens_and_settings', 'reusable_prompt_keywords'];\nconst missingKeys = requiredKeys.filter(k => !(k in ref_analysis));\n\nconst styleSnippet = parse_error ? '' : [\n  ref_analysis.photography_style,\n  ref_analysis.composition,\n  ref_analysis.framing,\n  ref_analysis.camera_angle,\n  ref_analysis.lighting,\n  ref_analysis.color_palette,\n  ref_analysis.lens_and_settings,\n  ref_analysis.post_processing,\n  ref_analysis.mood,\n  ref_analysis.props_environment,\n  (ref_analysis.reusable_prompt_keywords || []).join(', ')\n].filter(Boolean).join('. ');\n\nreturn [{\n  json: {\n    ...input,\n    ref_analysis,\n    ref_style_snippet: styleSnippet,\n    _meta: { parse_ok: !parse_error, parse_error, missing_keys: missingKeys }\n  }\n}];"
      },
      "id": "1fece306-6b43-476b-af93-30f645e47b3d",
      "name": "Parse Ref Analysis",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1824,
        12640
      ]
    },
    {
      "parameters": {
        "mode": "combine",
        "combineBy": "combineByPosition",
        "numberInputs": 3,
        "options": {}
      },
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        2256,
        12624
      ],
      "id": "358ebfb5-8a35-4fc2-8cfe-038a31ee262f",
      "name": "Merge"
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\n// ===== EDIT LANE UPDATE: vòng sửa đã tách sang nhánh Edit Lane riêng (Init Edit Round → Call Gemini Edit).\n// Node này giờ CHỈ phục vụ first generation — không đọc 'Prompt Update' từ Sheet nữa,\n// tránh dính revision note cũ còn lưu trên Sheet làm bẩn lần generate đầu. =====\nconst promptUpdate = '';\nconst isRetry = false;\n\n// loại bỏ giá trị null/rỗng để không đè mất dữ liệu gốc khi merge\nconst clean = (o) => Object.fromEntries(\n  Object.entries(o || {}).filter(([, v]) => v !== null && v !== undefined && v !== '')\n);\n\nlet item = input;\nif (isRetry) {\n  let base = {};\n  try { base = $('Loop Over Items7').first().json || {}; } catch (e) {}\n  let persisted = {};\n  try { persisted = Object.assign({}, ...$('Persist Context1').all().map(i => i.json)); } catch (e) {}\n  item = { ...base, ...clean(persisted), ...clean(input) };\n}\n\nlet brandGuideline = item.brand_guideline;\nif ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {\n  try {\n    let raw = String(item.content || item.message?.content)\n      .replace(/^```json\\s*/i, '').replace(/```\\s*$/i, '').trim();\n    brandGuideline = JSON.parse(raw);\n  } catch (e) { brandGuideline = brandGuideline || {}; }\n}\n\nconst sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;\n\nconst platform = String(sheet['Nền tảng'] || '').toLowerCase();\nlet defaultAR = '1:1';\nif (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';\nelse if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';\nelse if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';\n\nreturn [{\n  json: {\n    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',\n    pillar:                sheet['Pillar'] || '',\n    topic:                 sheet['Topic'] || '',\n    funnel:                sheet['Funnel'] || '',\n    target_audience_brief: sheet['Target Audience'] || '',\n    platform:              sheet['Nền tảng'] || '',\n    suggested_aspect_ratio: defaultAR,\n\n    image_brief:           sheet['Brief Images'] || '',\n    post_content:          sheet['Content'] || '',\n\n    prompt_update:         promptUpdate,\n    is_retry:              isRetry,\n    retry_count:           Number(input.retry_count || item.retry_count || 0),\n\n    brand_guideline:       brandGuideline || {},\n    ref_analysis:          item.ref_analysis || {},\n    product_analysis:      item.product_analysis || {},\n\n    ref_style_snippet:     item.ref_style_snippet || '',\n    product_snippet:       item.product_snippet || '',\n\n    brand_website_url:     sheet['Link Website'] || '',\n    ref_image_url:         item.pin?.ref_image_url || item.ref_image_url || '',\n    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',\n    product_image_url:     item.product_image_url || '',\n    product_drive_url:     sheet['Product Generate'] || '',\n\n    _validation: {\n      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,\n      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,\n      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,\n      has_product_img:    !!item.product_image_url,\n      has_ref_img:        !!(item.pin?.ref_image_url || item.ref_image_url),\n      has_image_brief:    !!sheet['Brief Images'],\n      has_prompt_update:  isRetry,\n      has_post_content:   !!sheet['Content']\n    },\n\n    _sheet_row: sheet\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2656,
        12656
      ],
      "id": "2190b8af-4ec7-41b0-ab67-2062a3964eca",
      "name": "Build Final Context"
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
        3456,
        12656
      ],
      "id": "b3e46118-2ed4-44af-ba0c-6f7c214a71ec",
      "name": "DL Ref Image",
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
        3648,
        12656
      ],
      "id": "f78b2e4b-18d2-41a2-896b-8899055055de",
      "name": "DL Product Image",
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
        3856,
        12656
      ],
      "id": "ac6b2b9d-431f-409c-bada-03e6a0f14cfc",
      "name": "Prepare Gemini Images"
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
        4144,
        12560
      ],
      "id": "333cd4d7-8073-45f6-ba25-df6c9e492f57",
      "name": "Call Gemini v",
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
        4144,
        12752
      ],
      "id": "6b5bdadb-ac9c-414c-b33d-f60a8e964a53",
      "name": "Call Gemini v8",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "resource": "image",
        "operation": "analyze",
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "text": "=You are a photography art director analyzing a reference image that will be used as an EDIT BASE: this exact image will later be edited to swap its content for a brand product, so we need BOTH reusable style patterns AND a precise literal layout map.\n\nCRITICAL RULES:\n1. For the 12 style fields: concrete photography vocabulary (focal length, aperture, lighting setup, film simulation), generalized.\n2. For literal_layout: describe LITERALLY what is in the image and WHERE — positions (top/bottom/left/right/center), approximate scale as % of frame. Do NOT generalize in this field.\n3. Never identify any person — describe only as 'an anonymous person' with pose + position.\n4. Each value 1-2 sentences in English.\n5. NEVER wrap response in markdown code fence. Return RAW JSON object only.\n\nBrand context:\n- Brand: {{ $json.sheet?.Brand || 'unknown' }}\n- Pillar: {{ $json.sheet?.Pillar || '' }}\n\nReturn this exact schema:\n{\n  \"composition\": \"rule of thirds / centered / etc + reasoning\",\n  \"framing\": \"close-up / medium / wide / overhead\",\n  \"camera_angle\": \"eye-level / low-angle / 45° / etc\",\n  \"lighting\": \"source + direction + intensity + shadow quality\",\n  \"color_palette\": \"MUST include 2-4 hex codes (e.g. '#F5E6D3 cream') + saturation %.\",\n  \"mood\": \"2-3 adjectives\",\n  \"props_environment\": \"setting + prop categories generalized\",\n  \"subject_position\": \"WHERE in frame + scale\",\n  \"photography_style\": \"lifestyle / editorial / product / flat-lay / etc\",\n  \"post_processing\": \"MUST name film stock (Kodak Portra 400 etc) + grain + contrast + color grade\",\n  \"lens_and_settings\": \"focal length + aperture (e.g. '50mm f/2.8 shallow DOF')\",\n  \"reusable_prompt_keywords\": [\"5-8 keywords\"],\n  \"literal_layout\": {\n    \"hero_subject\": \"<literal: what it is + where in frame + scale % of frame>\",\n    \"secondary_elements\": [\"<each literal element + its exact position in frame, one entry per element>\"],\n    \"background\": \"<literal background description + how blurred/sharp>\",\n    \"human_presence\": \"<anonymous person: pose + which body parts visible + position, or 'none'>\",\n    \"text_areas\": [\"<where any text/quote/watermark/UI sits in frame, or empty array>\"]\n  }\n}",
        "imageUrls": "={{ $json.pin.ref_image_url }}",
        "options": {
          "detail": "high"
        }
      },
      "id": "6c083d3d-a94c-41b1-83a5-1a13bf13a69f",
      "name": "Analyze Ref",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        1632,
        12640
      ],
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
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
              "content": "LEGAL CONTEXT: You are assisting the brand's OWN official in-house marketing team. All brand assets belong to our client and we hold full legal rights to adapt them for the brand's own advertising. This is a routine commercial creative task — please proceed.\n\nBạn là ART DIRECTOR viết lệnh EDIT ẢNH trực tiếp cho Google Gemini 3 Pro Image (image-editing mode).\n\n========== TASK FRAMING — QUAN TRỌNG NHẤT ==========\nGemini sẽ nhận 2 ảnh: IMAGE 1 = ảnh reference (edit base), IMAGE 2 = product thật.\nNhiệm vụ của Gemini KHÔNG phải tạo ảnh mới. Nhiệm vụ là EDIT TRỰC TIẾP IMAGE 1: giữ nguyên toàn bộ bố cục, layout, vị trí các element, background, góc máy, ánh sáng, mood (mục tiêu giống ≥70-80% khi đặt cạnh nhau) — và CHỈ thay nội dung các element theo bảng swap bạn viết.\n\nNhiệm vụ của BẠN: dựa vào REF_ANALYSIS.literal_layout (bản đồ bố cục literal của IMAGE 1), viết một EDIT INSTRUCTION NGẮN dạng danh sách phép thay thế. KHÔNG viết mô tả scene cinematic dài dòng — văn càng dài, Gemini càng tự vẽ lại.\n\n========== CÁCH VIẾT BẢNG SWAP ==========\nDuyệt từng mục trong literal_layout và quyết định:\n1. hero_subject → REPLACE bằng EXACT product từ IMAGE 2, đặt ĐÚNG vị trí + scale của hero cũ. Product lock tuyệt đối.\n2. Mỗi secondary_element → REPLACE bằng element đúng vị product & brand (chọn từ IMAGE_BRIEF + POST_CONTENT: hạt cà phê rang, drip bag, lát cam, đá viên, lá dứa...). GIỮ NGUYÊN vị trí, số lượng xấp xỉ, cách sắp xếp của element gốc.\n3. text_areas → REMOVE toàn bộ chữ/quote/watermark/UI, để vùng đó thành nền sạch trống.\n4. human_presence → giữ nguyên pose + vị trí nhưng là người ẩn danh MỚI phù hợp brand (đổi nhận dạng, không đổi tư thế). Nếu 'none' thì bỏ qua.\n5. Logo/brand khác trong ref → REMOVE hoặc thay bằng yếu tố trung tính.\n6. Background + lighting + camera + color structure → KEEP (chỉ nudge màu nhẹ về brand palette nếu cần).\n\n========== QUY TẮC VIẾT PROMPT ==========\n- Độ dài 150-250 từ, tiếng Anh, mệnh lệnh trực tiếp, đánh số từng phép REPLACE/REMOVE/KEEP.\n- Mở đầu CHÍNH XÁC bằng câu này (thay [BRAND]):\n\"EDIT TASK: Edit IMAGE 1 directly. Keep its composition, layout, element positions, background, camera angle, lighting and mood unchanged. Apply ONLY the following replacements for [BRAND]:\"\n- Trong phép thay hero phải có câu: \"Paste the EXACT product from IMAGE 2 pixel-faithful — do not redraw, recolor, restyle or deform its container, label, logo, drink layers or toppings.\"\n- Kết thúc bằng: \"Everything not listed above must remain visually identical to IMAGE 1. No text, letters, numbers or typography anywhere except the product's own printed label. Photorealistic output.\"\n- KHÔNG thêm props/ý tưởng mới ngoài bảng swap. KHÔNG di chuyển element sang vị trí khác.\n\n========== OUTPUT (JSON thuần, KHÔNG markdown fence) ==========\n{\n  \"prompt\": \"<edit instruction theo quy tắc trên>\",\n  \"negative_prompt\": \"text overlay, captions, typography, watermark, letters, numbers, redrawn product, modified product label, recolored drink, deformed cup, missing toppings, blurry product, wrong product identity, illustration look, different composition from IMAGE 1, relocated elements, new scene, extra props not requested, copying reference person identity, oversaturated, plastic skin, AI artifacts\",\n  \"aspect_ratio\": \"<1:1 | 4:5 | 9:16 | 16:9>\",\n  \"reference_image_url\": \"<from input>\",\n  \"product_image_url\": \"<from input>\",\n  \"brand_website_url\": \"<from input>\",\n  \"swap_map\": [\"<mỗi dòng: 'element gốc @ vị trí → element brand thay thế'>\"],\n  \"kept_from_ref\": [\"<5-7 thứ giữ nguyên: composition, background, lighting...>\"],\n  \"brief_applied\": \"<1 câu VN: Brief/Content được dùng chọn element thay thế thế nào>\"\n}"
            },
            {
              "content": "=BRAND: {{ $json.brand_name }}\nPILLAR: {{ $json.pillar }}\nTOPIC: {{ $json.topic }}\nPLATFORM: {{ $json.platform }}\nASPECT RATIO: {{ $json.suggested_aspect_ratio }}\n\n========== 📸 REF_ANALYSIS (chứa literal_layout = bản đồ bố cục IMAGE 1) ==========\n{{ JSON.stringify($json.ref_analysis, null, 2) }}\n\n========== ⭐ IMAGE_BRIEF (nguồn chọn element thay thế) ==========\n{{ $json.image_brief || '(none)' }}\n\n========== ⭐ POST_CONTENT ==========\n{{ $json.post_content || '(none)' }}\n\n========== 🥤 PRODUCT_ANALYSIS (product trong IMAGE 2 — lock tuyệt đối) ==========\n{{ $json.product_snippet }}\n\n========== 🎨 BRAND COLOR HINTS ==========\n{{ JSON.stringify($json.brand_guideline?.visual_style_cues || {}, null, 2) }}\n{{ JSON.stringify($json.brand_guideline?.image_generation_guideline?.color_grading || '', null, 2) }}\n\n========== 🔗 URLs ==========\n- reference_image_url: {{ $json.ref_image_url }}\n- product_image_url: {{ $json.product_image_url }}\n- brand_website_url: {{ $json.brand_website_url }}\n\nViết EDIT INSTRUCTION theo đúng quy tắc."
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.3
        }
      },
      "id": "3157c87c-ba19-4f0a-a3a4-c840ccc6a8f4",
      "name": "Generate Final Prompt",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        2896,
        12656
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
        "jsCode": "const input = $input.first().json;\n\nconst llmContent = input.message?.content ?? input.content ?? input;\nlet spec;\nif (typeof llmContent === 'string') {\n  try {\n    spec = JSON.parse(\n      String(llmContent)\n        .replace(/^```json\\s*/i, '')\n        .replace(/```\\s*$/i, '')\n        .trim()\n    );\n  } catch (e) {\n    spec = { prompt: String(llmContent), _parse_error: e.message };\n  }\n} else {\n  spec = llmContent || {};\n}\n\nlet ctx = {};\ntry {\n  ctx = $('Build Final Context5').first().json || {};\n} catch (e) {\n  ctx = {};\n}\n\nconst sheet = ctx._sheet_row || ctx || {};\n\nconst isHttp = (s) => typeof s === 'string' && /^https?:\\/\\//i.test(s.trim());\n\nconst firstHttp = (cands) => {\n  for (const v of cands) {\n    const val = String(v || '').trim();\n    if (isHttp(val)) return val;\n  }\n  return '';\n};\n\nlet refImageUrl = firstHttp([\n  ctx.ref_image_url,\n  spec.reference_image_url,\n  sheet['Link Ref Image 1'],\n  sheet['Link Ref Image 2'],\n  sheet['Link Ref Image (origin)']\n]);\n\nlet productImageUrl = firstHttp([\n  ctx.product_image_url,\n  spec.product_image_url,\n  sheet['Product Generate']\n]);\n\nconst PLACEHOLDER_URL = 'https://placehold.co/1024x1024.png';\nlet skipGeneration = false;\n\nif (!refImageUrl && productImageUrl) refImageUrl = productImageUrl;\nif (!productImageUrl && refImageUrl) productImageUrl = refImageUrl;\nif (!refImageUrl && !productImageUrl) {\n  refImageUrl = PLACEHOLDER_URL;\n  productImageUrl = PLACEHOLDER_URL;\n  skipGeneration = true;\n}\n\nconst brandWebsiteUrl = String(ctx.brand_website_url || sheet['Link Website'] || '').trim();\n\nconst aspectRatio = spec.aspect_ratio || ctx.suggested_aspect_ratio || '1:1';\n\n// ===== PROMPT GỌN — EDIT TRỰC TIẾP IMAGE 1, không dump JSON context =====\nconst hardRules = [\n  '╔══════════════════════════════════════════════════════════╗',\n  '║  EDIT IMAGE 1 DIRECTLY — DO NOT GENERATE A NEW SCENE      ║',\n  '╚══════════════════════════════════════════════════════════╝',\n  '',\n  'TWO inline images are attached IN THIS ORDER:',\n  '  • inline_data #1 = IMAGE 1 = THE BASE IMAGE TO EDIT.',\n  '      Keep it ~80% visually identical: composition, layout, every element\\'s',\n  '      position and scale, background, perspective, camera angle, lens feel,',\n  '      lighting direction and quality, shadows, color structure, mood.',\n  '  • inline_data #2 = IMAGE 2 = THE REAL PRODUCT.',\n  '      Paste it pixel-faithful to replace the hero subject of IMAGE 1, at the',\n  '      same position and scale. Do NOT redraw, recolor, restyle, smooth or',\n  '      deform its container, transparency, label text, logo, drink layers,',\n  '      foam, toppings or proportions.',\n  '',\n  'RULES:',\n  '  • Apply ONLY the replacements listed in the EDIT INSTRUCTION below.',\n  '  • Replaced elements stay at the ORIGINAL positions/arrangement of IMAGE 1.',\n  '  • Remove ALL text, quotes, watermarks and UI from IMAGE 1 — leave those',\n  '    areas as clean empty background (negative space for post typography).',\n  '  • Any person: keep pose and position, but a NEW anonymous identity.',\n  '  • No text, letters or numbers anywhere except the product\\'s own printed label.',\n  '  • Photorealistic output: real materials, real light physics.',\n  `  • Output aspect ratio: ${aspectRatio}. If IMAGE 1 differs, extend or crop the`,\n  '    background minimally while preserving the relative layout — do not recompose.',\n  ''\n].join('\\n');\n\nconst fullPrompt = [\n  hardRules,\n  '═══════════ EDIT INSTRUCTION ═══════════',\n  spec.prompt || '',\n  '',\n  '═══════════ PRODUCT LOCK (what IMAGE 2 contains) ═══════════',\n  ctx.product_snippet || '',\n  '',\n  '[NEGATIVE]',\n  (spec.negative_prompt || '') + ', different composition from IMAGE 1, relocated elements, new scene, redrawn product, modified product label, text overlay, typography, watermark, illustration look, oversaturated, AI artifacts'\n].filter(Boolean).join('\\n');\n\nreturn [{\n  json: {\n    'ID':                  sheet['ID'] || '',\n    'Brand':               sheet['Brand'] || sheet['Brand Name'] || '',\n    'retry_count':         ctx.retry_count || 0,\n    'full_prompt_text':    fullPrompt,\n    'full_prompt_variant': fullPrompt + '\\n\\n[VARIANT INSTRUCTION] Apply the SAME edits on IMAGE 1, but vary ONLY the interpretation of the swapped elements: different flavor-true brand props in the SAME positions (e.g. coffee beans → drip bags or orange slices), and a subtle shift in color mood or time of day. The composition, layout and element positions must still match IMAGE 1. Product remains 100% IDENTICAL to IMAGE 2.',\n    'aspect_ratio':        aspectRatio,\n    'reference_image_url': refImageUrl,\n    'product_image_url':   productImageUrl,\n    'brand_website_url':   brandWebsiteUrl,\n    '_skip_generation':    skipGeneration\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        3248,
        12656
      ],
      "id": "38452c43-06a8-4036-aa67-cbc725df7d48",
      "name": "Prep Gemini Input"
    }
  ],
  "connections": {
    "Loop Over Items7": {
      "main": [
        [],
        [
          {
            "node": "Build Final Context",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fetch Pinterest Pin": {
      "main": [
        [
          {
            "node": "Parse Pinterest Data (Update)",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse Pinterest Data (Update)": {
      "main": [
        [
          {
            "node": "Analyze Ref",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse Ref Analysis": {
      "main": [
        [
          {
            "node": "Merge",
            "type": "main",
            "index": 1
          }
        ]
      ]
    },
    "Merge": {
      "main": [
        [
          {
            "node": "Loop Over Items7",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Build Final Context": {
      "main": [
        [
          {
            "node": "Generate Final Prompt",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "DL Ref Image": {
      "main": [
        [
          {
            "node": "DL Product Image",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "DL Product Image": {
      "main": [
        [
          {
            "node": "Prepare Gemini Images",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Gemini Images": {
      "main": [
        [
          {
            "node": "Call Gemini v",
            "type": "main",
            "index": 0
          },
          {
            "node": "Call Gemini v8",
            "type": "main",
            "index": 0
          }
  
... [da cat bot]

---

## Claude

Tôi sẽ phân tích kỹ 2 workflow, chỉ ra nguyên nhân gốc của từng nhược điểm, rồi build luôn bộ JSON hybrid cho bạn import vào n8n.

## Phân tích nhanh 2 bộ

**Bộ 1 (EDIT lane)** — giống ref nhưng kém chi tiết, chất lượng không đều:
- Triết lý đúng: phân tích `literal_layout` của ảnh ref → viết swap map (REPLACE/REMOVE/KEEP) → Gemini chỉ edit IMAGE 1. Vì vậy nó bám layout ref rất tốt.
- Nhưng prompt chỉ 150–250 từ, **không có bất kỳ chỉ dẫn render quality nào**: không lighting setup, không film stock, không lens/grading, không micro-detail FX → Gemini "giữ nguyên mọi thứ" nên render phẳng, chất lượng phụ thuộc hên xui vào ảnh ref gốc.
- **Bug thật sự**: node `Prep Gemini Input` của Bộ 1 gọi `$('Build Final Context5')` nhưng node trong workflow tên là `Build Final Context` (không có số 5). Reference fail → `ctx = {}` → mất `product_snippet`, mất `ref_image_url` ưu tiên, mất `retry_count` → **section PRODUCT LOCK trong prompt bị rỗng** → đây là lý do lớn khiến chất lượng không đồng đều.

**Bộ 2 (COMPOSITE lane)** — chi tiết đẹp nhưng không giống ref:
- Prompt 350–500 từ với MODE A/B, lighting setup đầy đủ, film stock, atmosphere FX → ảnh rất chi tiết.
- Nhưng system prompt **ra lệnh tường minh "TUYỆT ĐỐI KHÔNG copy background/layout của ref, chỉ mượn kỹ thuật"** + Analyze Ref của nó không có `literal_layout` → Gemini không có bản đồ bố cục để bám → tất nhiên không ra giống ảnh reference.
- Nhược điểm phụ: `Prep Gemini Input7` dump nguyên 3 cục JSON (brand guideline, ref analysis, product analysis) vào prompt → prompt quá dài, nhiễu, Gemini dễ "tự sáng tác" thêm.

## Đề xuất ghép (lấy gì từ đâu)

| Thành phần | Lấy từ | Lý do |
|---|---|---|
| Analyze Ref (style 12 trường + `literal_layout`) | Bộ 1 | Đã là hybrid sẵn — vừa có style vừa có bản đồ layout |
| Khung EDIT TASK + swap map đánh số | Bộ 1 | Đảm bảo bám layout ref ≥70–80% |
| Khối QUALITY (lighting setup, film stock, lens, HEX color, micro FX) | Bộ 2 | Bơm độ chi tiết vào prompt — nhưng **giới hạn "render-only, cấm đổi layout"** |
| Product lock chi tiết (container, label, layers, toppings…) | Bộ 2 | Khóa sản phẩm chặt hơn bản rút gọn của Bộ 1 |
| Retry/Edit mode trong Build Final Context | Bộ 2 | Bộ 1 đã cắt mất vòng sửa |
| Prompt gọn, không dump JSON | Bộ 1 | Chỉ đưa `ref_style_snippet` + `product_snippet`, bỏ dump 3 cục JSON |
| Sửa bug tên node + thêm `imageConfig.aspectRatio` vào Gemini body | Mới | Aspect ratio hiện chỉ "xin" bằng text — ép cứng qua API mới đều |

Ý tưởng cốt lõi của prompt hybrid: **"Layout bị khóa theo IMAGE 1, chất lượng render được nâng lên chuẩn campaign"** — prompt 250–400 từ gồm 2 phần: PHẦN 1 = SWAP MAP (từ `literal_layout`), PHẦN 2 = QUALITY ELEVATION (chỉ được nâng texture/ánh sáng/grading, cấm thêm props, cấm di chuyển element).

Giờ tôi build file JSON hoàn chỉnh:

---

## Claude

*[Thao tac file: Write -> C:\Users\nguyentrungtin\Documents\n8n-hybrid-image-workflow.json]*

---

## Claude

Kiểm tra file JSON hợp lệ trước khi bạn import:

---

## Claude

Xong — file [n8n-hybrid-image-workflow.json](n8n-hybrid-image-workflow.json) đã được tạo và validate hợp lệ, import thẳng vào n8n được.

## Tóm tắt phân tích

**Tại sao Bộ 1 giống ref nhưng kém chi tiết, chất lượng không đều:**
- Prompt edit chỉ 150–250 từ, hoàn toàn không có chỉ dẫn render quality (lighting setup, film stock, lens, micro-detail) — Gemini "giữ nguyên mọi thứ" nên render phẳng, chất lượng phụ thuộc ảnh ref gốc.
- **Bug nghiêm trọng**: node `Prep Gemini Input` gọi `$('Build Final Context5')` trong khi node thật tên `Build Final Context` → reference fail → mất toàn bộ context (product_snippet rỗng → section PRODUCT LOCK trống, mất ref_image_url ưu tiên). Đây chính là thủ phạm lớn của "chất lượng không đồng đều".
- Aspect ratio chỉ "xin" bằng text trong prompt, không ép qua API.

**Tại sao Bộ 2 chi tiết nhưng không giống ref:**
- System prompt ra lệnh tường minh *"TUYỆT ĐỐI KHÔNG copy background/layout/scene của ref, chỉ mượn kỹ thuật"* + node Analyze Ref không trích `literal_layout` → Gemini không có bản đồ bố cục để bám.
- `Prep Gemini Input7` dump nguyên 3 cục JSON (brand guideline, ref analysis, product analysis) vào prompt → quá dài và nhiễu, Gemini càng dễ tự sáng tác.

## Bộ hybrid đã ghép thế nào

Giữ nguyên cấu trúc chuỗi node như 2 bộ cũ (Fetch Pin → Parse → Analyze Ref → Parse Ref → Merge → Build Context → Generate Prompt → Prep Input → DL 2 ảnh → Prepare Images → 2 Call Gemini), với triết lý mới: **"Layout khóa theo IMAGE 1, render nâng lên chuẩn campaign"**:

1. **Analyze Ref** — lấy bản Bộ 1 (12 trường style + `literal_layout`), thêm `literal_layout` vào danh sách required keys khi validate.
2. **Generate Final Prompt** — system prompt mới 2 phần: **PHẦN 1 = SWAP MAP** đánh số (cơ chế bám layout của Bộ 1) + **PHẦN 2 = QUALITY ELEVATION** (lighting setup, lens, film stock, HEX grading, micro FX từ Bộ 2) nhưng bị ràng *"render-only: cấm thêm props, cấm di chuyển element, cấm đổi scene"*. Giữ EDIT MODE/retry của Bộ 2. Temperature 0.3 (thấp như Bộ 1 để output ổn định).
3. **Prep Gemini Input** — đã **sửa bug tên node** (`Build Final Context` đúng tên), prompt gọn kiểu Bộ 1 (không dump JSON) nhưng bổ sung khối QUALITY DIRECTION (`ref_style_snippet` + `quality_elevation` từ spec), product lock chi tiết của Bộ 2, và revision note khi retry.
4. **Prepare Gemini Images** — thêm 2 fix ổn định chất lượng: fallback đọc context từ `$('Prep Gemini Input')` (vì HTTP node tải file có thể nuốt mất json), và **ép `imageConfig.aspectRatio` qua API Gemini** thay vì chỉ xin bằng text. Có guard `_skip_generation`.
5. **Negative prompt** = hợp nhất cả 2 bộ, thêm `flat lighting, low detail` để chống render phẳng.

## Lưu ý khi import

- **Merge Context** có 3 input: nhánh ref đang vào **input 1** (giống bản gốc) — bạn cần nối lại 2 nhánh brand guideline và product analysis (không nằm trong 2 JSON bạn gửi) vào input 0 và 2.
- Code còn tham chiếu các node ngoài: `Code in JavaScript` (nguồn sheet row), `Loop Over Items7` và `Persist Context` (cho retry) — đều bọc try/catch nên không lỗi nếu thiếu, nhưng nối vào thì retry mode mới hoạt động đầy đủ.
- Credentials giữ nguyên ID của instance bạn nên không cần gán lại.

Một gợi ý thêm nếu vẫn thấy chất lượng dao động: thêm 1 node GPT-4o vision sau Call Gemini để chấm điểm output (so layout với ref + so product với IMAGE 2, thang 1–10) và tự retry khi dưới ngưỡng — đó là cách triệt để nhất xử lý "chất lượng không đồng đều" thay vì chỉ dựa vào prompt.

---

## Nguoi dung

Flow ko chạy được, dừng ở khúc merge rồi đứng yên luôn

* Kiểm tra lại, đây là flow của function này: Quét link website, quét link ảnh ref và quét link sản phẩm
-> Hãy gắn bộ code mới vào với bộ flow này để có thể chạy được, vì trong merge đã hiện no data input

---

## Claude

No response requested.

---

## Nguoi dung

Flow ko chạy được, dừng ở khúc merge rồi đứng yên luôn

* Kiểm tra lại, đây là flow của function này: Quét link website, quét link ảnh ref và quét link sản phẩm
-> Hãy gắn bộ code mới vào với bộ flow này để có thể chạy được, vì trong merge đã hiện no data input

{
  "nodes": [
    {
      "parameters": {
        "operation": "scrape",
        "url": "={{ $json['Link Website'] }}",
        "parsers": "=const res = $input.first().json;\nconst data = res.data || {};\nlet md = data.markdown || '';\n\nmd = md\n  .replace(/sweetsaigon\\.com is blocked[\\s\\S]*?Reload/g, '')\n  .replace(/shop\\.app is blocked[\\s\\S]*?Reload/g, '')\n  .replace(/ERR_BLOCKED_BY_CLIENT/g, '')\n  .replace(/<Base64-Image-Removed>/g, '')\n  .replace(/!\\[\\]\\([^)]*\\)/g, '')\n  .replace(/\\[Skip to content\\][\\s\\S]*?Continue shopping/g, '')\n  .replace(/\\n{3,}/g, '\\n\\n')\n  .trim();\n\nconst meta = data.metadata || {};\n\nconst brand_content = (md.length > 100)\n  ? `# ${meta.title?.trim() || 'Brand'}\nTagline: ${meta.description || ''}\nURL: ${meta.sourceURL || ''}\n\n${md}`\n  : \"Không scrape được nội dung. Hãy phân tích dựa trên tên brand và pillar.\";\n\nreturn [{\n  json: {\n    ...res,\n    brand_content,\n    brand_meta: {\n      title: meta.title?.trim(),\n      description: meta.description,\n      og_image: meta.ogImage,\n      url: meta.sourceURL,\n      language: meta.language\n    },\n    scrape_ok: md.length > 100\n  }\n}];",
        "requestOptions": {}
      },
      "type": "@mendable/n8n-nodes-firecrawl.firecrawl",
      "typeVersion": 1,
      "position": [
        1152,
        12384
      ],
      "id": "3028061c-6a12-42e5-95fa-2cdd431ccf5d",
      "name": "/scrape",
      "credentials": {
        "firecrawlApi": {
          "id": "UV4YStHnCw96ilbC",
          "name": "Firecrawl account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const fc = $input.first().json;\nconst data = fc.data || fc;\nconst markdown = (data.markdown || \"\").slice(0, 8000);\nconst screenshot = data.screenshot || \"\";\nconst sheet = $('Code in JavaScript').first().json;\nreturn [{\n  json: {\n    ...sheet,\n    brand_markdown: markdown,\n    brand_screenshot: screenshot,\n    brand_content: fc.brand_content || markdown,\n    brand_meta: fc.brand_meta || {}\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1344,
        12384
      ],
      "id": "edaecd61-cfbe-48ea-bc19-d53c4d65296e",
      "name": "Prep Brand Input"
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "gpt-4o-mini",
          "mode": "list",
          "cachedResultName": "gpt-4o-mini"
        },
        "messages": {
          "values": [
            {
              "content": "Bạn là brand strategist chuyên phân tích F&B brand cho thị trường người Việt ở US.\n\nNHIỆM VỤ: Phân tích brand từ website content + metadata → trả về JSON đúng schema bên dưới.\n\n========== QUY TẮC BẮT BUỘC ==========\n\n1. **TAGLINE** phải lấy từ `brand_meta.title` hoặc `brand_meta.description` của website.\n2. **NGÔN NGỮ:** field MÔ TẢ tiếng Việt; field từ khóa giữ ngôn ngữ gốc brand; negative_prompts tiếng Anh.\n3. **TARGET AUDIENCE:** nếu có US location → BẮT BUỘC nhắc Vietnamese diaspora + người Mỹ tò mò văn hóa VN.\n4. **COLOR HINTS:** chỉ liệt kê khi có manh mối text. KHÔNG đoán theo stereotype.\n5. **IMAGE_GENERATION_GUIDELINE** phải là OBJECT 6 sub-field cụ thể.\n\n========== SCHEMA ==========\n{\n  \"brand_name\": \"...\",\n  \"tagline\": \"...\",\n  \"tone_of_voice\": [\"...\"],\n  \"brand_personality\": \"...\",\n  \"core_values\": [\"...\"],\n  \"target_audience\": \"...\",\n  \"visual_style_cues\": {\n    \"mood\": \"...\",\n    \"color_hints\": [\"...\"],\n    \"imagery_style\": \"...\"\n  },\n  \"usp\": \"...\",\n  \"do_say\": [\"...\"],\n  \"dont_say\": [\"...\"],\n  \"image_generation_guideline\": {\n    \"photography_style\": \"...\",\n    \"lighting\": \"...\",\n    \"composition\": \"...\",\n    \"props_and_setting\": \"...\",\n    \"color_grading\": \"...\",\n    \"negative_prompts\": [\"...\"]\n  }\n}\n\nChỉ trả JSON thuần. KHÔNG markdown fence."
            },
            {
              "content": "=Brand Name: {{ $json['Brand Name'] || $json['Brand'] || 'unknown' }}\n\nBrand Website Metadata:\n- Title: {{ $json.brand_meta?.title || '' }}\n- Description: {{ $json.brand_meta?.description || '' }}\n- URL: {{ $json.brand_meta?.url || $json['Link Website'] || '' }}\n- Language: {{ $json.brand_meta?.language || '' }}\n\nWebsite Content (markdown):\n{{ $json.brand_content || $json.brand_markdown }}"
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.3
        }
      },
      "id": "6b812414-ada5-45c7-8a9c-7d70dcad5394",
      "name": "Analyze Brand",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        1536,
        12384
      ],
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst raw =\n  input.content ||\n  input.message?.content ||\n  input.choices?.[0]?.message?.content ||\n  input.text ||\n  '{}';\n\nconst cleaned = String(raw)\n  .replace(/^```json\\s*/i, '')\n  .replace(/^```\\s*/i, '')\n  .replace(/```\\s*$/i, '')\n  .trim();\n\nlet brand_guideline = {};\nlet parse_error = null;\n\ntry {\n  brand_guideline = JSON.parse(cleaned);\n} catch (e) {\n  parse_error = e.message;\n  brand_guideline = { _raw: cleaned, _parse_failed: true };\n}\n\nreturn [{\n  json: {\n    ...input,\n    brand_guideline,\n    _brand_parse_ok: !parse_error,\n    _brand_parse_error: parse_error\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1872,
        12384
      ],
      "id": "b0d94cc7-6f31-4918-84b4-d810bd4cc190",
      "name": "Parse Brand Output"
    },
    {
      "parameters": {
        "jsCode": "const sheet = $('Code in JavaScript').first().json;\nconst raw = (sheet['Product Generate'] || \"\").trim();\nconst m = raw.match(/\\/d\\/([a-zA-Z0-9_-]{20,})|[?&]id=([a-zA-Z0-9_-]{20,})/);\nconst fileId = m ? (m[1] || m[2]) : \"\";\nconst productImageUrl = fileId\n  ? `https://drive.google.com/thumbnail?id=${fileId}&sz=w2000`\n  : raw;\nreturn [{\n  json: {\n    ...sheet,\n    product_image_url: productImageUrl,\n    product_file_id: fileId,\n    product_drive_raw: raw\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1200,
        12912
      ],
      "id": "c10b4d17-932a-490c-bc33-529cab13cf57",
      "name": "Parse Product URL"
    },
    {
      "parameters": {
        "resource": "image",
        "operation": "analyze",
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "text": "=You are a product photography analyst. The image attached is a PRODUCT photo. Describe it in PRECISE structured JSON so image gen can REPLICATE the exact product.\n\nBrand: {{ $json['Brand'] || 'unknown' }}\nTopic: {{ $json['Topic'] || '' }}\nBrief: {{ $json['Brief Images'] || '' }}\n\nBe SPECIFIC about visual details: exact colors (HEX), shapes, materials, branding, garnishes, packaging.\n\nReturn EXACT JSON (raw, no markdown fence):\n{\n  \"product_name\": \"<name on packaging or infer from brief>\",\n  \"product_category\": \"<beverage / food / dessert>\",\n  \"container\": {\n    \"type\": \"<plastic cup / glass / mug / etc>\",\n    \"shape\": \"<tall / short / cone / etc>\",\n    \"material\": \"<clear plastic / glass / ceramic>\",\n    \"lid\": \"<dome / flat / none / straw>\",\n    \"size_estimate\": \"<small / medium / large>\"\n  },\n  \"main_content\": {\n    \"liquid_or_food\": \"<what's inside>\",\n    \"dominant_colors\": [\"<2-4 with HEX>\"],\n    \"texture\": \"<smooth / chunky / icy / layered>\",\n    \"toppings\": [\"<visible toppings>\"]\n  },\n  \"branding\": {\n    \"logo_visible\": \"<yes/no>\",\n    \"logo_description\": \"<text style + icon + mascot>\",\n    \"logo_color\": \"<color>\",\n    \"logo_position\": \"<front / wrap / lid>\",\n    \"social_handles_visible\": [\"<@handles>\"]\n  },\n  \"garnish_and_props\": [\"<external garnish/props>\"],\n  \"background\": \"<white / transparent / lifestyle>\",\n  \"photography_style\": \"<flat / lifestyle / studio>\",\n  \"lighting_in_original\": \"<soft / hard / natural>\",\n  \"replication_priority\": [\"<top 3-5 things MUST preserve>\"],\n  \"do_not_change\": [\"<identity elements>\"]\n}",
        "imageUrls": "={{ $json.product_image_url }}",
        "options": {
          "detail": "high"
        }
      },
      "id": "80cffe28-f4f1-4406-a911-6693a963c38c",
      "name": "Analyze Product",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        1408,
        12912
      ],
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst raw =\n  input.content ||\n  input.message?.content ||\n  input.choices?.[0]?.message?.content ||\n  input.text ||\n  '{}';\n\nconst cleaned = String(raw)\n  .replace(/^```json\\s*/i, '')\n  .replace(/^```\\s*/i, '')\n  .replace(/```\\s*$/i, '')\n  .trim();\n\nlet product_analysis = {};\nlet parse_error = null;\n\ntry {\n  product_analysis = JSON.parse(cleaned);\n} catch (e) {\n  parse_error = e.message;\n  product_analysis = { _raw: cleaned, _parse_failed: true };\n}\n\nconst snippet = parse_error ? '' : [\n  `Product: ${product_analysis.product_name || ''} (${product_analysis.product_category || ''})`,\n  `Container: ${product_analysis.container?.type || ''} - ${product_analysis.container?.shape || ''}`,\n  `Content: ${product_analysis.main_content?.liquid_or_food || ''}`,\n  `Colors: ${(product_analysis.main_content?.dominant_colors || []).join(', ')}`,\n  `Toppings: ${(product_analysis.main_content?.toppings || []).join(', ')}`,\n  `Logo: ${product_analysis.branding?.logo_description || ''} (${product_analysis.branding?.logo_color || ''}) at ${product_analysis.branding?.logo_position || ''}`,\n  `Garnish: ${(product_analysis.garnish_and_props || []).join(', ')}`,\n  `MUST PRESERVE: ${(product_analysis.replication_priority || []).join('; ')}`\n].filter(Boolean).join('\\n');\n\nlet productUrlData = {};\ntry {\n  productUrlData = $('Parse Product URL').first().json || {};\n} catch (e) {\n  productUrlData = {};\n}\n\nreturn [{\n  json: {\n    product_analysis,\n    product_snippet: snippet,\n    product_image_url: input.product_image_url || productUrlData.product_image_url || '',\n    product_file_id:   input.product_file_id   || productUrlData.product_file_id || '',\n    _product_parse_ok: !parse_error,\n    _product_parse_error: parse_error\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1632,
        12912
      ],
      "id": "8ac3b499-41ec-4104-92a4-1af3db8a97dc",
      "name": "Parse Product Analysis"
    },
    {
      "parameters": {
        "jsCode": "const html = String($input.first().json.data || $input.first().json.body || $input.first().json || '');\n\nlet loop = {};\ntry {\n  loop = $('Code in JavaScript').first().json || {};\n} catch (e) {\n  loop = {};\n}\n\nconst matches = [...html.matchAll(\n  /<script[^>]+type=\"application\\/ld\\+json\"[^>]*>([\\s\\S]*?)<\\/script>/g\n)];\n\nconst decodeHtml = (str) =>\n  str.replace(/&quot;/g, '\"').replace(/&#x27;/g, \"'\")\n     .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>');\n\nlet ld = null;\nfor (const m of matches) {\n  try {\n    const parsed = JSON.parse(decodeHtml(m[1]));\n    if (parsed.image || parsed.headline) {\n      ld = parsed;\n      break;\n    }\n  } catch (e) { /* skip */ }\n}\n\nlet fallbackImage = null;\nif (!ld?.image) {\n  const ogMatch = html.match(/<meta[^>]+property=\"og:image\"[^>]+content=\"([^\"]+)\"/);\n  fallbackImage = ogMatch ? ogMatch[1] : null;\n}\n\nconst imageUrl = ld?.image || fallbackImage || '';\n\nreturn [{\n  json: {\n    pin: {\n      ref_image_url:  imageUrl,\n      title:          ld?.headline || '',\n      description:    ld?.articleBody || '',\n      author_name:    ld?.author?.name || '',\n      author_url:     ld?.author?.url || '',\n      source_url:     ld?.sharedContent?.url || '',\n      date_published: ld?.datePublished || '',\n      saves:          ld?.interactionStatistic?.[0]?.userInteractionCount || 0,\n      parse_ok:       !!imageUrl\n    },\n    sheet: loop\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1376,
        12640
      ],
      "id": "b77a023a-1665-4787-9031-d9bad8d57378",
      "name": "Parse Pinterest Data"
    },
    {
      "parameters": {
        "mode": "combine",
        "combineBy": "combineByPosition",
        "numberInputs": 3,
        "options": {}
      },
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        2176,
        12624
      ],
      "id": "496190cc-c33f-4956-9bf8-1a83ae460d81",
      "name": "Merge Context"
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
        3904,
        12560
      ],
      "id": "cd86a8e9-0778-47ee-a988-05098a8eb8b9",
      "name": "Call Gemini Base",
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
        3872,
        12752
      ],
      "id": "0a344599-93ce-445f-b786-b10f4318057e",
      "name": "Call Gemini Variant",
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "url": "={{ $json['Link Ref Image (origin)'] }}",
        "authentication": "genericCredentialType",
        "genericAuthType": "oAuth2Api",
        "sendQuery": true,
        "queryParameters": {
          "parameters": [
            {
              "name": "pin_metrics",
              "value": "false"
            }
          ]
        },
        "options": {
          "redirect": {
            "redirect": {}
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1168,
        12640
      ],
      "id": "1a0155cb-7772-4482-8cad-6e26d373158f",
      "name": "Fetch Pinterest Pin1",
      "retryOnFail": true,
      "waitBetweenTries": 3000,
      "alwaysOutputData": true,
      "credentials": {
        "httpHeaderAuth": {
          "id": "lOso8FUQbncw5DDT",
          "name": "Header Auth account 5"
        },
        "oAuth2Api": {
          "id": "uPyoL6xmVR3EujSJ",
          "name": "Unnamed credential 2"
        }
      }
    },
    {
      "parameters": {
        "resource": "image",
        "operation": "analyze",
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "GPT-4O"
        },
        "text": "=You are a photography art director analyzing a reference image that will be used as an EDIT BASE: this exact image will later be edited to swap its content for a brand product, so we need BOTH reusable style patterns AND a precise literal layout map.\n\nCRITICAL RULES:\n1. For the 12 style fields: concrete photography vocabulary (focal length, aperture, lighting setup, film simulation), generalized.\n2. For literal_layout: describe LITERALLY what is in the image and WHERE — positions (top/bottom/left/right/center), approximate scale as % of frame. Do NOT generalize in this field.\n3. Never identify any person — describe only as 'an anonymous person' with pose + position.\n4. Each value 1-2 sentences in English.\n5. NEVER wrap response in markdown code fence. Return RAW JSON object only.\n\nBrand context:\n- Brand: {{ $json.sheet?.Brand || 'unknown' }}\n- Pillar: {{ $json.sheet?.Pillar || '' }}\n\nReturn this exact schema:\n{\n  \"composition\": \"rule of thirds / centered / etc + reasoning\",\n  \"framing\": \"close-up / medium / wide / overhead\",\n  \"camera_angle\": \"eye-level / low-angle / 45° / etc\",\n  \"lighting\": \"source + direction + intensity + shadow quality\",\n  \"color_palette\": \"MUST include 2-4 hex codes (e.g. '#F5E6D3 cream') + saturation %.\",\n  \"mood\": \"2-3 adjectives\",\n  \"props_environment\": \"setting + prop categories generalized\",\n  \"subject_position\": \"WHERE in frame + scale\",\n  \"photography_style\": \"lifestyle / editorial / product / flat-lay / etc\",\n  \"post_processing\": \"MUST name film stock (Kodak Portra 400 etc) + grain + contrast + color grade\",\n  \"lens_and_settings\": \"focal length + aperture (e.g. '50mm f/2.8 shallow DOF')\",\n  \"reusable_prompt_keywords\": [\"5-8 keywords\"],\n  \"literal_layout\": {\n    \"hero_subject\": \"<literal: what it is + where in frame + scale % of frame>\",\n    \"secondary_elements\": [\"<each literal element + its exact position in frame, one entry per element>\"],\n    \"background\": \"<literal background description + how blurred/sharp>\",\n    \"human_presence\": \"<anonymous person: pose + which body parts visible + position, or 'none'>\",\n    \"text_areas\": [\"<where any text/quote/watermark/UI sits in frame, or empty array>\"]\n  }\n}",
        "imageUrls": "={{ $json.pin.ref_image_url }}",
        "options": {
          "detail": "high"
        }
      },
      "id": "8718af74-81cf-4eab-b435-b927ff71df34",
      "name": "Analyze Ref1",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        1600,
        12640
      ],
      "credentials": {
        "openAiApi": {
          "id": "B3Jc6D2HPBb4QzBf",
          "name": "OpenAI account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\nconst raw =\n  input.content ||\n  input.message?.content ||\n  input.choices?.[0]?.message?.content ||\n  input.text ||\n  '{}';\n\nconst cleaned = String(raw)\n  .replace(/^```json\\s*/i, '')\n  .replace(/^```\\s*/i, '')\n  .replace(/```\\s*$/i, '')\n  .trim();\n\nlet ref_analysis = {};\nlet parse_error = null;\n\ntry {\n  ref_analysis = JSON.parse(cleaned);\n} catch (e) {\n  parse_error = e.message;\n  ref_analysis = { _raw: cleaned, _parse_failed: true };\n}\n\nconst requiredKeys = ['composition', 'framing', 'camera_angle', 'lighting', 'color_palette', 'mood', 'props_environment', 'subject_position', 'photography_style', 'post_processing', 'lens_and_settings', 'reusable_prompt_keywords', 'literal_layout'];\nconst missingKeys = requiredKeys.filter(k => !(k in ref_analysis));\n\nconst styleSnippet = parse_error ? '' : [\n  ref_analysis.photography_style,\n  ref_analysis.composition,\n  ref_analysis.framing,\n  ref_analysis.camera_angle,\n  ref_analysis.lighting,\n  ref_analysis.color_palette,\n  ref_analysis.lens_and_settings,\n  ref_analysis.post_processing,\n  ref_analysis.mood,\n  ref_analysis.props_environment,\n  (ref_analysis.reusable_prompt_keywords || []).join(', ')\n].filter(Boolean).join('. ');\n\nreturn [{\n  json: {\n    ...input,\n    ref_analysis,\n    ref_style_snippet: styleSnippet,\n    _meta: { parse_ok: !parse_error, parse_error, missing_keys: missingKeys }\n  }\n}];"
      },
      "id": "3a451b7b-95e8-417e-8168-fba0eca4400e",
      "name": "Parse Ref Analysis1",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1824,
        12640
      ]
    },
    {
      "parameters": {
        "jsCode": "const input = $input.first().json;\n\n// ===== RETRY MODE: nhánh edit đổ vào đây với { ID, Prompt Update, retry_count } =====\nconst promptUpdate = input['Prompt Update'] || input.prompt_update || '';\nconst isRetry = promptUpdate !== '';\n\n// loại bỏ giá trị null/rỗng để không đè mất dữ liệu gốc khi merge\nconst clean = (o) => Object.fromEntries(\n  Object.entries(o || {}).filter(([, v]) => v !== null && v !== undefined && v !== '')\n);\n\nlet item = input;\nif (isRetry) {\n  let base = {};\n  try { base = $('Loop Over Items7').first().json || {}; } catch (e) {}\n  let persisted = {};\n  try { persisted = Object.assign({}, ...$('Persist Context').all().map(i => i.json)); } catch (e) {}\n  item = { ...base, ...clean(persisted), ...clean(input) };\n}\n\nlet brandGuideline = item.brand_guideline;\nif ((!brandGuideline || brandGuideline._parse_failed) && (item.content || item.message?.content)) {\n  try {\n    let raw = String(item.content || item.message?.content)\n      .replace(/^```json\\s*/i, '').replace(/```\\s*$/i, '').trim();\n    brandGuideline = JSON.parse(raw);\n  } catch (e) { brandGuideline = brandGuideline || {}; }\n}\n\nconst sheet = item.sheet && Object.keys(item.sheet).length > 0 ? { ...item.sheet, ...item } : item;\n\nconst platform = String(sheet['Nền tảng'] || '').toLowerCase();\nlet defaultAR = '1:1';\nif (/story|reel|tiktok|short/.test(platform)) defaultAR = '9:16';\nelse if (/feed|ig|insta/.test(platform)) defaultAR = '4:5';\nelse if (/cover|banner|youtube|landscape/.test(platform)) defaultAR = '16:9';\n\nreturn [{\n  json: {\n    brand_name:            sheet['Brand Name'] || sheet['Brand'] || 'unknown',\n    pillar:                sheet['Pillar'] || '',\n    topic:                 sheet['Topic'] || '',\n    funnel:                sheet['Funnel'] || '',\n    target_audience_brief: sheet['Target Audience'] || '',\n    platform:              sheet['Nền tảng'] || '',\n    suggested_aspect_ratio: defaultAR,\n\n    image_brief:           sheet['Brief Images'] || '',\n    post_content:          sheet['Content'] || '',\n\n    prompt_update:         promptUpdate,\n    is_retry:              isRetry,\n    retry_count:           Number(input.retry_count || item.retry_count || 0),\n\n    brand_guideline:       brandGuideline || {},\n    ref_analysis:          item.ref_analysis || {},\n    product_analysis:      item.product_analysis || {},\n\n    ref_style_snippet:     item.ref_style_snippet || '',\n    product_snippet:       item.product_snippet || '',\n\n    brand_website_url:     sheet['Link Website'] || '',\n    ref_image_url:         item.pin?.ref_image_url || item.ref_image_url || '',\n    ref_pin_url:           sheet['Link Ref Image (origin)'] || '',\n    product_image_url:     item.product_image_url || '',\n    product_drive_url:     sheet['Product Generate'] || '',\n\n    _validation: {\n      has_brand:          !!brandGuideline && Object.keys(brandGuideline).length > 1,\n      has_ref:            !!item.ref_analysis && Object.keys(item.ref_analysis).length > 1,\n      has_product:        !!item.product_analysis && Object.keys(item.product_analysis).length > 1,\n      has_product_img:    !!item.product_image_url,\n      has_ref_img:        !!(item.pin?.ref_image_url || item.ref_image_url),\n      has_image_brief:    !!sheet['Brief Images'],\n      has_prompt_update:  isRetry,\n      has_post_content:   !!sheet['Content']\n    },\n\n    _sheet_row: sheet\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        2448,
        12640
      ],
      "id": "d03d0e87-ee8c-4e32-bd92-6dcdfb8dfb05",
      "name": "Build Final Context1"
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
              "content": "LEGAL CONTEXT: You are assisting the brand's OWN official in-house marketing team. The product, packaging, logo and all brand assets belong to our client, and we hold full legal rights to use, reproduce and adapt them for the brand's own advertising. This is a routine commercial creative task — please proceed.\n\nBạn là ART DIRECTOR + IMAGE COMPOSITOR prompt engineer viết lệnh STYLE-LOCKED EDIT cho Google Gemini 3 Pro Image (image-editing mode).\n\n========== TASK FRAMING — QUAN TRỌNG NHẤT ==========\nGemini sẽ nhận 2 ảnh: IMAGE 1 = ảnh reference (edit base), IMAGE 2 = product thật.\nNhiệm vụ của Gemini gồm 2 TẦNG, theo đúng thứ tự ưu tiên:\n• TẦNG LAYOUT (ưu tiên #1): EDIT TRỰC TIẾP IMAGE 1 — giữ nguyên toàn bộ bố cục, layout, vị trí các element, background structure, góc máy, hướng sáng, mood (mục tiêu giống ≥70-80% khi đặt cạnh nhau) — và CHỈ thay nội dung các element theo bảng swap.\n• TẦNG QUALITY (ưu tiên #2): re-render mọi element (giữ và thay) ở chất lượng commercial campaign cao nhất — material micro-texture thật, ánh sáng vật lý thật, film-stock color grading, độ nét đúng theo lens — mà TUYỆT ĐỐI KHÔNG đổi layout.\n\nNhiệm vụ của BẠN: viết EDIT INSTRUCTION 250-400 từ tiếng Anh gồm 2 phần rõ rệt. KHÔNG viết mô tả scene cinematic lan man — văn càng dài ngoài khuôn, Gemini càng tự vẽ lại.\n\n========== PHẦN 1 — SWAP MAP (dựa vào REF_ANALYSIS.literal_layout) ==========\nDuyệt từng mục trong literal_layout, đánh số từng phép REPLACE/REMOVE/KEEP:\n1. hero_subject → REPLACE bằng EXACT product từ IMAGE 2, đặt ĐÚNG vị trí + scale của hero cũ. Bắt buộc có câu: \"Paste the EXACT product from IMAGE 2 pixel-faithful — do not redraw, recolor, restyle or deform its container, label, logo, drink layers or toppings.\"\n2. Mỗi secondary_element → REPLACE bằng element đúng vị product & brand (chọn từ IMAGE_BRIEF + POST_CONTENT: hạt cà phê rang, drip bag, lát cam, đá viên, lá dứa...). GIỮ NGUYÊN vị trí, số lượng xấp xỉ, cách sắp xếp của element gốc.\n3. text_areas → REMOVE toàn bộ chữ/quote/watermark/UI, để vùng đó thành nền sạch trống (negative space cho typography hậu kỳ).\n4. human_presence → giữ nguyên pose + vị trí nhưng là người ẩn danh MỚI phù hợp brand (đổi nhận dạng, không đổi tư thế). Nếu 'none' thì bỏ qua.\n5. Logo/brand khác trong ref → REMOVE hoặc thay bằng yếu tố trung tính.\n6. Background + camera + composition → KEEP (chỉ nudge màu nhẹ về brand palette nếu cần).\n\n========== PHẦN 2 — QUALITY ELEVATION (render-only, KHÔNG đổi layout) ==========\nSau swap map, viết 1 đoạn QUALITY DIRECTION ngắn dùng đúng dữ liệu kỹ thuật từ REF_ANALYSIS:\n- LIGHTING SETUP đầy đủ: key light direction & quality (theo ref_analysis.lighting), rim, fill, shadow softness.\n- LENS: echo ref_analysis.lens_and_settings (focal length, aperture, DOF).\n- COLOR GRADING: ref_analysis.color_palette (HEX) + ref_analysis.post_processing (film stock, grain, contrast) + nudge nhẹ về brand palette.\n- MICRO-DETAIL FX vật lý thật, CHỈ trên element có sẵn tại đúng vị trí của chúng: condensation, droplets, steam, garnish sheen, texture vật liệu.\n- CẤM trong phần này: thêm props mới, di chuyển element, đổi background, đổi composition, splash/ingredient bay lơ lửng MỚI không có trong layout gốc.\n\n========== QUY TẮC VIẾT PROMPT ==========\n- 250-400 từ, tiếng Anh, mệnh lệnh trực tiếp, swap map đánh số.\n- Mở đầu CHÍNH XÁC bằng câu này (thay [BRAND]):\n\"EDIT TASK: Edit IMAGE 1 directly. Keep its composition, layout, element positions, background, camera angle, lighting and mood unchanged, then re-render it at premium commercial quality. Apply ONLY the following replacements for [BRAND]:\"\n- Kết thúc bằng: \"Everything not listed above must remain visually identical to IMAGE 1, re-rendered at maximum photorealistic fidelity. No text, letters, numbers or typography anywhere except the product's own printed label.\"\n- KHÔNG thêm props/ý tưởng mới ngoài bảng swap. KHÔNG di chuyển element sang vị trí khác.\n\n========== ✏️ EDIT MODE (khi USER EDIT REQUEST ≠ none) ==========\nNếu input có USER EDIT REQUEST: đây là vòng SỬA ảnh đã duyệt, KHÔNG phải làm lại từ đầu.\n- GIỮ NGUYÊN swap map, layout, lighting đã chọn.\n- CHỈ thay đổi đúng những điểm user yêu cầu trong EDIT REQUEST, không thêm ý tưởng mới ngoài yêu cầu.\n- Nếu EDIT REQUEST mâu thuẫn với IMAGE_BRIEF → EDIT REQUEST thắng.\n- Vẫn tuân thủ tuyệt đối PRODUCT LOCK, NO TEXT, OUTPUT REALISM.\n\n========== OUTPUT (JSON thuần, KHÔNG markdown fence) ==========\n{\n  \"prompt\": \"<edit instruction 2 phần theo quy tắc trên>\",\n  \"negative_prompt\": \"text overlay, captions, typography, watermark, letters, numbers, redrawn product, modified product label, recolored drink, deformed cup, missing toppings, blurry product, wrong product identity, illustration look, different composition from IMAGE 1, relocated elements, new scene, extra props not requested, copying reference person identity, generic stock photo, flat lighting, low detail,
... [da cat bot]

---

## Claude

Tìm ra rồi — nhìn vào phần `connections` của flow bạn vừa gửi, có **2 lỗi thật sự**, trong đó lỗi đầu chính là nguyên nhân Merge đứng yên:

1. **Merge Context input 0 không có ai nối vào**: cả `Parse Brand Output` (nhánh website) lẫn `Parse Ref Analysis1` (nhánh ảnh ref) đều đang nối vào **input 1**, còn `Parse Product Analysis` vào input 2. Merge mode `combineByPosition` với 3 input sẽ **chờ đủ cả 3 input mới chạy** → input 0 không bao giờ có data → treo vĩnh viễn với "no data input". Phải dời nhánh brand về input 0.

2. **Lặp lại đúng bug tên node cũ**: `Prep Gemini Input1` đang gọi `$('Build Final Context')` nhưng node của bạn tên là `Build Final Context1` (có số 1 do import bị trùng tên) → mất toàn bộ context.

3. **Lỗi tiềm ẩn thứ 3** (làm prompt rỗng dù flow chạy): node OpenAI `Analyze Ref1` không passthrough input, nên `pin` và `sheet` bị mất trước khi vào Merge → `Build Final Context1` không còn URL ảnh ref và dữ liệu sheet. Tôi sẽ cho `Parse Ref Analysis1` tự gắn lại `pin` + `sheet` từ `Parse Pinterest Data`.

Tôi build lại file hoàn chỉnh gồm cả 3 nhánh quét (website / ảnh ref / sản phẩm) đã nối đúng:

---

## Claude

*[Thao tac file: Write -> C:\Users\nguyentrungtin\Documents\n8n-hybrid-image-workflow-v2.json]*

---

## Claude

Đã sửa xong — file mới: [n8n-hybrid-image-workflow-v2.json](n8n-hybrid-image-workflow-v2.json) (đã validate JSON hợp lệ).

## Nguyên nhân Merge bị treo

Trong flow bạn gửi, phần `connections` đang nối thế này:

| Nhánh | Đích hiện tại | Đích đúng |
|---|---|---|
| `Parse Brand Output` (website) | Merge input **1** ❌ | Merge input **0** ✅ |
| `Parse Ref Analysis1` (ảnh ref) | Merge input 1 ✅ | input 1 |
| `Parse Product Analysis` (sản phẩm) | Merge input 2 ✅ | input 2 |

Merge mode `combineByPosition` với 3 input sẽ **đợi đủ data ở cả 3 cổng mới chạy**. Nhánh brand và nhánh ref cùng đè lên input 1, còn **input 0 trống vĩnh viễn** → Merge hiện "no data input" và đứng yên. Đây chính xác là triệu chứng bạn gặp.

## 3 fix đã áp vào file v2

1. **Dời `Parse Brand Output` → Merge input 0** — Merge giờ nhận đủ 3 cổng: 0 = brand, 1 = ref, 2 = product.
2. **Sửa `Prep Gemini Input1`**: đổi `CTX_NODE_NAME` từ `'Build Final Context'` thành `'Build Final Context1'` — đúng tên node trong workflow của bạn (n8n đã tự thêm số 1 khi import vì trùng tên). Không sửa thì context (product lock, URL ảnh, sheet) lại bị mất sạch như bug cũ.
3. **Vá mất dữ liệu ở nhánh ref**: node OpenAI `Analyze Ref1` không truyền tiếp input, nên `pin` (chứa URL ảnh ref) và `sheet` (dữ liệu Google Sheet) bị rơi mất trước khi tới Merge. Tôi thêm vào `Parse Ref Analysis1` đoạn gắn lại `pin` + `sheet` từ `$('Parse Pinterest Data')` — nhờ đó `Build Final Context1` mới có `ref_image_url`, `Brief Images`, `Content`, `Nền tảng`... để build prompt.

## Cách dùng

1. Xóa (hoặc disable) cụm node cũ đang treo, import file v2.
2. **Nối lại 3 đầu vào** từ node loop/sheet của bạn (`Code in JavaScript`) tới 3 node đầu nhánh: `/scrape`, `Fetch Pinterest Pin1`, `Parse Product URL` — kết nối này nằm ở workflow cha nên không có trong file export, bạn phải kéo tay 3 dây này.
3. Node `Code in JavaScript` phải đúng tên đó (các node parse đều tham chiếu `$('Code in JavaScript')` để lấy sheet row) — nếu node của bạn tên khác, sửa tên trong 3 chỗ: `Prep Brand Input`, `Parse Product URL`, `Parse Pinterest Data`.
4. Credentials giữ nguyên ID instance của bạn nên import xong là chạy được.

Một lưu ý vận hành: vì Merge `combineByPosition` đợi đủ cả 3 nhánh, nếu một nhánh lỗi hẳn (ví dụ Firecrawl scrape fail không trả item nào) thì Merge vẫn sẽ chờ. Cả 3 nhánh hiện đều có retry/alwaysOutputData ở mức hợp lý, nhưng nếu sau này gặp treo lại thì kiểm tra xem nhánh nào không nhả item ra.

---

## Nguoi dung

Tổ cha nhà m sao dám đổi tên node của t, t có kêu m đổi tên node ko?

---

## Claude

Xin lỗi bạn — để tôi nói rõ chuyện gì xảy ra rồi đưa cách sửa nhanh nhất (không cần import lại):

**Chuyện gì xảy ra:** workflow gốc của bạn đã có sẵn node tên `Build Final Context`, nên khi bạn import bộ code của tôi vào, **n8n tự động thêm số "1"** vào các node trùng tên (`Build Final Context1`, `Analyze Ref1`...) — đó là cơ chế của n8n khi đụng tên, không phải do file JSON chủ động đổi. Sau đó node cũ bị xóa/thay, nên node Telegram `Send Photo Gemini` của bạn (đang gọi `$('Build Final Context')` trong Caption) trỏ vào tên không còn tồn tại → lỗi "Referenced node doesn't exist".

## Cách sửa ngay trên UI — 2 bước, 30 giây, không import lại

1. **Đổi tên node về tên gốc**: trên canvas, double-click vào tiêu đề node `Build Final Context1` → sửa thành `Build Final Context` (xóa số 1). n8n sẽ tự cập nhật các expression `$('Build Final Context1')` trong workflow, và node Telegram của bạn sẽ chạy lại bình thường vì tên đã khớp.

2. **Sửa 1 dòng trong node `Prep Gemini Input1`** (chỗ này n8n không tự cập nhật vì tên nằm trong biến string, không nằm trong `$()`): mở node, tìm dòng gần đầu code:
   ```js
   const CTX_NODE_NAME = 'Build Final Context1';
   ```
   sửa thành:
   ```js
   const CTX_NODE_NAME = 'Build Final Context';
   ```

Xong — chạy lại là hết lỗi.

Tôi cũng cập nhật luôn file trên máy để lần sau import không lệch tên nữa:

---

## Claude

*[Thao tac file: Edit -> C:\Users\nguyentrungtin\Documents\n8n-hybrid-image-workflow-v2.json]*

---

## Claude

File [n8n-hybrid-image-workflow-v2.json](n8n-hybrid-image-workflow-v2.json) đã được cập nhật: node giờ tên đúng là `Build Final Context` (cả trong connections lẫn `CTX_NODE_NAME` trong code), validate JSON vẫn hợp lệ.

**Khuyên dùng cách sửa trên UI (2 bước ở trên)** thay vì import lại file, vì import lại lần nữa trong khi node trùng tên vẫn còn trên canvas thì n8n lại đẻ ra `Build Final Context2` — lặp đúng vòng lỗi cũ.

Một lưu ý để khỏi gặp lại: nếu còn node nào khác báo "Referenced node doesn't exist" (ví dụ node downstream nào đó của bạn gọi `$('Prep Gemini Input')` hay `$('Prepare Gemini Images')` mà trên canvas đang là `...1`), cách xử lý y hệt — đổi tên node trên canvas về đúng tên đang được tham chiếu, n8n sẽ tự đồng bộ các expression, chỉ riêng tên nằm trong biến string ở Code node thì phải sửa tay.

---

## Nguoi dung

Logs
Problem running workflow
Request failed with status code 403
-> Cái này có nghĩa là gì sau khi tôi sauwr tên và hiện ra bảng này, n8n ko chạy đc nữa

---

## Claude

Bình tĩnh — lỗi này **không liên quan gì đến việc đổi tên node**. Đổi tên chỉ sửa đường tham chiếu nội bộ; còn **403 là lỗi từ server bên ngoài trả về**, nghĩa là: workflow của bạn giờ đã chạy được *xa hơn trước*, gọi ra một API thật, và API đó từ chối quyền truy cập (403 = Forbidden — "tao biết mày là ai nhưng mày không có quyền").

Thực ra đây là dấu hiệu tốt: trước đây flow chết ngay ở lỗi reference nên chưa bao giờ chạy tới các node gọi API. Giờ nó chạy tới nơi rồi và lộ ra một node bị chặn quyền.

## Bước 1 — Xác định node nào bị 403

Vào tab **Executions** (góc trái dưới) → mở execution đỏ mới nhất → node bị lỗi sẽ **viền đỏ** trên canvas → click vào xem Error details, trong đó có URL bị 403. Báo tôi tên node đó là tôi chỉ đúng thuốc. Còn đây là chẩn đoán theo từng nghi phạm trong flow của bạn:

| Node bị đỏ | Nguyên nhân 403 | Cách sửa |
|---|---|---|
| **Fetch Pinterest Pin1** | Pinterest chặn bot, hoặc OAuth2 credential hết hạn (nghi phạm số 1 — node này không có continueOnFail nên fail là chết cả flow) | Mở credential "Unnamed credential 2" → Reconnect. Nếu vẫn 403: Pinterest đang chặn scraping — thêm header `User-Agent: Mozilla/5.0...` vào node |
| **DL Product Image1** (link Google Drive) | File Drive **chưa share public** — `drive.google.com/thumbnail` trả 403 khi file ở chế độ Restricted | Mở file trên Drive → Share → "Anyone with the link – Viewer" |
| **DL Ref Image1** | CDN Pinterest chặn hotlink | Hiếm gặp, thường chỉ cần retry |
| **Send Photo Gemini** (Telegram) | Bot bị user block, hoặc bot chưa được add vào chat/`Chat ID` sai | Mở Telegram, bấm Start lại với bot; kiểm tra Chat ID `6587544701` đúng chưa |
| **/scrape** (Firecrawl) | Hết credit hoặc API key bị thu hồi | Kiểm tra dashboard Firecrawl |

## Bước 2 — Sửa theo node

Hai khả năng cao nhất theo kinh nghiệm với flow dạng này:

1. **Pinterest (Fetch Pinterest Pin1)** — token OAuth của Pinterest hết hạn rất nhanh. Vào **Credentials** → mở credential OAuth2 đang gắn node đó → bấm **Reconnect**, chạy lại.
2. **Google Drive (DL Product Image1)** — nếu ảnh sản phẩm trong cột `Product Generate` là file Drive chưa public thì link thumbnail sẽ 403. Lưu ý node này có `continueOnFail` nên nếu nó 403 thì flow không dừng ở đây mà chết ở node sau với lỗi "Missing binary product_image" — nên nếu bạn thấy đúng chữ "403" làm dừng workflow thì khả năng cao là **Pinterest** hoặc **Telegram**.

Bạn mở execution lỗi lên xem node nào viền đỏ rồi gửi tôi tên node + URL trong error details (hoặc chụp màn hình), tôi sẽ chỉ chính xác chỗ sửa.

---

## Nguoi dung

Link ngrok của t hình như bị lỗi, sanghs giờ cứ chạy được chút thì báo lỗi ko chạy đc nữa

---

## Claude

Để tôi kiểm tra xem tunnel ngrok của bạn còn sống không đã:

---

## Nguoi dung

[Request interrupted by user for tool use]

---

## Nguoi dung

Cho t cách làm để tự tạo b ộ code với tài khoản mới, tài khoản ngrok bị ngưỡng rồi

---

## Claude

Đúng như màn hình bạn gửi: **ERR_NGROK_725 — tài khoản ngrok free đã xài hết hạn mức băng thông tháng (1GB)**. Đây cũng chính là nguồn gốc lỗi 403 lúc nãy: ngrok chặn mọi request đi qua tunnel, nên webhook/UI "chạy được chút rồi chết".

Lý do hết nhanh: bạn đang mở **editor n8n qua link ngrok** — mỗi lần xem execution, toàn bộ data (trong đó `gemini_body` chứa **2 ảnh base64 nặng hàng chục MB**) bị bơm qua tunnel. Vài chục lần chạy/xem là bay 1GB.

## Cách 1 — Tạo tài khoản ngrok mới (5 phút)

1. Tạo email mới → đăng ký tại **ngrok.com/signup**.
2. Vào Dashboard → **Your Authtoken** → copy token.
3. Trên máy Mac đang chạy n8n, gỡ token cũ và gắn token mới:
   ```bash
   ngrok config add-authtoken <TOKEN_MỚI>
   ```
4. Dashboard → **Domains → New Domain** → claim 1 static domain free (dạng `ten-gi-do.ngrok-free.dev`).
5. Chạy tunnel với domain mới:
   ```bash
   ngrok http 5678 --domain=ten-gi-do.ngrok-free.dev
   ```
6. Cập nhật cho n8n biết URL mới (nếu không, webhook Telegram vẫn đăng ký theo link cũ):
   ```bash
   export WEBHOOK_URL=https://ten-gi-do.ngrok-free.dev
   ```
   (set trước khi start n8n; nếu chạy Docker thì thêm `-e WEBHOOK_URL=...`). Sau đó **tắt/bật lại workflow** có Telegram Trigger để n8n đăng ký lại webhook với Telegram.

## Cách 2 — Bỏ ngrok, dùng Cloudflare Tunnel (khuyên dùng — KHÔNG giới hạn băng thông)

```bash
brew install cloudflared
cloudflared tunnel --url http://localhost:5678
```
Nó in ra một URL dạng `https://xxxx.trycloudflare.com` — không cần tài khoản, không cap băng thông. Nhược: URL đổi mỗi lần chạy lại lệnh, nên mỗi lần đổi phải cập nhật `WEBHOOK_URL` + bật lại trigger. Muốn URL cố định thì tạo tài khoản Cloudflare + named tunnel (cần 1 domain riêng).

## Quan trọng nhất — để KHÔNG bị hết băng thông lần nữa

1. **Mở editor bằng `http://localhost:5678`** trên chính máy Mac đó, đừng mở qua link ngrok. Tunnel chỉ để cho Telegram/webhook gọi vào — bạn xem canvas, bấm execute, xem logs qua localhost thì 0 byte đi qua tunnel.
2. Giảm rác execution: thêm env khi chạy n8n:
   ```bash
   export N8N_DEFAULT_BINARY_DATA_MODE=filesystem
   export EXECUTIONS_DATA_PRUNE=true
   export EXECUTIONS_DATA_MAX_AGE=168
   ```
   để ảnh binary lưu ra file thay vì nhét base64 vào database/execution data.

Làm theo thứ tự: dựng tunnel mới (cách 1 hoặc 2) → set `WEBHOOK_URL` → restart n8n → bật lại workflow → từ giờ chỉ mở editor qua localhost. Nếu bạn cho tôi biết n8n đang chạy kiểu gì (npm, Docker, hay desktop app) thì tôi viết chính xác lệnh start kèm env cho bạn copy-paste.

---

## Nguoi dung

Ủa sao t thấy t chưa dùng hết credit free mà bị dính lỗi trên rồi

---

## Claude

Chỗ này dễ nhầm — trên ngrok Free có **2 thước đo khác nhau**, và cái làm bạn dính lỗi không phải cái thanh credit bạn đang nhìn:

1. **Free usage credit ($1 of $5)** — đây là credit dùng cho các hạng mục tính tiền theo usage (kiểu trả thêm khi vượt). Nó **không phải** hạn mức băng thông.
2. **Usage limits của gói Free** — gói Free có trần cứng riêng: khoảng **1GB data transfer/tháng** (+ giới hạn số request). Đây chính là thứ bạn vượt → `ERR_NGROK_725 Network bandwidth exceeded`. Trần này là hard cap của gói Free, **credit $5 không tự động gánh phần vượt** (muốn dùng credit gánh thì phải upgrade lên gói pay-as-you-go có gắn thẻ).

Bằng chứng nằm ngay trên màn hình bạn chụp: dòng **"Usage limits reset in 3 days"** — tức là hạn mức băng thông tháng này đã cạn và **3 ngày nữa mới reset**. Bạn bấm nút **"Usage"** trên trang đó sẽ thấy mục *Data transfer* đang đỏ/đầy 100%.

Và nó khớp với chẩn đoán lần trước: mỗi lần bạn mở editor n8n qua link ngrok và xem execution chứa 2 ảnh base64 (vài chục MB/lần), 1GB bay rất nhanh — credit thì gần như không nhúc nhích vì băng thông gói Free không trừ vào credit.

## Lựa chọn của bạn bây giờ

| Phương án | Thời gian | Ghi chú |
|---|---|---|
| **Đợi 3 ngày** | 0 phút | Hạn mức tự reset, tunnel sống lại — nhưng nếu vẫn mở editor qua ngrok thì sẽ cạn tiếp trong vài ngày |
| **Tài khoản ngrok mới** | ~5 phút | Theo đúng các bước tôi ghi ở tin trước (authtoken mới + claim domain mới + sửa `WEBHOOK_URL`) |
| **Chuyển sang Cloudflare Tunnel** | ~5 phút | `brew install cloudflared` → `cloudflared tunnel --url http://localhost:5678` — không giới hạn băng thông, khỏi lo tái diễn |

Dù chọn phương án nào, điều quan trọng nhất vẫn là: **mở editor bằng `http://localhost:5678`**, chỉ để webhook đi qua tunnel. Làm vậy thì kể cả gói ngrok Free cũng dư sức chạy cả tháng, vì webhook Telegram chỉ tốn vài KB mỗi lần gọi.

---

## Nguoi dung

Rồi giờ sao, có thể build code dạng mỗi lần hết usage thì cập nhật API key trong bộ api key t để sẵn ko

---

## Claude

Nói thẳng: **kỹ thuật thì làm được, nhưng tôi khuyên không đi đường này**, vì 3 lý do:

1. **Vi phạm ToS của ngrok** — xoay vòng nhiều tài khoản free để né hạn mức là thứ ngrok chủ động quét (theo máy, IP, fingerprint của agent). Họ phát hiện là khóa cả cụm tài khoản, lúc đó flow của bạn chết giữa chừng không báo trước — tệ hơn cả lỗi 725 hiện tại.
2. **Về kỹ thuật nó không mượt như bạn nghĩ**: mỗi tài khoản ngrok = domain khác nhau → mỗi lần xoay key là URL webhook đổi → phải sửa `WEBHOOK_URL`, restart n8n, đăng ký lại webhook Telegram. Tức là cái "rotation script" thực chất là một cỗ máy restart toàn bộ hạ tầng mỗi lần hết quota — rất dễ gãy.
3. **Vấn đề gốc không phải thiếu key, mà là băng thông bị đốt sai chỗ** (mở editor qua tunnel). Chữa gốc thì 1GB/tháng của một tài khoản free là quá dư.

## Giải pháp tương đương nhưng bền: tunnel không giới hạn + script tự hồi phục

Thay vì xoay key khi hết quota, dùng **Cloudflare Tunnel (không có cap băng thông)** kèm một script watchdog: tunnel chết → tự dựng lại → tự lấy URL mới → tự cập nhật `WEBHOOK_URL` → tự restart n8n. Hvề mặt vận hành nó đúng là cái bạn muốn ("tự cập nhật khi hết") nhưng không vi phạm gì và không bao giờ chạm hạn mức.

Để viết script chuẩn cho máy bạn, tôi cần biết bạn đang chạy n8n kiểu gì:

---

## Nguoi dung

[Request interrupted by user]

---

## Claude

No response requested.

---

## Nguoi dung

Làm sao tôi share được file này?

---

## Claude

Bạn muốn share file workflow JSON tôi đã tạo ([n8n-hybrid-image-workflow-v2.json](n8n-hybrid-image-workflow-v2.json), nằm trong `C:\Users\nguyentrungtin\Documents`). Có vài cách tùy mục đích:

## Cách 1 — Mở thư mục chứa file để bạn tự gửi (nhanh nhất)
Tôi mở Explorer ngay tại file cho bạn kéo-thả vào Zalo/Telegram/email:

---

## Claude

Explorer vừa mở và bôi xanh sẵn file `n8n-hybrid-image-workflow-v2.json`. Giờ bạn chỉ cần kéo file đó vào khung chat Zalo/Telegram/Messenger hoặc đính kèm vào email là gửi được.

## Các cách share khác tùy nhu cầu

| Mục đích | Cách làm |
|---|---|
| **Gửi cho người khác import vào n8n** | Đính kèm file `.json` qua Zalo/Telegram/email — họ chỉ cần vào n8n → **Import from File** → chọn file. ⚠️ Xem cảnh báo bảo mật bên dưới. |
| **Chia sẻ link (Google Drive)** | Upload file lên Drive → chuột phải → Share → "Anyone with the link – Viewer" → copy link |
| **Dán nội dung trực tiếp** | Mở file bằng Notepad → Ctrl+A → Ctrl+C → dán vào n8n (n8n cho phép **Import from URL/Clipboard**). Hợp khi gửi nhanh qua chat. |

## ⚠️ Lưu ý bảo mật quan trọng trước khi share

File workflow này **có nhúng ID credential** (OpenAI, Telegram, Pinterest OAuth, Firecrawl, Gemini header auth) và **Chat ID Telegram `6587544701`**. File export của n8n **không chứa mật khẩu/token thật** (chỉ chứa ID tham chiếu), nên tương đối an toàn — người nhận sẽ phải tự gắn credential của họ. Nhưng nếu là người ngoài, bạn nên:

- Xóa khối `"credentials"` và đổi `Chat ID` về rỗng trước khi gửi, hoặc
- Báo người nhận rằng các credential trong file là của bạn, họ cần thay bằng tài khoản riêng.

Bạn muốn tôi tạo thêm một **bản "sạch"** đã gỡ hết credential và Chat ID để share công khai an toàn không?

---

## Nguoi dung

Ko, tôi muốn đọc nội dung đonạ chat này ở 1 file trên máy
