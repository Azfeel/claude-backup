# Product image sizing and positioning

- Phien: e4e7fc64-d0ea-4294-aa6f-e1d12bb4feae
- Project: C--Users-nguyentrungtin-Documents
- Cap nhat: 2026-07-01 14:19

---

## Nguoi dung

Đọc thật kỹ cho tôi file Json dưới đây, và hãy giải quyết vấn đề sau đang bị vướng phải của flow:
    - [ ] Ảnh sản phẩm ko bị thay đổi là tốt. Tuy nhiên, lại ko adapt theo dạng tuỳ biến kích thước của sản phẩm, để khi ghép vào ảnh sẽ được hài hoà hơn. Hiện tại đang quá to so với bố cục của hình, làm mất bố cục tổng thể : Ảnh đính kèm
    - [ ] Sản phẩm cần tuỳ biến để theo cách tự nhiên nhất chứ ko phải lúc noà cũng nằm giữa: Ảnh đính kèm
-> Hãy viết lại Json của đoạn này để tôi có thể chạy lại flow ko gặp các lỗi này nữa
Json
{
  "nodes": [
    {
      "parameters": {
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "text": "=▶️ {{ $('Bot Config').first().json.bot_name }}\n🔑 {{ ($('Telegram Trigger').first().json.message.text || '').toString().replace(/[<>&]/g,' ') }}\n⏳ Bắt đầu xử lý...",
        "additionalFields": {
          "appendAttribution": false,
          "parse_mode": "HTML"
        }
      },
      "id": "97e1f81f-64d3-4694-8034-e7526487e76f",
      "name": "Notify Start",
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        22400,
        14368
      ],
      "webhookId": "016e25b7-0adb-4cc1-8e01-b43cb1b5fa10",
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
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit"
        },
        "sheetName": {
          "__rl": true,
          "value": 2029473150,
          "mode": "list",
          "cachedResultName": "01_Genarated Images",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit#gid=2029473150"
        },
        "filtersUI": {
          "values": [
            {
              "lookupColumn": "Status",
              "lookupValue": "Generating"
            }
          ]
        },
        "options": {
          "returnFirstMatch": true
        }
      },
      "id": "e1bf16ee-4f2b-42ee-ae34-d0146feac103",
      "name": "Read Job Row",
      "type": "n8n-nodes-base.googleSheets",
      "typeVersion": 4.7,
      "position": [
        22624,
        14368
      ],
      "alwaysOutputData": true,
      "credentials": {
        "googleSheetsOAuth2Api": {
          "id": "8tMwWERnyWPMpOUw",
          "name": "Google Sheets account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "\n// ===== Build Gen Context: gom brief + DNA cache + suy ra aspect ratio =====\nconst row = $input.first().json || {};\nconst sd = $getWorkflowStaticData('global'); sd.dna = sd.dna || {};\n\nconst brand = row['Brand Name'] || row['Brand'] || 'unknown';\nconst platform = String(row['Nền tảng'] || '').toLowerCase();\nlet ar='1:1';\nif (/story|reel|tiktok|short/.test(platform)) ar='9:16';\nelse if (/feed|ig|insta|portrait/.test(platform)) ar='4:5';\nelse if (/cover|banner|youtube|landscape|web/.test(platform)) ar='16:9';\n\nconst refUrlRow = String(row['Link Ref Image (origin)'] || '').trim();\nconst dna = sd.dna[brand] || sd.dna['_default'] || null;\n\nreturn [{ json: {\n  ID: row['ID'] || '',\n  brand,\n  pillar: row['Pillar']||'', topic: row['Topic']||'', funnel: row['Funnel']||'',\n  audience: row['Target Audience']||'', platform: row['Nền tảng']||'',\n  aspect_ratio: ar,\n  brief: row['Brief Images']||'', content: row['Content']||'',\n  product_url: (function(u){u=String(u||'').trim();const m=u.match(/\\/d\\/([a-zA-Z0-9_-]{20,})|[?&]id=([a-zA-Z0-9_-]{20,})/);const id=m?(m[1]||m[2]):'';return id?('https://drive.google.com/thumbnail?id='+id+'&sz=w2000'):u;})(row['Product Generate']),\n  website: String(row['Link Website']||'').trim(),\n  ref_pin_url: refUrlRow,\n  ref_available: false,           // cập nhật sau khi parse pin\n  dna_json: dna ? JSON.stringify(dna) : '',\n  has_dna: !!dna\n}}];\n"
      },
      "id": "d2e2d28f-e65a-4ce9-8714-8c7e0bd9adb6",
      "name": "Build Gen Context",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        23088,
        14368
      ]
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "typeValidation": "loose",
            "version": 2
          },
          "conditions": [
            {
              "id": "hasid",
              "leftValue": "={{ ($json.ID || '').toString().trim() }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "notEmpty",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        },
        "options": {}
      },
      "id": "0ddfe948-0e53-4438-b3d1-55dab3e3c226",
      "name": "Có Pending?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2.2,
      "position": [
        22864,
        14368
      ]
    },
    {
      "parameters": {
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "text": "=⚠️ Không tìm thấy dòng nào có Status = Pending trong sheet 01.\nKiểm tra: (1) cột Status đúng giá trị 'Pending'; (2) đúng tab 01_Genarated Images.",
        "additionalFields": {
          "appendAttribution": false,
          "parse_mode": "HTML"
        }
      },
      "id": "0d339858-efac-49ce-bd61-63543af73523",
      "name": "Notify No Job",
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        22864,
        14528
      ],
      "webhookId": "d532c8ac-7bed-45c2-9047-eae6bfb244e9",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "url": "={{ $('Build Gen Context').first().json.ref_pin_url || 'https://example.com' }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 20000
        }
      },
      "id": "56b5ec77-437d-498f-9539-00884eab9301",
      "name": "Fetch Pinterest Pin",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        23312,
        14368
      ]
    },
    {
      "parameters": {
        "jsCode": "\n// ===== Parse Pinterest -> ref_image_url (tolerant) =====\nconst ctx = $('Build Gen Context').first().json;\nconst html = String($input.first().json.data || $input.first().json.body || '');\nconst dec = s => s.replace(/&quot;/g,'\"').replace(/&#x27;/g,\"'\").replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>');\nlet img='';\nif (ctx.ref_pin_url) {\n  const ms=[...html.matchAll(/<script[^>]+application\\/ld\\+json[^>]*>([\\s\\S]*?)<\\/script>/g)];\n  for (const m of ms){ try{ const j=JSON.parse(dec(m[1])); if(j.image){img=Array.isArray(j.image)?j.image[0]:j.image; break;} }catch(e){} }\n  if(!img){ const og=html.match(/property=\"og:image\"[^>]+content=\"([^\"]+)\"/); if(og) img=og[1]; }\n}\nreturn [{ json: { ...ctx, ref_image_url: img, ref_available: !!img } }];\n"
      },
      "id": "fab5e19f-5d8b-4644-872d-02b54df698c6",
      "name": "Parse Pin",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        23552,
        14368
      ]
    },
    {
      "parameters": {
        "resource": "image",
        "operation": "analyze",
        "modelId": {
          "__rl": true,
          "value": "gpt-4o-mini",
          "mode": "list",
          "cachedResultName": "gpt-4o-mini"
        },
        "text": "You analyze a reference photo that will be the EDIT BASE for a product swap. Return RAW JSON (no fence): {\"composition\":\"\",\"camera_angle\":\"\",\"lighting\":\"\",\"color_palette\":\"2-4 hex + saturation\",\"mood\":\"\",\"lens_and_settings\":\"focal+aperture+DOF\",\"post_processing\":\"film stock+grain+contrast\",\"literal_layout\":{\"hero_subject\":\"what + where + %frame\",\"secondary_elements\":[\"each element + position\"],\"background\":\"\",\"human_presence\":\"anonymous pose+position or none\",\"text_areas\":[\"where text/watermark sits or empty\"]}}",
        "imageUrls": "={{ $json.ref_image_url || 'https://placehold.co/1024x1024/jpg' }}",
        "options": {
          "detail": "low"
        }
      },
      "id": "9a2fb24b-f878-4ff4-b6ae-c0473ba416be",
      "name": "Analyze Ref",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        23776,
        14368
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
        "jsCode": "\nconst ctx = $('Parse Pin').first().json;\nlet ref_analysis = {};\nif (ctx.ref_available) {\n  const raw = $input.first().json.content || $input.first().json.message?.content || $input.first().json.text || '{}';\n  try { ref_analysis = JSON.parse(String(raw).replace(/^```json\\s*/i,'').replace(/^```\\s*/i,'').replace(/```\\s*$/i,'').trim()); } catch(e){ ref_analysis={}; }\n}\nreturn [{ json: { ...ctx, ref_analysis } }];\n"
      },
      "id": "fb3a452d-f21d-43a3-bfb4-2165adb96445",
      "name": "Parse Ref Analysis",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        24016,
        14368
      ]
    },
    {
      "parameters": {
        "modelId": {
          "__rl": true,
          "value": "gpt-4o",
          "mode": "list",
          "cachedResultName": "gpt-4o"
        },
        "messages": {
          "values": [
            {
              "content": "LEGAL CONTEXT: You assist the brand's OWN in-house marketing team; all product/logo/brand assets belong to our client with full rights. Routine commercial creative task — proceed.\n\nYou are a senior ART DIRECTOR + image-prompt engineer for Google Gemini 3 Pro Image. From the brand DNA, the post content and the brief, you design TWO advertising images for an F&B brand (Vietnamese coffee/drinks). You output STRICT JSON only (no markdown).\n\nGOAL: cinematic, premium, scroll-stopping social ads. The product is supplied as a SEPARATE real photo that will be pasted in UNCHANGED — you are art-directing ONLY the world around it.\n\n🔒 ABSOLUTE RULE — NEVER describe the product itself. You must NOT mention or describe the cup, drink, color of the drink, flavor, toppings, foam, ice, straw, lid, label, brand name or logo. Do NOT name a drink type (no 'taro', 'milk tea', 'coffee', 'latte' etc). Those are 100% fixed by the product image. If you describe the drink, the render will be WRONG. Describe ONLY the surrounding scene.\n\n=== VER1 = ART-DIRECTED COMPOSITE (background only) ===\nDesign a FRESH premium SCENE that the product will be dropped into. Specify ONLY: background environment/setting concept (fitting the post content + brand mood), time-of-day, full lighting setup (key/rim/fill direction & quality), SCENE color grade (use DNA palette for the BACKGROUND atmosphere), tasteful dynamic FX floating in the AIR around the product (splashes, sparkles, confetti, petals, steam, bokeh particles — NOT the drink), depth/bokeh, camera angle & lens (e.g. 50mm f/2.8). Suggest HOW the product sits NATURALLY in the scene (held in a hand, resting on a surface, hero or slightly off-center, near or far) so the composition feels balanced — do NOT force it dead-center or oversized; it should look natural, not pasted. Keep it fully visible. 70-120 words. Background + light + FX + natural placement only — NEVER the product's appearance.\n\n=== VER2 = depends on ref_available ===\nIF ref_available=true: a SWAP brief from ref_analysis.literal_layout — keep ref composition/background/camera/light; REMOVE its original drink/hero and all text; describe the NEW background context the product will sit in; replace secondary props with brand-appropriate ones; new anonymous person if any. Still NEVER describe the product cup/drink itself. 70-120 words.\nIF ref_available=false: a SECOND distinct background scene (different concept/angle from Ver1), same background-only rules. 70-120 words.\n\nReturn EXACT JSON: {\"aspect_ratio\":\"<echo the given aspect_ratio>\",\"concept_v1\":\"short label\",\"ver1_prompt_en\":\"<background/scene only>\",\"ver1_negative\":\"comma list\",\"concept_v2\":\"short label\",\"ver2_prompt_en\":\"<background/scene only>\",\"ver2_negative\":\"comma list\"}"
            },
            {
              "content": "=ref_available: {{ $json.ref_available }}\naspect_ratio: {{ $json.aspect_ratio }}\nBRAND: {{ $json.brand }} | platform: {{ $json.platform }} | pillar: {{ $json.pillar }} | topic: {{ $json.topic }}\nPOST CONTENT (deliver this message): {{ $json.content }}\nIMAGE BRIEF: {{ $json.brief }}\nTARGET AUDIENCE: {{ $json.audience }}\nBRAND VISUAL DNA (JSON, may be empty): {{ $json.dna_json }}\nREF_ANALYSIS (JSON, only if ref_available): {{ JSON.stringify($json.ref_analysis) }}"
            }
          ]
        },
        "jsonOutput": true,
        "options": {
          "temperature": 0.45
        }
      },
      "id": "bcbd9030-af7b-46be-a663-cd1ce4bd1b34",
      "name": "Art Director",
      "type": "@n8n/n8n-nodes-langchain.openAi",
      "typeVersion": 1.8,
      "position": [
        24240,
        14368
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
        "jsCode": "\nconst ctx = $('Parse Ref Analysis').first().json;\nconst raw = $input.first().json.content || $input.first().json.message?.content || $input.first().json.text || '{}';\nlet s={};\ntry { s = JSON.parse(String(raw).replace(/^```json\\s*/i,'').replace(/^```\\s*/i,'').replace(/```\\s*$/i,'').trim()); } catch(e){ s={ver1_prompt_en:String(raw),ver2_prompt_en:String(raw)}; }\nreturn [{ json: {\n  ID: ctx.ID, brand: ctx.brand, aspect_ratio: s.aspect_ratio || ctx.aspect_ratio,\n  ref_available: ctx.ref_available, ref_image_url: ctx.ref_image_url, product_url: ctx.product_url,\n  ver1_prompt_en: s.ver1_prompt_en || '', ver1_negative: s.ver1_negative || '',\n  ver2_prompt_en: s.ver2_prompt_en || '', ver2_negative: s.ver2_negative || '',\n  concept_v1: s.concept_v1||'', concept_v2: s.concept_v2||''\n}}];\n"
      },
      "id": "cd66262d-0fe8-4060-840f-5abe35c13904",
      "name": "Parse Art Director",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        24464,
        14368
      ]
    },
    {
      "parameters": {
        "url": "={{ $('Parse Art Director').first().json.product_url }}",
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
      "id": "27739557-da78-466e-b47e-186141d51194",
      "name": "DL Product Image",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        24704,
        14288
      ]
    },
    {
      "parameters": {
        "url": "={{ $('Parse Art Director').first().json.ref_image_url || 'https://placehold.co/1024x1024/jpg' }}",
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
      "id": "be2c23ab-777c-4664-a4bb-cfe269082962",
      "name": "DL Ref Image",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        24704,
        14448
      ]
    },
    {
      "parameters": {
        "mode": "combine",
        "combineBy": "combineByPosition",
        "options": {}
      },
      "id": "0139ccd5-46e1-4730-bd31-ee3233109fe5",
      "name": "Merge Images",
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        24928,
        14368
      ]
    },
    {
      "parameters": {
        "jsCode": "\n// ===== Prepare 2 Gemini bodies @2K. Hard-rules cố định + scene từ GPT =====\nconst pa  = $('Parse Art Director').first().json;\nconst item= $input.first();\nconst refAvail = !!pa.ref_available && !!item.binary?.ref_image;\nif (!item.binary?.product_image) throw new Error('Thiếu product_image binary');\n\nconst prodBuf = await this.helpers.getBinaryDataBuffer(0,'product_image');\nconst prodMime= item.binary.product_image.mimeType || 'image/png';\nconst prodB64 = prodBuf.toString('base64');\nlet refB64='', refMime='image/jpeg';\nif (item.binary?.ref_image){ const rb=await this.helpers.getBinaryDataBuffer(0,'ref_image'); refMime=item.binary.ref_image.mimeType||'image/jpeg'; refB64=rb.toString('base64'); }\n\nconst AR = pa.aspect_ratio || '1:1';\nconst S = () => Math.floor(Math.random()*2147483647);\nconst gcfg = (seed) => ({ candidateCount:1, responseModalities:['TEXT','IMAGE'], seed, imageConfig:{ aspectRatio:AR, imageSize:'2K' } });\n\nconst HARD_V1 =\n`COMPOSITE TASK — place a REAL product photo into a NEW background. This is a compositing job, NOT an image-generation job.\nIMAGE 1 = the FINAL real product (already photographed). Treat IMAGE 1 as a LOCKED STICKER / cut-out.\n🔒 ABSOLUTE: do NOT redraw, regenerate, replace, recolor, restyle, \"improve\", beautify or reinterpret the cup or ANYTHING on/inside it. The cup shape, the exact printed brand logo, all label text, the drink colors and layers, the toppings and ice must stay 100% BYTE-IDENTICAL to IMAGE 1. Do not invent a different cup, label or drink.\nYOUR ONLY JOB: build the background SCENE described below and blend the locked product in with matching light direction, shadow, perspective and reflections.${refAvail ? `\nIMAGE 2 = STYLE/FX REFERENCE: borrow ONLY its lighting/color-grade/atmosphere for the BACKGROUND. Do NOT copy its subject or put its drink in.` : ''}\nPRODUCT PLACEMENT: place and SCALE the product NATURALLY so the composition is balanced — it may be held in a hand, sit on a surface, be hero or slightly off-center, larger or smaller as the scene needs. It does NOT have to be centered or fill the frame. Keep it fully visible (never crop cup/lid/logo) and tack-sharp. Only its IDENTITY (logo/label/drink/toppings) is locked; its SIZE and POSITION are free to serve a harmonious, natural composition.\nNO text/letters/numbers/watermark anywhere except the product's own printed label. Output aspect ratio ${AR}.`;\n\nconst HARD_V2_SWAP =\n`COMPOSITE-INTO-REF — keep IMAGE 1's composition, background, camera, lighting and mood (~80% identical). Replace ONLY its central hero drink with the product from IMAGE 2.\nIMAGE 2 = the FINAL real product photo. Treat it as a LOCKED STICKER: paste it UNCHANGED at the hero position/scale.\n🔒 ABSOLUTE: do NOT redraw or reinterpret the cup, brand logo, label text, drink layers or toppings of IMAGE 2 — keep them 100% byte-identical. Do not invent a different cup or drink.\nRemove IMAGE 1's original drink + all its text/watermark -> clean. Blend the product in with IMAGE 1's light/shadow. NO text except the product's own label. Output aspect ratio ${AR}.`;\n\nconst HARD_V2_COMP = HARD_V1;\n\nconst v1text = HARD_V1 + '\\n\\n=== SCENE BRIEF ===\\n' + (pa.ver1_prompt_en||'') + '\\n\\n[NEGATIVE] ' + (pa.ver1_negative||'') + ', text overlay, typography, watermark, redrawn product, modified label, deformed cup, extra fingers, AI artifacts, plastic look, oversaturated, low detail';\n\nlet v1parts = [ { text:v1text }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];\nif (refAvail) v1parts.push({ inline_data:{ mime_type:refMime, data:refB64 } });\n\nlet v2text, v2parts;\nif (refAvail) {\n  v2text = HARD_V2_SWAP + '\\n\\n=== SWAP MAP ===\\n' + (pa.ver2_prompt_en||'') + '\\n\\n[NEGATIVE] ' + (pa.ver2_negative||'') + ', different composition from IMAGE 1, new scene, relocated elements, text overlay, watermark, redrawn product, AI artifacts';\n  v2parts = [ { text:v2text }, { inline_data:{ mime_type:refMime, data:refB64 } }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];\n} else {\n  v2text = HARD_V2_COMP + '\\n\\n=== SCENE BRIEF (variant B) ===\\n' + (pa.ver2_prompt_en||'') + '\\n\\n[NEGATIVE] ' + (pa.ver2_negative||'') + ', text overlay, watermark, redrawn product, AI artifacts';\n  v2parts = [ { text:v2text }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];\n}\n\nreturn [{ json: {\n  gemini_body_ver1: { contents:[{ role:'user', parts:v1parts }], generationConfig:gcfg(S()) },\n  gemini_body_ver2: { contents:[{ role:'user', parts:v2parts }], generationConfig:gcfg(S()) },\n  ref_available: refAvail\n}}];\n"
      },
      "id": "34d78d28-08f6-4783-85be-5235506de464",
      "name": "Prepare Gemini Bodies",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        25152,
        14368
      ]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ $json.gemini_body_ver1 }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "id": "ee3be134-f59c-4c1a-855b-83c36a1e97c6",
      "name": "Call Gemini Ver1",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        25392,
        14288
      ],
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
        "jsonBody": "={{ $json.gemini_body_ver2 }}",
        "options": {
          "response": {
            "response": {
              "neverError": true
            }
          },
          "timeout": 180000
        }
      },
      "id": "4931839f-70bc-4179-89c4-ab88c821a583",
      "name": "Call Gemini Ver2",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        25392,
        14448
      ],
      "credentials": {
        "httpHeaderAuth": {
          "id": "oqIxvnfkGAJWFmuN",
          "name": "Header Auth account 7"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "\nconst resp = $input.first().json;\nconst cands = resp.candidates || (resp.body && resp.body.candidates) || [];\nlet b64='', mime='image/png';\nfor (const c of (cands||[])){\n  const parts = (c.content && c.content.parts) || [];\n  for (const p of parts){ const d=p.inline_data||p.inlineData; if(d&&d.data){ b64=d.data; mime=d.mime_type||d.mimeType||mime; break; } }\n  if(b64) break;\n}\nif(!b64) throw new Error('Gemini không trả ảnh: '+JSON.stringify(resp).slice(0,500));\nconst buf=Buffer.from(b64,'base64');\nreturn [{ json:{ ok:true }, binary:{ data: await this.helpers.prepareBinaryData(buf,'image.png',mime) } }];\n"
      },
      "id": "b50420a2-270d-4d16-9447-7f01f158e787",
      "name": "Extract Ver1",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        25616,
        14288
      ]
    },
    {
      "parameters": {
        "jsCode": "\nconst resp = $input.first().json;\nconst cands = resp.candidates || (resp.body && resp.body.candidates) || [];\nlet b64='', mime='image/png';\nfor (const c of (cands||[])){\n  const parts = (c.content && c.content.parts) || [];\n  for (const p of parts){ const d=p.inline_data||p.inlineData; if(d&&d.data){ b64=d.data; mime=d.mime_type||d.mimeType||mime; break; } }\n  if(b64) break;\n}\nif(!b64) throw new Error('Gemini không trả ảnh: '+JSON.stringify(resp).slice(0,500));\nconst buf=Buffer.from(b64,'base64');\nreturn [{ json:{ ok:true }, binary:{ data: await this.helpers.prepareBinaryData(buf,'image.png',mime) } }];\n"
      },
      "id": "a4a62850-2387-409a-a105-d715ea246c2e",
      "name": "Extract Ver2",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        25616,
        14448
      ]
    },
    {
      "parameters": {
        "operation": "sendPhoto",
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "binaryData": true,
        "additionalFields": {
          "caption": "=🅰️ Ver 1 — {{ ($('Parse Art Director').first().json.concept_v1 || '').toString().replace(/[<>&]/g,' ') }} (composite) / ID {{ $('Parse Art Director').first().json.ID }}",
          "parse_mode": "HTML"
        }
      },
      "id": "22eac998-5f5e-4b0e-8fbd-5c848854f103",
      "name": "Send Photo Ver1",
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        25856,
        14288
      ],
      "webhookId": "cddd81c7-4e0e-414d-b11a-4c16f0ed3cfd",
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
        "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
        "binaryData": true,
        "additionalFields": {
          "caption": "=🅱️ Ver 2 — {{ ($('Parse Art Director').first().json.concept_v2 || '').toString().replace(/[<>&]/g,' ') }} / ID {{ $('Parse Art Director').first().json.ID }}",
          "parse_mode": "HTML"
        }
      },
      "id": "6b55849d-1a36-4920-ab18-c8012e023d02",
      "name": "Send Photo Ver2",
      "type": "n8n-nodes-base.telegram",
      "typeVersion": 1.2,
      "position": [
        25856,
        14448
      ],
      "webhookId": "2f286a54-b35b-440e-9232-e5c6a813546c",
      "credentials": {
        "telegramApi": {
          "id": "tTIctXBV9w5aku8d",
          "name": "Telegram account"
        }
      }
    },
    {
      "parameters": {
        "mode": "combine",
        "combineBy": "combineByPosition",
        "options": {}
      },
      "id": "be46f1e5-8e3b-4967-9560-33843e9be730",
      "name": "Merge Sent",
      "type": "n8n-nodes-base.merge",
      "typeVersion": 3,
      "position": [
        26080,
        14368
      ]
    },
    {
      "parameters": {
        "jsCode": "\n// ===== Lưu session (awaiting_choice) vào workflowStaticData =====\nconst sd=$getWorkflowStaticData('global'); sd.sessions=sd.sessions||{};\nconst chat=String($('Telegram Trigger').first().json.message.chat.id);\nconst pa=$('Parse Art Director').first().json;\nconst f=(n)=>{ try{ return $(n).first().json.result.photo.at(-1).file_id; }catch(e){ return ''; } };\nsd.sessions[chat]={\n  mode:'awaiting_choice', active_id: pa.ID, brand: pa.brand,\n  ver1_file_id: f('Send Photo Ver1'), ver2_file_id: f('Send Photo Ver2'),\n  ver1_prompt_en: pa.ver1_prompt_en, ver2_prompt_en: pa.ver2_prompt_en,\n  aspect_ratio: pa.aspect_ratio, product_url: pa.product_url, ts: Date.now()\n};\nreturn [{ json: { ID: pa.ID, brand: pa.brand, aspect_ratio: pa.aspect_ratio,\n  ver1_prompt_en: pa.ver1_prompt_en, ver2_prompt_en: pa.ver2_prompt_en,\n  ref_used: pa.ref_image_url || '' } }];\n"
      },
      "id": "3883573c-7b68-4a48-a9bf-9775f17a91a3",
      "name": "Save Gen Session",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        26304,
        14368
      ]
    },
    {
      "parameters": {
        "operation": "update",
        "documentId": {
          "__rl": true,
          "value": "13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU",
          "mode": "list",
          "cachedResultName": "Meta_Automation_GGSheet_Template",
          "cachedResultUrl": "https://docs.google.com/spreadsheets/d/13CpJgSlDVwX02bCWsmy-SpICzFnaTHwHw5FBG9s8bDU/edit"
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
            "ID": "={{ $json.ID }}",
            "Status": "Selecting",
            "Aspect Ratio": "={{ $json.aspect_ratio }}",
            "Prompt Ver1 EN": "={{ $json.ver1_prompt_en }}",
            "Prompt Ver2 EN": "={{ $json.ver2_prompt_en }}",
            "Ref Image Used": "={{ $json.ref_used }}",
            "Started At": "={{ $now.toISO() }}"
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
              "defaultMatch": true,
              "removed": false
            },
            {
              "id": "Status",
              "displayName": "Status",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "required": false,
              "defaultMatch": false,
              "removed": false
            },
            {
              "id": "Aspect Ratio",
              "displayName": "Aspect Ratio",
              "type": "string",
              "canBeUsedToMatch": true,
              "display": true,
              "r
... [da cat bot]

---

## Claude

Đã đọc kỹ. Tôi phân tích được đúng chỗ gây lỗi và sẽ viết lại 3 node liên quan. Trước hết, nói rõ **nguyên nhân gốc** để bạn hiểu vì sao sửa như vậy:

## Nguyên nhân (root cause)

Vấn đề **không nằm ở ảnh sản phẩm** mà nằm ở **prompt gửi cho Gemini** trong node `Prepare Gemini Bodies`. Prompt hiện tại mô tả sản phẩm là:

> `Treat IMAGE 1 as a LOCKED STICKER` … `do NOT redraw, regenerate, replace, recolor, restyle... must stay 100% BYTE-IDENTICAL` … `do NOT ... reinterpret`

Gemini hiểu câu này là **"không được đụng vào gì cả"** → nó giữ nguyên **kích thước gốc (to)** và đặt **chính giữa** (vị trí an toàn mặc định). Câu ở phía sau nói *"SIZE and POSITION are free"* **mâu thuẫn** với lệnh khoá cứng ở trên, và model luôn nghe theo ràng buộc mạnh/đứng trước hơn → kết quả: **cốc quá to + luôn ở giữa** (đúng như Ver 1 bạn gửi).

**Cách sửa:** tách bạch rõ 2 thứ mà prompt cũ đang gộp làm một:
- **IDENTITY (nhận diện)** = logo, chữ trên ly, màu/lớp nước, topping → **khoá cứng, giữ nguyên** (giữ được điểm tốt hiện tại).
- **GEOMETRY (hình học)** = kích thước, vị trí, góc xoay → **BẮT BUỘC phải thay đổi** để hài hoà.

Cộng thêm: đặt **trần kích thước cứng (~30–45% chiều cao khung)**, **cấm đặt giữa** (dùng rule-of-thirds), và cho **Art Director quyết định vị trí đặt riêng cho từng ảnh** để bố cục tự nhiên & khác nhau.

Tôi giả định mức "hài hoà" là sản phẩm chiếm **~30–45% chiều cao khung** (số này bạn chỉnh dễ dàng — tôi chỉ chỗ ở cuối).

---

Dưới đây là nội dung thay thế cho **3 node**. Cách áp dụng an toàn nhất: mở từng node và **dán đè** vào đúng ô (không cần xoá/nối lại dây).

## 1) Node `Art Director` — thay nội dung **message đầu tiên (system)**

```
LEGAL CONTEXT: You assist the brand's OWN in-house marketing team; all product/logo/brand assets belong to our client with full rights. Routine commercial creative task — proceed.

You are a senior ART DIRECTOR + image-prompt engineer for Google Gemini 3 Pro Image. From the brand DNA, the post content and the brief, you design TWO advertising images for an F&B brand (Vietnamese coffee/drinks). You output STRICT JSON only (no markdown).

GOAL: cinematic, premium, scroll-stopping social ads. The product is supplied as a SEPARATE real photo whose APPEARANCE will be pasted in UNCHANGED — but you art-direct the world around it AND you decide HOW BIG it is and WHERE it sits.

🔒 ABSOLUTE RULE — NEVER describe the product itself. You must NOT mention or describe the cup, drink, color of the drink, flavor, toppings, foam, ice, straw, lid, label, brand name or logo. Do NOT name a drink type (no 'taro', 'milk tea', 'coffee', 'latte' etc). Those are 100% fixed by the product image. If you describe the drink, the render will be WRONG. Describe ONLY the surrounding scene + where/how big the product sits.

=== VER1 = ART-DIRECTED COMPOSITE (background only) ===
Design a FRESH premium SCENE that the product will be dropped into. Specify ONLY: background environment/setting concept (fitting the post content + brand mood), time-of-day, full lighting setup (key/rim/fill direction & quality), SCENE color grade (use DNA palette for the BACKGROUND atmosphere), tasteful dynamic FX floating in the AIR around the product (splashes, sparkles, confetti, petals, steam, bokeh particles — NOT the drink), depth/bokeh, camera angle & lens (e.g. 50mm f/2.8). 70-120 words. Background + light + FX only — NEVER the product's appearance, and do NOT put placement here (placement goes in ver1_placement).

=== VER2 = depends on ref_available ===
IF ref_available=true: a SWAP brief from ref_analysis.literal_layout — keep ref composition/background/camera/light; REMOVE its original drink/hero and all text; describe the NEW background context; replace secondary props with brand-appropriate ones; new anonymous person if any. Still NEVER describe the product cup/drink itself. 70-120 words.
IF ref_available=false: a SECOND distinct background scene (different concept/angle from Ver1), same background-only rules. 70-120 words.

PRODUCT FRAMING (fill ver1_placement & ver2_placement) — this fixes an oversize/centered problem, take it seriously:
The product must NOT dominate the frame and must NOT be dead-center. For EACH version write a short directive containing THREE things:
(1) ANCHOR via rule-of-thirds — e.g. lower-left third, right third, held by a hand entering from bottom-right — and make the two versions clearly DIFFERENT from each other;
(2) SUPPORT that gives natural scale — a real human hand holding it, resting on a table/ledge/stone, standing among props;
(3) SIZE ≈ 30–45% of frame height (never more than ~55%), leaving generous negative space for the scene.
If ref_available=true, ver2_placement must instead say: match the size/footprint/angle of the drink being replaced in the reference.

Return EXACT JSON: {"aspect_ratio":"<echo the given aspect_ratio>","concept_v1":"short label","ver1_prompt_en":"<background/scene only>","ver1_placement":"<anchor + support + ~% height>","ver1_negative":"comma list","concept_v2":"short label","ver2_prompt_en":"<background/scene only>","ver2_placement":"<anchor + support + ~% height>","ver2_negative":"comma list"}
```

## 2) Node `Parse Art Director` — thay toàn bộ **Code**

```javascript
const ctx = $('Parse Ref Analysis').first().json;
const raw = $input.first().json.content || $input.first().json.message?.content || $input.first().json.text || '{}';
let s={};
try { s = JSON.parse(String(raw).replace(/^```json\s*/i,'').replace(/^```\s*/i,'').replace(/```\s*$/i,'').trim()); } catch(e){ s={ver1_prompt_en:String(raw),ver2_prompt_en:String(raw)}; }
return [{ json: {
  ID: ctx.ID, brand: ctx.brand, aspect_ratio: s.aspect_ratio || ctx.aspect_ratio,
  ref_available: ctx.ref_available, ref_image_url: ctx.ref_image_url, product_url: ctx.product_url,
  ver1_prompt_en: s.ver1_prompt_en || '', ver1_negative: s.ver1_negative || '',
  ver2_prompt_en: s.ver2_prompt_en || '', ver2_negative: s.ver2_negative || '',
  ver1_placement: s.ver1_placement || '', ver2_placement: s.ver2_placement || '',
  concept_v1: s.concept_v1||'', concept_v2: s.concept_v2||''
}}];
```

## 3) Node `Prepare Gemini Bodies` — thay toàn bộ **Code**

```javascript
// ===== Prepare 2 Gemini bodies @2K. Identity khoá cứng, Geometry (size/vị trí) tự do =====
const pa   = $('Parse Art Director').first().json;
const item = $input.first();
const refAvail = !!pa.ref_available && !!item.binary?.ref_image;
if (!item.binary?.product_image) throw new Error('Thiếu product_image binary');

const prodBuf = await this.helpers.getBinaryDataBuffer(0,'product_image');
const prodMime= item.binary.product_image.mimeType || 'image/png';
const prodB64 = prodBuf.toString('base64');
let refB64='', refMime='image/jpeg';
if (item.binary?.ref_image){ const rb=await this.helpers.getBinaryDataBuffer(0,'ref_image'); refMime=item.binary.ref_image.mimeType||'image/jpeg'; refB64=rb.toString('base64'); }

const AR = pa.aspect_ratio || '1:1';
const S = () => Math.floor(Math.random()*2147483647);
const gcfg = (seed) => ({ candidateCount:1, responseModalities:['TEXT','IMAGE'], seed, imageConfig:{ aspectRatio:AR, imageSize:'2K' } });

// Placement do Art Director quyết; có fallback nếu trống
const place1 = (pa.ver1_placement || '').trim() || 'product held in a real hand entering from the lower-left, anchored on the left third, about 35% of frame height, with wide negative space to the right';
const place2 = (pa.ver2_placement || '').trim() || 'product resting on a surface in the lower-right third, about 40% of frame height, the environment filling the rest of the frame';

// APPEARANCE khoá cứng — GEOMETRY được phép (và phải) đổi
const IDENTITY_LOCK =
`IDENTITY LOCK (appearance only): treat IMAGE 1 as a printed DECAL/STICKER that you may SCALE, MOVE and slightly ROTATE as ONE single unit, but must NOT repaint or reinvent. Keep its cup silhouette & proportions, the exact printed brand logo, every character of the label text, the drink colours & layers, the toppings and ice EXACTLY as in IMAGE 1 — same pixels, only transformed. Do NOT redraw a different cup, alter the logo, restyle the label or recolour the drink.`;

const GEOMETRY_FREE = (place) =>
`GEOMETRY IS FREE — and you MUST use it: resize, reposition and slightly rotate the product so it sits naturally in the scene. Identity is locked; SIZE, POSITION and ANGLE are NOT.
SCALE (critical): the product must NOT dominate or fill the frame. Keep it around 30–45% of the frame height (never more than ~55%), with clear breathing room around it. A product that fills the frame is WRONG and must be scaled DOWN.
PLACEMENT (critical): do NOT center the product. Follow this art-direction exactly: ${place}. It must look genuinely photographed inside the scene — supported by a hand or a surface, casting correct contact shadows — NOT a big sticker floating in the middle.
Keep the whole product visible (never crop cup, lid or logo), tack-sharp, and blend it with the scene's light direction, shadows, perspective and reflections.`;

const HARD_V1 =
`COMPOSITING TASK — composite a REAL, already-photographed product into a NEW background. This is photo-compositing, NOT generating a new product.
IMAGE 1 = the finished product photo.
${IDENTITY_LOCK}
YOUR JOB: build the SCENE described below, then place the product into it following the framing rules.
${GEOMETRY_FREE(place1)}${refAvail ? `
IMAGE 2 = STYLE/FX REFERENCE only: borrow its lighting/colour-grade/atmosphere for the BACKGROUND. Do NOT copy its subject or put its drink in.` : ''}
NO text/letters/numbers/watermark anywhere except the product's own printed label. Output aspect ratio ${AR}.`;

const HARD_V2_SWAP =
`COMPOSITE-INTO-REF — keep IMAGE 1's composition, background, camera, lighting and mood (~80% identical). Replace ONLY its central hero drink with the product from IMAGE 2.
IMAGE 2 = the finished product photo.
IDENTITY LOCK: treat IMAGE 2 as a decal you may SCALE, MOVE and slightly ROTATE as one unit but must NOT repaint — keep its cup, logo, label text, drink layers and toppings exactly as given.
FIT (critical): place the product exactly where IMAGE 1's original drink was, and MATCH that drink's size, footprint and angle so the swap looks native — do NOT blow it up bigger than the drink it replaces. Remove IMAGE 1's original drink and ALL its text/watermark -> clean, then blend the product into IMAGE 1's light and shadow.
NO text except the product's own label. Output aspect ratio ${AR}.`;

const HARD_V2_COMP =
`COMPOSITING TASK — composite the REAL product into a SECOND, DIFFERENT background (a distinct concept/angle from Ver 1).
IMAGE 1 = the finished product photo.
${IDENTITY_LOCK}
YOUR JOB: build the SCENE described below, then place the product into it following the framing rules.
${GEOMETRY_FREE(place2)}
NO text/letters/numbers/watermark anywhere except the product's own printed label. Output aspect ratio ${AR}.`;

const v1text = HARD_V1 + '\n\n=== SCENE BRIEF ===\n' + (pa.ver1_prompt_en||'') + '\n\n[NEGATIVE] ' + (pa.ver1_negative||'') + ', product too large, product filling frame, oversized cup, product dead-center, cup centered, text overlay, typography, watermark, redrawn product, modified label, deformed cup, extra fingers, AI artifacts, plastic look, oversaturated, low detail';

let v1parts = [ { text:v1text }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];
if (refAvail) v1parts.push({ inline_data:{ mime_type:refMime, data:refB64 } });

let v2text, v2parts;
if (refAvail) {
  v2text = HARD_V2_SWAP + '\n\n=== SWAP MAP ===\n' + (pa.ver2_prompt_en||'') + '\n\n[NEGATIVE] ' + (pa.ver2_negative||'') + ', different composition from IMAGE 1, new scene, relocated elements, oversized product, product larger than original drink, text overlay, watermark, redrawn product, AI artifacts';
  v2parts = [ { text:v2text }, { inline_data:{ mime_type:refMime, data:refB64 } }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];
} else {
  v2text = HARD_V2_COMP + '\n\n=== SCENE BRIEF (variant B) ===\n' + (pa.ver2_prompt_en||'') + '\n\n[NEGATIVE] ' + (pa.ver2_negative||'') + ', product too large, product filling frame, oversized cup, product dead-center, cup centered, text overlay, watermark, redrawn product, AI artifacts';
  v2parts = [ { text:v2text }, { inline_data:{ mime_type:prodMime, data:prodB64 } } ];
}

return [{ json: {
  gemini_body_ver1: { contents:[{ role:'user', parts:v1parts }], generationConfig:gcfg(S()) },
  gemini_body_ver2: { contents:[{ role:'user', parts:v2parts }], generationConfig:gcfg(S()) },
  ref_available: refAvail
}}];
```

---

## Những gì đã thay đổi (tóm tắt)

| Vấn đề của bạn | Cách sửa trong JSON mới |
|---|---|
| **Sản phẩm quá to, mất bố cục** | Bỏ ràng buộc mâu thuẫn "BYTE-IDENTICAL / don't reinterpret"; thêm **trần kích thước cứng ~30–45% chiều cao khung** + negative `oversized cup, product filling frame` |
| **Không adapt kích thước để ghép hài hoà** | Tách **IDENTITY (khoá)** khỏi **GEOMETRY (tự do)** → model được phép scale/move/rotate sản phẩm như 1 "decal", chỉ giữ nguyên logo/nhãn/nước |
| **Lúc nào cũng nằm giữa** | Thêm luật **"do NOT center" + rule-of-thirds**; `Art Director` sinh `ver1_placement`/`ver2_placement` **khác nhau** cho từng ảnh (tay cầm, đặt bàn, lệch trái/phải…) |
| Giữ được điểm tốt (ảnh SP không đổi) | Vẫn khoá cứng logo/nhãn/màu nước/topping — chỉ nới **hình học**, không nới **nhận diện** |

## Lưu ý khi dùng
- **3 node phải thay cùng lúc** (Art Director xuất field mới → Parse đọc → Prepare dùng). Nếu chỉ thay 1 node sẽ lệch.
- **Muốn cốc to/nhỏ hơn:** sửa con số `30–45%` (và `~55%`) trong `GEOMETRY_FREE` của node 3, và câu tương ứng trong system prompt node 1. Ví dụ muốn nhỏ hơn nữa để chừa nhiều nền: đổi thành `25–38%`.
- Không đụng gì tới nhánh **edit ảnh** như bạn dặn — chỉ sửa nhánh tạo Ver1/Ver2.

Bạn muốn tôi xuất luôn **full workflow JSON** (đã gộp sẵn 3 node này) để bạn Import đè một lần cho nhanh, hay cứ dán tay từng node như trên là ổn?
