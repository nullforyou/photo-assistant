import 'dart:convert';

import 'pose_library.dart';

/// 内置默认姿势数据包（单机版唯一数据源，等效原服务端契约）。
/// 由 scripts/generate_poses_json.py 从 image/ 生成，并与 WSL 源 / 本地副本保持同步。
/// 全部 42 条姿势均为 imageAsset 透明 PNG（来自 D:\work\photo-assistant\image），
/// 不再携带 SVG 路径（paths / headRect / parts）数据。
/// 每条姿势带 tips 摆姿文字提示；无实际指导的姿势 tips 为空数组，不显示无意义占位文案。
const String kDefaultPoseJson = r'''
{
  "version": "1.0.0",
  "designWidth": 240,
  "designHeight": 380,
  "styles": {
    "minimal": {
      "name": "极简单线",
      "tint": "#FFFFFF",
      "outerColor": "#000000",
      "outerWidth": 4.0,
      "innerColor": "#FFFFFF",
      "innerWidth": 2.0,
      "glow": false,
      "glowColor": "#FFFFFF",
      "glowBlur": 0.0,
      "fillColor": "#FFFFFF",
      "fillOpacity": 0.05,
      "showKeyPoints": false,
      "keyPointColor": "#FFFFFF",
      "keyPointRadius": 3.0,
      "keyPointGlow": false,
      "showTips": true,
      "nameI18n": {
        "en": "Minimal single line",
        "zh_Hant": "極簡單線",
        "ja": "ミニマル単線",
        "ko": "미니멀 단선",
        "fr": "Ligne unique minimaliste",
        "de": "Minimaler Einzellinien-Stil",
        "th": "เส้นเดี่ยวมินิมอล",
        "pt": "Linha única minimalista",
        "es": "Línea única minimalista",
        "tr": "Minimal tek çizgi"
      }
    },
    "dual_outline": {
      "name": "蓝调描边",
      "tint": "#00E5FF",
      "outerColor": "#0A0E14",
      "outerWidth": 6.0,
      "innerColor": "#00E5FF",
      "innerWidth": 2.5,
      "glow": false,
      "glowColor": "#00E5FF",
      "glowBlur": 10.0,
      "fillColor": "#10243A",
      "fillOpacity": 0.18,
      "showKeyPoints": true,
      "keyPointColor": "#00E5FF",
      "keyPointRadius": 4.0,
      "keyPointGlow": true,
      "showTips": true,
      "singleLayer": true,
      "nameI18n": {
        "en": "Blue outline",
        "zh_Hant": "藍調描邊",
        "ja": "ブルーの輪郭",
        "ko": "블루 외곽선",
        "fr": "Contour bleu",
        "de": "Blaue Umrandung",
        "th": "เส้นขอบสีน้ำเงิน",
        "pt": "Contorno azul",
        "es": "Contorno azul",
        "tr": "Mavi kontur"
      }
    },
    "neon": {
      "name": "霓虹",
      "tint": "#FF2BD6",
      "outerColor": "#1A0033",
      "outerWidth": 6.0,
      "innerColor": "#FF2BD6",
      "innerWidth": 3.0,
      "glow": false,
      "glowColor": "#FF2BD6",
      "glowBlur": 16.0,
      "fillColor": "#FF2BD6",
      "fillOpacity": 0.08,
      "showKeyPoints": true,
      "keyPointColor": "#FFFFFF",
      "keyPointRadius": 4.0,
      "keyPointGlow": true,
      "showTips": true,
      "singleLayer": true,
      "nameI18n": {
        "en": "Neon",
        "zh_Hant": "霓虹",
        "ja": "ネオン",
        "ko": "네온",
        "fr": "Néon",
        "de": "Neon",
        "th": "นีออน",
        "pt": "Neon",
        "es": "Neón",
        "tr": "Neon"
      }
    },
    "soft_glow": {
      "name": "柔光暖黄",
      "tint": "#FFD54F",
      "outerColor": "#3A2E00",
      "outerWidth": 6.0,
      "innerColor": "#FFD54F",
      "innerWidth": 2.5,
      "glow": false,
      "glowColor": "#FFD54F",
      "glowBlur": 12.0,
      "fillColor": "#FFD54F",
      "fillOpacity": 0.12,
      "showKeyPoints": true,
      "keyPointColor": "#FFD54F",
      "keyPointRadius": 4.0,
      "keyPointGlow": true,
      "showTips": true,
      "singleLayer": true,
      "nameI18n": {
        "en": "Soft warm yellow",
        "zh_Hant": "柔光暖黃",
        "ja": "やわらかな暖黄色",
        "ko": "부드러운 따뜻한 노랑",
        "fr": "Jaune chaud doux",
        "de": "Weiches warmes Gelb",
        "th": "เหลืองอุ่นนุ่มนวล",
        "pt": "Amarelo quente suave",
        "es": "Amarillo cálido suave",
        "tr": "Yumuşak sıcak sarı"
      }
    }
  },
  "activeStyle": "none",
  "thumbnail": {
    "listHeight": 43,
    "itemWidth": 34,
    "itemHeight": 43,
    "itemSpacing": 10
  },
  "poses": [
    {
      "id": "pose_001",
      "name": "侧身微笑腿抬起",
      "nameI18n": {
        "en": "Side smile, leg raised",
        "zh_Hant": "側身微笑腿抬起"
      },
      "imageAsset": "assets/poses/pose_001.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "侧身微笑",
          "x": 180,
          "y": 230
        },
        {
          "text": "腿抬起",
          "x": 340,
          "y": 440
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Smile — at left shoulder",
            "x": 180,
            "y": 230
          },
          {
            "text": "Raise leg — at left knee",
            "x": 340,
            "y": 440
          }
        ],
        "zh_Hant": [
          {
            "text": "側身微笑",
            "x": 180,
            "y": 230
          },
          {
            "text": "腿抬起",
            "x": 340,
            "y": 440
          }
        ],
        "ja": [
          {
            "text": "横顔で微笑む",
            "x": 180,
            "y": 230
          },
          {
            "text": "足を上げる",
            "x": 340,
            "y": 440
          }
        ],
        "ko": [
          {
            "text": "옆얼굴로 미소",
            "x": 180,
            "y": 230
          },
          {
            "text": "다리 들기",
            "x": 340,
            "y": 440
          }
        ],
        "fr": [
          {
            "text": "Sourire de profil",
            "x": 180,
            "y": 230
          },
          {
            "text": "Jambe levée",
            "x": 340,
            "y": 440
          }
        ],
        "de": [
          {
            "text": "Lächeln im Seitenprofil",
            "x": 180,
            "y": 230
          },
          {
            "text": "Bein gehoben",
            "x": 340,
            "y": 440
          }
        ],
        "th": [
          {
            "text": "ยิ้มข้างตัว",
            "x": 180,
            "y": 230
          },
          {
            "text": "ยกขา",
            "x": 340,
            "y": 440
          }
        ],
        "pt": [
          {
            "text": "Sorriso de perfil",
            "x": 180,
            "y": 230
          },
          {
            "text": "Perna levantada",
            "x": 340,
            "y": 440
          }
        ],
        "es": [
          {
            "text": "Sonrisa de perfil",
            "x": 180,
            "y": 230
          },
          {
            "text": "Pierna levantada",
            "x": 340,
            "y": 440
          }
        ],
        "tr": [
          {
            "text": "Yandan gülümseme",
            "x": 180,
            "y": 230
          },
          {
            "text": "Bacak kaldırılmış",
            "x": 340,
            "y": 440
          }
        ]
      }
    },
    {
      "id": "pose_002",
      "name": "一手遮帽向前比耶",
      "nameI18n": {
        "en": "One hand shading hat, peace sign forward",
        "zh_Hant": "一手遮帽向前比耶"
      },
      "imageAsset": "assets/poses/pose_002.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "一手遮帽",
          "x": 322,
          "y": 220
        },
        {
          "text": "向前比耶",
          "x": 452,
          "y": 380
        },
        {
          "text": "侧身",
          "x": 78,
          "y": 584
        },
        {
          "text": "脚前伸",
          "x": 410,
          "y": 750
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "One hand shading hat",
            "x": 322,
            "y": 220
          },
          {
            "text": "Peace sign forward",
            "x": 452,
            "y": 380
          },
          {
            "text": "Turn to side",
            "x": 78,
            "y": 584
          },
          {
            "text": "Foot extended forward",
            "x": 410,
            "y": 750
          }
        ],
        "zh_Hant": [
          {
            "text": "一手遮帽",
            "x": 322,
            "y": 220
          },
          {
            "text": "向前比耶",
            "x": 452,
            "y": 380
          },
          {
            "text": "側身",
            "x": 78,
            "y": 584
          },
          {
            "text": "腳前伸",
            "x": 410,
            "y": 750
          }
        ],
        "ja": [
          {
            "text": "片手で帽子を隠す",
            "x": 322,
            "y": 220
          },
          {
            "text": "前方でピース",
            "x": 452,
            "y": 380
          },
          {
            "text": "横顔",
            "x": 78,
            "y": 584
          },
          {
            "text": "足を前に出す",
            "x": 410,
            "y": 750
          }
        ],
        "ko": [
          {
            "text": "한 손으로 모자 가리기",
            "x": 322,
            "y": 220
          },
          {
            "text": "앞에서 브이",
            "x": 452,
            "y": 380
          },
          {
            "text": "옆얼굴",
            "x": 78,
            "y": 584
          },
          {
            "text": "발 앞으로 뻗기",
            "x": 410,
            "y": 750
          }
        ],
        "fr": [
          {
            "text": "une main sous le chapeau",
            "x": 322,
            "y": 220
          },
          {
            "text": "signe de paix vers l'avant",
            "x": 452,
            "y": 380
          },
          {
            "text": "de profil",
            "x": 78,
            "y": 584
          },
          {
            "text": "pied tendu vers l'avant",
            "x": 410,
            "y": 750
          }
        ],
        "de": [
          {
            "text": "eine Hand unter dem Hut",
            "x": 322,
            "y": 220
          },
          {
            "text": "Peace-Zeichen nach vorn",
            "x": 452,
            "y": 380
          },
          {
            "text": "im Seitenprofil",
            "x": 78,
            "y": 584
          },
          {
            "text": "Fuß nach vorn gestreckt",
            "x": 410,
            "y": 750
          }
        ],
        "th": [
          {
            "text": "มือหนึ่งบังหมวก",
            "x": 322,
            "y": 220
          },
          {
            "text": "สัญญาณวีด้านหน้า",
            "x": 452,
            "y": 380
          },
          {
            "text": "ข้างตัว",
            "x": 78,
            "y": 584
          },
          {
            "text": "เท้ายื่นไปข้างหน้า",
            "x": 410,
            "y": 750
          }
        ],
        "pt": [
          {
            "text": "uma mão sob o chapéu",
            "x": 322,
            "y": 220
          },
          {
            "text": "sinal de paz à frente",
            "x": 452,
            "y": 380
          },
          {
            "text": "de perfil",
            "x": 78,
            "y": 584
          },
          {
            "text": "pé estendido à frente",
            "x": 410,
            "y": 750
          }
        ],
        "es": [
          {
            "text": "una mano bajo el sombrero",
            "x": 322,
            "y": 220
          },
          {
            "text": "signo de paz al frente",
            "x": 452,
            "y": 380
          },
          {
            "text": "de perfil",
            "x": 78,
            "y": 584
          },
          {
            "text": "pie extendido al frente",
            "x": 410,
            "y": 750
          }
        ],
        "tr": [
          {
            "text": "bir el şapka altında",
            "x": 322,
            "y": 220
          },
          {
            "text": "öne V işareti",
            "x": 452,
            "y": 380
          },
          {
            "text": "yandan",
            "x": 78,
            "y": 584
          },
          {
            "text": "ayak öne uzatılmış",
            "x": 410,
            "y": 750
          }
        ]
      }
    },
    {
      "id": "pose_003",
      "name": "一手平举侧踢腿",
      "nameI18n": {
        "en": "One arm extended, side kick",
        "zh_Hant": "一手平舉側踢腿"
      },
      "imageAsset": "assets/poses/pose_003.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "一手平举",
          "x": 400,
          "y": 186
        },
        {
          "text": "侧踢腿",
          "x": 129,
          "y": 658
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "One arm raised sideways",
            "x": 400,
            "y": 186
          },
          {
            "text": "Side kick",
            "x": 129,
            "y": 658
          }
        ],
        "zh_Hant": [
          {
            "text": "一手平舉",
            "x": 400,
            "y": 186
          },
          {
            "text": "側踢腿",
            "x": 129,
            "y": 658
          }
        ],
        "ja": [
          {
            "text": "片手を水平に挙げる",
            "x": 400,
            "y": 186
          },
          {
            "text": "横蹴り",
            "x": 129,
            "y": 658
          }
        ],
        "ko": [
          {
            "text": "한 손 수평으로 들기",
            "x": 400,
            "y": 186
          },
          {
            "text": "옆차기",
            "x": 129,
            "y": 658
          }
        ],
        "fr": [
          {
            "text": "un bras à l'horizontale",
            "x": 400,
            "y": 186
          },
          {
            "text": "coup de pied de côté",
            "x": 129,
            "y": 658
          }
        ],
        "de": [
          {
            "text": "ein Arm waagerecht gestreckt",
            "x": 400,
            "y": 186
          },
          {
            "text": "Seitentritt",
            "x": 129,
            "y": 658
          }
        ],
        "th": [
          {
            "text": "แขนข้างระดับเสมอ",
            "x": 400,
            "y": 186
          },
          {
            "text": "เตะข้าง",
            "x": 129,
            "y": 658
          }
        ],
        "pt": [
          {
            "text": "um braço na horizontal",
            "x": 400,
            "y": 186
          },
          {
            "text": "chute lateral",
            "x": 129,
            "y": 658
          }
        ],
        "es": [
          {
            "text": "un brazo en horizontal",
            "x": 400,
            "y": 186
          },
          {
            "text": "patada lateral",
            "x": 129,
            "y": 658
          }
        ],
        "tr": [
          {
            "text": "bir kol yatay uzatılmış",
            "x": 400,
            "y": 186
          },
          {
            "text": "yan tekme",
            "x": 129,
            "y": 658
          }
        ]
      }
    },
    {
      "id": "pose_004",
      "name": "坐着歪头拉头发",
      "nameI18n": {
        "en": "Sitting, head tilted, fixing hair",
        "zh_Hant": "坐著歪頭拉頭髮"
      },
      "imageAsset": "assets/poses/pose_004.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "拉头发",
          "x": 209,
          "y": 223
        },
        {
          "text": "坐着歪头",
          "x": 277,
          "y": 415
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Pulling hair",
            "x": 209,
            "y": 223
          },
          {
            "text": "Sitting, head tilted",
            "x": 277,
            "y": 415
          }
        ],
        "zh_Hant": [
          {
            "text": "拉頭髮",
            "x": 209,
            "y": 223
          },
          {
            "text": "坐著歪頭",
            "x": 277,
            "y": 415
          }
        ],
        "ja": [
          {
            "text": "髪を引っ張る",
            "x": 209,
            "y": 223
          },
          {
            "text": "座って首をかしげる",
            "x": 277,
            "y": 415
          }
        ],
        "ko": [
          {
            "text": "머리 잡아당기기",
            "x": 209,
            "y": 223
          },
          {
            "text": "앉아서 고개 숙이기",
            "x": 277,
            "y": 415
          }
        ],
        "fr": [
          {
            "text": "tirer les cheveux",
            "x": 209,
            "y": 223
          },
          {
            "text": "assise, tête penchée",
            "x": 277,
            "y": 415
          }
        ],
        "de": [
          {
            "text": "Haare ziehen",
            "x": 209,
            "y": 223
          },
          {
            "text": "sitzend, Kopf schief",
            "x": 277,
            "y": 415
          }
        ],
        "th": [
          {
            "text": "ดึงผม",
            "x": 209,
            "y": 223
          },
          {
            "text": "นั่งก้มคอ",
            "x": 277,
            "y": 415
          }
        ],
        "pt": [
          {
            "text": "puxar o cabelo",
            "x": 209,
            "y": 223
          },
          {
            "text": "sentada, cabeça inclinada",
            "x": 277,
            "y": 415
          }
        ],
        "es": [
          {
            "text": "tirar del pelo",
            "x": 209,
            "y": 223
          },
          {
            "text": "sentada, cabeza inclinada",
            "x": 277,
            "y": 415
          }
        ],
        "tr": [
          {
            "text": "saçı çekme",
            "x": 209,
            "y": 223
          },
          {
            "text": "oturmuş, başı yana eğik",
            "x": 277,
            "y": 415
          }
        ]
      }
    },
    {
      "id": "pose_005",
      "name": "提包拉发腿交叉",
      "nameI18n": {
        "en": "Holding bag, fixing hair, crossed legs",
        "zh_Hant": "提包拉發腿交叉"
      },
      "imageAsset": "assets/poses/pose_005.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "提包",
          "x": 114,
          "y": 280
        },
        {
          "text": "拉头发",
          "x": 400,
          "y": 333
        },
        {
          "text": "腿交叉",
          "x": 360,
          "y": 700
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Holding bag",
            "x": 114,
            "y": 280
          },
          {
            "text": "Pulling hair",
            "x": 400,
            "y": 333
          },
          {
            "text": "Legs crossed",
            "x": 360,
            "y": 700
          }
        ],
        "zh_Hant": [
          {
            "text": "提包",
            "x": 114,
            "y": 280
          },
          {
            "text": "拉頭髮",
            "x": 400,
            "y": 333
          },
          {
            "text": "腿交叉",
            "x": 360,
            "y": 700
          }
        ],
        "ja": [
          {
            "text": "バッグを持つ",
            "x": 114,
            "y": 280
          },
          {
            "text": "髪を引っ張る",
            "x": 400,
            "y": 333
          },
          {
            "text": "足を組む",
            "x": 360,
            "y": 700
          }
        ],
        "ko": [
          {
            "text": "가방 들기",
            "x": 114,
            "y": 280
          },
          {
            "text": "머리 잡아당기기",
            "x": 400,
            "y": 333
          },
          {
            "text": "다리 꼬기",
            "x": 360,
            "y": 700
          }
        ],
        "fr": [
          {
            "text": "tenant un sac",
            "x": 114,
            "y": 280
          },
          {
            "text": "tirer les cheveux",
            "x": 400,
            "y": 333
          },
          {
            "text": "jambes croisées",
            "x": 360,
            "y": 700
          }
        ],
        "de": [
          {
            "text": "Tasche haltend",
            "x": 114,
            "y": 280
          },
          {
            "text": "Haare ziehen",
            "x": 400,
            "y": 333
          },
          {
            "text": "Beine überkreuzt",
            "x": 360,
            "y": 700
          }
        ],
        "th": [
          {
            "text": "ถือกระเป๋า",
            "x": 114,
            "y": 280
          },
          {
            "text": "ดึงผม",
            "x": 400,
            "y": 333
          },
          {
            "text": "ขาไขว้",
            "x": 360,
            "y": 700
          }
        ],
        "pt": [
          {
            "text": "segurando uma bolsa",
            "x": 114,
            "y": 280
          },
          {
            "text": "puxar o cabelo",
            "x": 400,
            "y": 333
          },
          {
            "text": "pernas cruzadas",
            "x": 360,
            "y": 700
          }
        ],
        "es": [
          {
            "text": "sosteniendo un bolso",
            "x": 114,
            "y": 280
          },
          {
            "text": "tirar del pelo",
            "x": 400,
            "y": 333
          },
          {
            "text": "piernas cruzadas",
            "x": 360,
            "y": 700
          }
        ],
        "tr": [
          {
            "text": "çanta tutarak",
            "x": 114,
            "y": 280
          },
          {
            "text": "saçı çekme",
            "x": 400,
            "y": 333
          },
          {
            "text": "bacaklar çapraz",
            "x": 360,
            "y": 700
          }
        ]
      }
    },
    {
      "id": "pose_006",
      "name": "双手拿头发侧弯腰",
      "nameI18n": {
        "en": "Both hands in hair, bending sideways",
        "zh_Hant": "雙手拿頭髮側彎腰"
      },
      "imageAsset": "assets/poses/pose_006.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "双手拿头发",
          "x": 364,
          "y": 229
        },
        {
          "text": "侧弯腰",
          "x": 208,
          "y": 556
        },
        {
          "text": "较尖朝上",
          "x": 138,
          "y": 745
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Both hands in hair",
            "x": 364,
            "y": 229
          },
          {
            "text": "Bend to the side",
            "x": 208,
            "y": 556
          },
          {
            "text": "Toes pointing up",
            "x": 138,
            "y": 745
          }
        ],
        "zh_Hant": [
          {
            "text": "雙手拿頭髮",
            "x": 364,
            "y": 229
          },
          {
            "text": "側彎腰",
            "x": 208,
            "y": 556
          },
          {
            "text": "較尖朝上",
            "x": 138,
            "y": 745
          }
        ],
        "ja": [
          {
            "text": "両手で髪を掴む",
            "x": 364,
            "y": 229
          },
          {
            "text": "横に体を曲げる",
            "x": 208,
            "y": 556
          },
          {
            "text": "先端を上に",
            "x": 138,
            "y": 745
          }
        ],
        "ko": [
          {
            "text": "두 손으로 머리 잡기",
            "x": 364,
            "y": 229
          },
          {
            "text": "옆으로 굽히기",
            "x": 208,
            "y": 556
          },
          {
            "text": "뾰족한 끝을 위로",
            "x": 138,
            "y": 745
          }
        ],
        "fr": [
          {
            "text": "les deux mains dans les cheveux",
            "x": 364,
            "y": 229
          },
          {
            "text": "se pencher sur le côté",
            "x": 208,
            "y": 556
          },
          {
            "text": "la pointe vers le haut",
            "x": 138,
            "y": 745
          }
        ],
        "de": [
          {
            "text": "beide Hände in den Haaren",
            "x": 364,
            "y": 229
          },
          {
            "text": "zur Seite beugen",
            "x": 208,
            "y": 556
          },
          {
            "text": "die Spitze nach oben",
            "x": 138,
            "y": 745
          }
        ],
        "th": [
          {
            "text": "สองมือจับผม",
            "x": 364,
            "y": 229
          },
          {
            "text": "ก้มตัวข้าง",
            "x": 208,
            "y": 556
          },
          {
            "text": "ปลายชี้ขึ้น",
            "x": 138,
            "y": 745
          }
        ],
        "pt": [
          {
            "text": "ambas as mãos no cabelo",
            "x": 364,
            "y": 229
          },
          {
            "text": "inclinar para o lado",
            "x": 208,
            "y": 556
          },
          {
            "text": "a ponta para cima",
            "x": 138,
            "y": 745
          }
        ],
        "es": [
          {
            "text": "ambas manos en el pelo",
            "x": 364,
            "y": 229
          },
          {
            "text": "inclinarse a un lado",
            "x": 208,
            "y": 556
          },
          {
            "text": "la punta hacia arriba",
            "x": 138,
            "y": 745
          }
        ],
        "tr": [
          {
            "text": "iki el saçta",
            "x": 364,
            "y": 229
          },
          {
            "text": "yana eğilme",
            "x": 208,
            "y": 556
          },
          {
            "text": "uç yukarıda",
            "x": 138,
            "y": 745
          }
        ]
      }
    },
    {
      "id": "pose_007",
      "name": "低头双手环抱",
      "nameI18n": {
        "en": "Head down, arms wrapped",
        "zh_Hant": "低頭雙手環抱"
      },
      "imageAsset": "assets/poses/pose_007.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "低头",
          "x": 319,
          "y": 172
        },
        {
          "text": "双手环胸",
          "x": 350,
          "y": 388
        },
        {
          "text": "腿交叉",
          "x": 322,
          "y": 686
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Head down",
            "x": 319,
            "y": 172
          },
          {
            "text": "Arms crossed at chest",
            "x": 350,
            "y": 388
          },
          {
            "text": "Legs crossed",
            "x": 322,
            "y": 686
          }
        ],
        "zh_Hant": [
          {
            "text": "低頭",
            "x": 319,
            "y": 172
          },
          {
            "text": "雙手環胸",
            "x": 350,
            "y": 388
          },
          {
            "text": "腿交叉",
            "x": 322,
            "y": 686
          }
        ],
        "ja": [
          {
            "text": "うつむく",
            "x": 319,
            "y": 172
          },
          {
            "text": "両腕で胸を抱える",
            "x": 350,
            "y": 388
          },
          {
            "text": "足を組む",
            "x": 322,
            "y": 686
          }
        ],
        "ko": [
          {
            "text": "고개 숙이기",
            "x": 319,
            "y": 172
          },
          {
            "text": "두 팔로 가슴 감싸기",
            "x": 350,
            "y": 388
          },
          {
            "text": "다리 꼬기",
            "x": 322,
            "y": 686
          }
        ],
        "fr": [
          {
            "text": "tête baissée",
            "x": 319,
            "y": 172
          },
          {
            "text": "bras croisés sur la poitrine",
            "x": 350,
            "y": 388
          },
          {
            "text": "jambes croisées",
            "x": 322,
            "y": 686
          }
        ],
        "de": [
          {
            "text": "Kopf gesenkt",
            "x": 319,
            "y": 172
          },
          {
            "text": "Arme vor der Brust verschränkt",
            "x": 350,
            "y": 388
          },
          {
            "text": "Beine überkreuzt",
            "x": 322,
            "y": 686
          }
        ],
        "th": [
          {
            "text": "ก้มหน้า",
            "x": 319,
            "y": 172
          },
          {
            "text": "แขนกอดหน้าอก",
            "x": 350,
            "y": 388
          },
          {
            "text": "ขาไขว้",
            "x": 322,
            "y": 686
          }
        ],
        "pt": [
          {
            "text": "cabeça baixa",
            "x": 319,
            "y": 172
          },
          {
            "text": "braços cruzados no peito",
            "x": 350,
            "y": 388
          },
          {
            "text": "pernas cruzadas",
            "x": 322,
            "y": 686
          }
        ],
        "es": [
          {
            "text": "cabeza baja",
            "x": 319,
            "y": 172
          },
          {
            "text": "brazos cruzados al pecho",
            "x": 350,
            "y": 388
          },
          {
            "text": "piernas cruzadas",
            "x": 322,
            "y": 686
          }
        ],
        "tr": [
          {
            "text": "baş eğik",
            "x": 319,
            "y": 172
          },
          {
            "text": "kollar göğüs önünde kavuşmuş",
            "x": 350,
            "y": 388
          },
          {
            "text": "bacaklar çapraz",
            "x": 322,
            "y": 686
          }
        ]
      }
    },
    {
      "id": "pose_008",
      "name": "双手上下摆动腿分开",
      "nameI18n": {
        "en": "Hands up and down, legs apart",
        "zh_Hant": "雙手上下襬動腿分開"
      },
      "imageAsset": "assets/poses/pose_008.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "双手上下摆动",
          "x": 460,
          "y": 61
        },
        {
          "text": "身体微侧",
          "x": 400,
          "y": 396
        },
        {
          "text": "双腿大步分开",
          "x": 260,
          "y": 733
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Hands moving up and down",
            "x": 460,
            "y": 61
          },
          {
            "text": "Body slightly turned",
            "x": 400,
            "y": 396
          },
          {
            "text": "Legs apart, wide stance",
            "x": 260,
            "y": 733
          }
        ],
        "zh_Hant": [
          {
            "text": "雙手上下襬動",
            "x": 460,
            "y": 61
          },
          {
            "text": "身體微側",
            "x": 400,
            "y": 396
          },
          {
            "text": "雙腿大步分開",
            "x": 260,
            "y": 733
          }
        ],
        "ja": [
          {
            "text": "両手を上下に振る",
            "x": 460,
            "y": 61
          },
          {
            "text": "体を少し横に",
            "x": 400,
            "y": 396
          },
          {
            "text": "両足を大きく開く",
            "x": 260,
            "y": 733
          }
        ],
        "ko": [
          {
            "text": "두 손 위아래로 흔들기",
            "x": 460,
            "y": 61
          },
          {
            "text": "몸 살짝 옆으로",
            "x": 400,
            "y": 396
          },
          {
            "text": "두 다리 크게 벌리기",
            "x": 260,
            "y": 733
          }
        ],
        "fr": [
          {
            "text": "mains balancées haut et bas",
            "x": 460,
            "y": 61
          },
          {
            "text": "corps légèrement de côté",
            "x": 400,
            "y": 396
          },
          {
            "text": "jambes écartées en grand",
            "x": 260,
            "y": 733
          }
        ],
        "de": [
          {
            "text": "Hände auf und ab schwingen",
            "x": 460,
            "y": 61
          },
          {
            "text": "Körper leicht zur Seite",
            "x": 400,
            "y": 396
          },
          {
            "text": "Beine weit auseinandergestellt",
            "x": 260,
            "y": 733
          }
        ],
        "th": [
          {
            "text": "มือส่ายขึ้นลง",
            "x": 460,
            "y": 61
          },
          {
            "text": "ลำตัวเอียงเล็กน้อย",
            "x": 400,
            "y": 396
          },
          {
            "text": "ขากว้างก้าวออก",
            "x": 260,
            "y": 733
          }
        ],
        "pt": [
          {
            "text": "mãos balançando para cima e para baixo",
            "x": 460,
            "y": 61
          },
          {
            "text": "corpo levemente de lado",
            "x": 400,
            "y": 396
          },
          {
            "text": "pernas afastadas em passada larga",
            "x": 260,
            "y": 733
          }
        ],
        "es": [
          {
            "text": "manos balanceándose arriba y abajo",
            "x": 460,
            "y": 61
          },
          {
            "text": "cuerpo ligeramente de lado",
            "x": 400,
            "y": 396
          },
          {
            "text": "piernas separadas en zancada",
            "x": 260,
            "y": 733
          }
        ],
        "tr": [
          {
            "text": "eller yukarı aşağı sallanma",
            "x": 460,
            "y": 61
          },
          {
            "text": "gövde hafif yana",
            "x": 400,
            "y": 396
          },
          {
            "text": "bacaklar büyük adımla açık",
            "x": 260,
            "y": 733
          }
        ]
      }
    },
    {
      "id": "pose_009",
      "name": "双腿分开顶胯",
      "nameI18n": {
        "en": "Legs apart, hip thrust",
        "zh_Hant": "雙腿分開頂胯"
      },
      "imageAsset": "assets/poses/pose_009.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "双手分开",
          "x": 214,
          "y": 46
        },
        {
          "text": "身体微倾顶跨",
          "x": 70,
          "y": 430
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Arms apart",
            "x": 214,
            "y": 46
          },
          {
            "text": "Body leaning, hip thrust",
            "x": 70,
            "y": 430
          }
        ],
        "zh_Hant": [
          {
            "text": "雙手分開",
            "x": 214,
            "y": 46
          },
          {
            "text": "身體微傾頂跨",
            "x": 70,
            "y": 430
          }
        ],
        "ja": [
          {
            "text": "両手を開く",
            "x": 214,
            "y": 46
          },
          {
            "text": "体を軽く傾け、腰を突き出す",
            "x": 70,
            "y": 430
          }
        ],
        "ko": [
          {
            "text": "두 손 벌리기",
            "x": 214,
            "y": 46
          },
          {
            "text": "몸 살짝 기울여 엉덩이 내밀기",
            "x": 70,
            "y": 430
          }
        ],
        "fr": [
          {
            "text": "mains écartées",
            "x": 214,
            "y": 46
          },
          {
            "text": "corps légèrement penché, bassin en avant",
            "x": 70,
            "y": 430
          }
        ],
        "de": [
          {
            "text": "Hände auseinander",
            "x": 214,
            "y": 46
          },
          {
            "text": "Körper leicht geneigt, Hüfte raus",
            "x": 70,
            "y": 430
          }
        ],
        "th": [
          {
            "text": "มือแยกกัน",
            "x": 214,
            "y": 46
          },
          {
            "text": "ลำตัวเอียงเล็กน้อย เตะเขยิบสะโพก",
            "x": 70,
            "y": 430
          }
        ],
        "pt": [
          {
            "text": "mãos separadas",
            "x": 214,
            "y": 46
          },
          {
            "text": "corpo levemente inclinado, quadril à frente",
            "x": 70,
            "y": 430
          }
        ],
        "es": [
          {
            "text": "manos separadas",
            "x": 214,
            "y": 46
          },
          {
            "text": "cuerpo ligeramente inclinado, cadera hacia afuera",
            "x": 70,
            "y": 430
          }
        ],
        "tr": [
          {
            "text": "eller ayrı",
            "x": 214,
            "y": 46
          },
          {
            "text": "gövde hafif eğik, kalça çıkık",
            "x": 70,
            "y": 430
          }
        ]
      }
    },
    {
      "id": "pose_010",
      "name": "双手遮眼身体倾斜",
      "nameI18n": {
        "en": "Hands over eyes, body leaning",
        "zh_Hant": "雙手遮眼身體傾斜"
      },
      "imageAsset": "assets/poses/pose_010.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "双手遮眼",
          "x": 220,
          "y": 25
        },
        {
          "text": "身体倾斜",
          "x": 476,
          "y": 367
        },
        {
          "text": "双腿大步分开",
          "x": 267,
          "y": 821
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Hands over eyes",
            "x": 220,
            "y": 25
          },
          {
            "text": "Body leaning",
            "x": 476,
            "y": 367
          },
          {
            "text": "Legs apart, wide stance",
            "x": 267,
            "y": 821
          }
        ],
        "zh_Hant": [
          {
            "text": "雙手遮眼",
            "x": 220,
            "y": 25
          },
          {
            "text": "身體傾斜",
            "x": 476,
            "y": 367
          },
          {
            "text": "雙腿大步分開",
            "x": 267,
            "y": 821
          }
        ],
        "ja": [
          {
            "text": "両手で目を隠す",
            "x": 220,
            "y": 25
          },
          {
            "text": "体を傾ける",
            "x": 476,
            "y": 367
          },
          {
            "text": "両足を大きく開く",
            "x": 267,
            "y": 821
          }
        ],
        "ko": [
          {
            "text": "두 손으로 눈 가리기",
            "x": 220,
            "y": 25
          },
          {
            "text": "몸 기울이기",
            "x": 476,
            "y": 367
          },
          {
            "text": "두 다리 크게 벌리기",
            "x": 267,
            "y": 821
          }
        ],
        "fr": [
          {
            "text": "mains sur les yeux",
            "x": 220,
            "y": 25
          },
          {
            "text": "corps penché",
            "x": 476,
            "y": 367
          },
          {
            "text": "jambes écartées en grand",
            "x": 267,
            "y": 821
          }
        ],
        "de": [
          {
            "text": "Hände vor den Augen",
            "x": 220,
            "y": 25
          },
          {
            "text": "Körper geneigt",
            "x": 476,
            "y": 367
          },
          {
            "text": "Beine weit auseinandergestellt",
            "x": 267,
            "y": 821
          }
        ],
        "th": [
          {
            "text": "มือบังตา",
            "x": 220,
            "y": 25
          },
          {
            "text": "ลำตัวเอียง",
            "x": 476,
            "y": 367
          },
          {
            "text": "ขากว้างก้าวออก",
            "x": 267,
            "y": 821
          }
        ],
        "pt": [
          {
            "text": "mãos sobre os olhos",
            "x": 220,
            "y": 25
          },
          {
            "text": "corpo inclinado",
            "x": 476,
            "y": 367
          },
          {
            "text": "pernas afastadas em passada larga",
            "x": 267,
            "y": 821
          }
        ],
        "es": [
          {
            "text": "manos sobre los ojos",
            "x": 220,
            "y": 25
          },
          {
            "text": "cuerpo inclinado",
            "x": 476,
            "y": 367
          },
          {
            "text": "piernas separadas en zancada",
            "x": 267,
            "y": 821
          }
        ],
        "tr": [
          {
            "text": "eller gözlerde",
            "x": 220,
            "y": 25
          },
          {
            "text": "gövde eğik",
            "x": 476,
            "y": 367
          },
          {
            "text": "bacaklar büyük adımla açık",
            "x": 267,
            "y": 821
          }
        ]
      }
    },
    {
      "id": "pose_011",
      "name": "右手扶头顶胯",
      "nameI18n": {
        "en": "Right hand on head, hip out",
        "zh_Hant": "右手扶頭頂胯"
      },
      "imageAsset": "assets/poses/pose_011.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "右手扶头",
          "x": 380,
          "y": 112
        },
        {
          "text": "左手插兜顶跨",
          "x": 403,
          "y": 421
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Right hand on head",
            "x": 380,
            "y": 112
          },
          {
            "text": "Left hand in pocket, hip out",
            "x": 403,
            "y": 421
          }
        ],
        "zh_Hant": [
          {
            "text": "右手扶頭",
            "x": 380,
            "y": 112
          },
          {
            "text": "左手插兜頂跨",
            "x": 403,
            "y": 421
          }
        ],
        "ja": [
          {
            "text": "右手で頭を支える",
            "x": 380,
            "y": 112
          },
          {
            "text": "左手をポケットに、腰を突き出す",
            "x": 403,
            "y": 421
          }
        ],
        "ko": [
          {
            "text": "오른손으로 머리 받치기",
            "x": 380,
            "y": 112
          },
          {
            "text": "왼손 주머니, 엉덩이 내밀기",
            "x": 403,
            "y": 421
          }
        ],
        "fr": [
          {
            "text": "main droite sur la tête",
            "x": 380,
            "y": 112
          },
          {
            "text": "main gauche dans la poche, bassin en avant",
            "x": 403,
            "y": 421
          }
        ],
        "de": [
          {
            "text": "rechte Hand auf dem Kopf",
            "x": 380,
            "y": 112
          },
          {
            "text": "linke Hand in der Tasche, Hüfte raus",
            "x": 403,
            "y": 421
          }
        ],
        "th": [
          {
            "text": "มือขวาประคองหัว",
            "x": 380,
            "y": 112
          },
          {
            "text": "มือซ้ายใส่กระเป๋า เตะเขยิบสะโพก",
            "x": 403,
            "y": 421
          }
        ],
        "pt": [
          {
            "text": "mão direita na cabeça",
            "x": 380,
            "y": 112
          },
          {
            "text": "mão esquerda no bolso, quadril à frente",
            "x": 403,
            "y": 421
          }
        ],
        "es": [
          {
            "text": "mano derecha en la cabeza",
            "x": 380,
            "y": 112
          },
          {
            "text": "mano izquierda en el bolsillo, cadera hacia afuera",
            "x": 403,
            "y": 421
          }
        ],
        "tr": [
          {
            "text": "sağ el başta",
            "x": 380,
            "y": 112
          },
          {
            "text": "sol el cebte, kalça çıkık",
            "x": 403,
            "y": 421
          }
        ]
      }
    },
    {
      "id": "pose_012",
      "name": "头歪双臂环抱",
      "nameI18n": {
        "en": "Head tilted, arms crossed",
        "zh_Hant": "頭歪雙臂環抱"
      },
      "imageAsset": "assets/poses/pose_012.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "头微歪",
          "x": 352,
          "y": 81
        },
        {
          "text": "双臂环抱",
          "x": 472,
          "y": 360
        },
        {
          "text": "一脚抬起",
          "x": 5,
          "y": 722
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Head slightly tilted",
            "x": 352,
            "y": 81
          },
          {
            "text": "Arms wrapped",
            "x": 472,
            "y": 360
          },
          {
            "text": "One foot lifted",
            "x": 5,
            "y": 722
          }
        ],
        "zh_Hant": [
          {
            "text": "頭微歪",
            "x": 352,
            "y": 81
          },
          {
            "text": "雙臂環抱",
            "x": 472,
            "y": 360
          },
          {
            "text": "一腳抬起",
            "x": 5,
            "y": 722
          }
        ],
        "ja": [
          {
            "text": "首を少しかしげる",
            "x": 352,
            "y": 81
          },
          {
            "text": "両腕で体を抱える",
            "x": 472,
            "y": 360
          },
          {
            "text": "片足を上げる",
            "x": 5,
            "y": 722
          }
        ],
        "ko": [
          {
            "text": "고개 살짝 갸웃",
            "x": 352,
            "y": 81
          },
          {
            "text": "양팔로 감싸기",
            "x": 472,
            "y": 360
          },
          {
            "text": "한 발 들기",
            "x": 5,
            "y": 722
          }
        ],
        "fr": [
          {
            "text": "tête légèrement penchée",
            "x": 352,
            "y": 81
          },
          {
            "text": "bras entourant le corps",
            "x": 472,
            "y": 360
          },
          {
            "text": "un pied levé",
            "x": 5,
            "y": 722
          }
        ],
        "de": [
          {
            "text": "Kopf leicht schief",
            "x": 352,
            "y": 81
          },
          {
            "text": "Arme um den Körper geschlungen",
            "x": 472,
            "y": 360
          },
          {
            "text": "ein Fuß gehoben",
            "x": 5,
            "y": 722
          }
        ],
        "th": [
          {
            "text": "หัวเอียงเล็กน้อย",
            "x": 352,
            "y": 81
          },
          {
            "text": "แขนกอดรอบลำตัว",
            "x": 472,
            "y": 360
          },
          {
            "text": "ยกเท้าหนึ่ง",
            "x": 5,
            "y": 722
          }
        ],
        "pt": [
          {
            "text": "cabeça levemente inclinada",
            "x": 352,
            "y": 81
          },
          {
            "text": "braços rodeando o corpo",
            "x": 472,
            "y": 360
          },
          {
            "text": "um pé levantado",
            "x": 5,
            "y": 722
          }
        ],
        "es": [
          {
            "text": "cabeza ligeramente inclinada",
            "x": 352,
            "y": 81
          },
          {
            "text": "brazos rodeando el cuerpo",
            "x": 472,
            "y": 360
          },
          {
            "text": "un pie levantado",
            "x": 5,
            "y": 722
          }
        ],
        "tr": [
          {
            "text": "baş hafif yana",
            "x": 352,
            "y": 81
          },
          {
            "text": "kollar gövdeyi sarmış",
            "x": 472,
            "y": 360
          },
          {
            "text": "bir ayak kalkmış",
            "x": 5,
            "y": 722
          }
        ]
      }
    },
    {
      "id": "pose_013",
      "name": "歪头双手环抱胸前",
      "nameI18n": {
        "en": "Head tilted, arms crossed at chest",
        "zh_Hant": "歪頭雙手環抱胸前"
      },
      "imageAsset": "assets/poses/pose_013.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "侧头头发垂下",
          "x": 242,
          "y": 76
        },
        {
          "text": "双臂环抱",
          "x": 466,
          "y": 267
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Head turned, hair falling",
            "x": 242,
            "y": 76
          },
          {
            "text": "Arms wrapped",
            "x": 466,
            "y": 267
          }
        ],
        "zh_Hant": [
          {
            "text": "側頭頭髮垂下",
            "x": 242,
            "y": 76
          },
          {
            "text": "雙臂環抱",
            "x": 466,
            "y": 267
          }
        ],
        "ja": [
          {
            "text": "首を横に、髪を垂らす",
            "x": 242,
            "y": 76
          },
          {
            "text": "両腕で体を抱える",
            "x": 466,
            "y": 267
          }
        ],
        "ko": [
          {
            "text": "고개 옆으로 머리 늘어뜨리기",
            "x": 242,
            "y": 76
          },
          {
            "text": "양팔로 감싸기",
            "x": 466,
            "y": 267
          }
        ],
        "fr": [
          {
            "text": "tête penchée, cheveux tombants",
            "x": 242,
            "y": 76
          },
          {
            "text": "bras entourant le corps",
            "x": 466,
            "y": 267
          }
        ],
        "de": [
          {
            "text": "Kopf zur Seite, Haare fallend",
            "x": 242,
            "y": 76
          },
          {
            "text": "Arme um den Körper geschlungen",
            "x": 466,
            "y": 267
          }
        ],
        "th": [
          {
            "text": "หัวข้าง ผมร่วงลง",
            "x": 242,
            "y": 76
          },
          {
            "text": "แขนกอดรอบลำตัว",
            "x": 466,
            "y": 267
          }
        ],
        "pt": [
          {
            "text": "cabeça inclinada, cabelo caído",
            "x": 242,
            "y": 76
          },
          {
            "text": "braços rodeando o corpo",
            "x": 466,
            "y": 267
          }
        ],
        "es": [
          {
            "text": "cabeza inclinada, pelo caído",
            "x": 242,
            "y": 76
          },
          {
            "text": "brazos rodeando el cuerpo",
            "x": 466,
            "y": 267
          }
        ],
        "tr": [
          {
            "text": "baş yana, saç sarkmış",
            "x": 242,
            "y": 76
          },
          {
            "text": "kollar gövdeyi sarmış",
            "x": 466,
            "y": 267
          }
        ]
      }
    },
    {
      "id": "pose_014",
      "name": "背影头后敬礼",
      "nameI18n": {
        "en": "Back view, salute behind head",
        "zh_Hant": "背影頭後敬禮"
      },
      "imageAsset": "assets/poses/pose_014.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "头左转手敬礼",
          "x": 259,
          "y": 112
        },
        {
          "text": "背影",
          "x": 425,
          "y": 352
        },
        {
          "text": "腿分开",
          "x": 217,
          "y": 826
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Head turned left, salute",
            "x": 259,
            "y": 112
          },
          {
            "text": "From behind",
            "x": 425,
            "y": 352
          },
          {
            "text": "Legs apart",
            "x": 217,
            "y": 826
          }
        ],
        "zh_Hant": [
          {
            "text": "頭左轉手敬禮",
            "x": 259,
            "y": 112
          },
          {
            "text": "背影",
            "x": 425,
            "y": 352
          },
          {
            "text": "腿分開",
            "x": 217,
            "y": 826
          }
        ],
        "ja": [
          {
            "text": "頭を左に回し、手を挙げて敬礼",
            "x": 259,
            "y": 112
          },
          {
            "text": "後ろ姿",
            "x": 425,
            "y": 352
          },
          {
            "text": "足を開く",
            "x": 217,
            "y": 826
          }
        ],
        "ko": [
          {
            "text": "머리 왼쪽으로 돌려 손으로 경례",
            "x": 259,
            "y": 112
          },
          {
            "text": "뒷모습",
            "x": 425,
            "y": 352
          },
          {
            "text": "다리 벌리기",
            "x": 217,
            "y": 826
          }
        ],
        "fr": [
          {
            "text": "tête tournée à gauche, main en salut",
            "x": 259,
            "y": 112
          },
          {
            "text": "vue de dos",
            "x": 425,
            "y": 352
          },
          {
            "text": "jambes écartées",
            "x": 217,
            "y": 826
          }
        ],
        "de": [
          {
            "text": "Kopf nach links gedreht, Hand grüßt",
            "x": 259,
            "y": 112
          },
          {
            "text": "Rückenansicht",
            "x": 425,
            "y": 352
          },
          {
            "text": "Beine auseinander",
            "x": 217,
            "y": 826
          }
        ],
        "th": [
          {
            "text": "หัวหันซ้าย มือทรงเคารพ",
            "x": 259,
            "y": 112
          },
          {
            "text": "มุมหลัง",
            "x": 425,
            "y": 352
          },
          {
            "text": "ขาแยก",
            "x": 217,
            "y": 826
          }
        ],
        "pt": [
          {
            "text": "cabeça virada à esquerda, saudação com a mão",
            "x": 259,
            "y": 112
          },
          {
            "text": "de costas",
            "x": 425,
            "y": 352
          },
          {
            "text": "pernas separadas",
            "x": 217,
            "y": 826
          }
        ],
        "es": [
          {
            "text": "cabeza girada a la izquierda, saludo con la mano",
            "x": 259,
            "y": 112
          },
          {
            "text": "de espaldas",
            "x": 425,
            "y": 352
          },
          {
            "text": "piernas separadas",
            "x": 217,
            "y": 826
          }
        ],
        "tr": [
          {
            "text": "baş sola dönük, el selam",
            "x": 259,
            "y": 112
          },
          {
            "text": "arkadan görünüm",
            "x": 425,
            "y": 352
          },
          {
            "text": "bacaklar açık",
            "x": 217,
            "y": 826
          }
        ]
      }
    },
    {
      "id": "pose_015",
      "name": "双手上下比耶",
      "nameI18n": {
        "en": "Both hands peace sign, up and down",
        "zh_Hant": "雙手上下比耶"
      },
      "imageAsset": "assets/poses/pose_015.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [
        {
          "text": "举起比耶",
          "x": 205,
          "y": 85
        },
        {
          "text": "向下比耶",
          "x": 464,
          "y": 392
        },
        {
          "text": "一脚抬起独立",
          "x": 316,
          "y": 779
        }
      ],
      "tipsI18n": {
        "en": [
          {
            "text": "Peace sign raised",
            "x": 205,
            "y": 85
          },
          {
            "text": "Peace sign lowered",
            "x": 464,
            "y": 392
          },
          {
            "text": "One foot lifted, balance",
            "x": 316,
            "y": 779
          }
        ],
        "zh_Hant": [
          {
            "text": "舉起比耶",
            "x": 205,
            "y": 85
          },
          {
            "text": "向下比耶",
            "x": 464,
            "y": 392
          },
          {
            "text": "一腳抬起獨立",
            "x": 316,
            "y": 779
          }
        ],
        "ja": [
          {
            "text": "ピースを挙げる",
            "x": 205,
            "y": 85
          },
          {
            "text": "下にピース",
            "x": 464,
            "y": 392
          },
          {
            "text": "片足で立つ",
            "x": 316,
            "y": 779
          }
        ],
        "ko": [
          {
            "text": "브이 들기",
            "x": 205,
            "y": 85
          },
          {
            "text": "아래로 브이",
            "x": 464,
            "y": 392
          },
          {
            "text": "한 발로 서기",
            "x": 316,
            "y": 779
          }
        ],
        "fr": [
          {
            "text": "lever le signe de paix",
            "x": 205,
            "y": 85
          },
          {
            "text": "signe de paix vers le bas",
            "x": 464,
            "y": 392
          },
          {
            "text": "debout sur une jambe",
            "x": 316,
            "y": 779
          }
        ],
        "de": [
          {
            "text": "Peace-Zeichen heben",
            "x": 205,
            "y": 85
          },
          {
            "text": "Peace-Zeichen nach unten",
            "x": 464,
            "y": 392
          },
          {
            "text": "auf einem Bein stehend",
            "x": 316,
            "y": 779
          }
        ],
        "th": [
          {
            "text": "ยกสัญญาณวี",
            "x": 205,
            "y": 85
          },
          {
            "text": "สัญญาณวีลง",
            "x": 464,
            "y": 392
          },
          {
            "text": "ยืนขาเดียว",
            "x": 316,
            "y": 779
          }
        ],
        "pt": [
          {
            "text": "levantar o sinal de paz",
            "x": 205,
            "y": 85
          },
          {
            "text": "sinal de paz para baixo",
            "x": 464,
            "y": 392
          },
          {
            "text": "em pé sobre uma perna",
            "x": 316,
            "y": 779
          }
        ],
        "es": [
          {
            "text": "levantar el signo de paz",
            "x": 205,
            "y": 85
          },
          {
            "text": "signo de paz hacia abajo",
            "x": 464,
            "y": 392
          },
          {
            "text": "de pie sobre una pierna",
            "x": 316,
            "y": 779
          }
        ],
        "tr": [
          {
            "text": "V işareti kaldırma",
            "x": 205,
            "y": 85
          },
          {
            "text": "aşağı V işareti",
            "x": 464,
            "y": 392
          },
          {
            "text": "tek ayak üzerinde durma",
            "x": 316,
            "y": 779
          }
        ]
      }
    },
    {
      "id": "pose_016",
      "name": "双手前伸比耶腿后抬",
      "nameI18n": {
        "en": "Hands forward peace sign, leg back",
        "zh_Hant": "雙手前伸比耶腿後抬"
      },
      "imageAsset": "assets/poses/pose_016.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_017",
      "name": "一手比耶一手叉腰",
      "nameI18n": {
        "en": "One peace sign, one hand on hip",
        "zh_Hant": "一手比耶一手叉腰"
      },
      "imageAsset": "assets/poses/pose_017.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_018",
      "name": "一手眼前比圈拉头发",
      "nameI18n": {
        "en": "One hand circle before eyes, fixing hair",
        "zh_Hant": "一手眼前比圈拉頭髮"
      },
      "imageAsset": "assets/poses/pose_018.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_019",
      "name": "双手上下脚并拢",
      "nameI18n": {
        "en": "Hands up and down, feet together",
        "zh_Hant": "雙手上下腳併攏"
      },
      "imageAsset": "assets/poses/pose_019.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_020",
      "name": "侧身踢腿双手比耶",
      "nameI18n": {
        "en": "Side kick, both hands peace sign",
        "zh_Hant": "側身踢腿雙手比耶"
      },
      "imageAsset": "assets/poses/pose_020.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_021",
      "name": "叉腰侧腿",
      "nameI18n": {
        "en": "Hands on hips, leg to side",
        "zh_Hant": "叉腰側腿"
      },
      "imageAsset": "assets/poses/pose_021.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_022",
      "name": "歪头双手合十侧抬腿",
      "nameI18n": {
        "en": "Head tilted, palms together, leg raised",
        "zh_Hant": "歪頭雙手合十側抬腿"
      },
      "imageAsset": "assets/poses/pose_022.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_023",
      "name": "低头",
      "nameI18n": {
        "en": "Head down",
        "zh_Hant": "低頭"
      },
      "imageAsset": "assets/poses/pose_023.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_024",
      "name": "下巴比耶叉腰",
      "nameI18n": {
        "en": "Chin up peace sign, hands on hips",
        "zh_Hant": "下巴比耶叉腰"
      },
      "imageAsset": "assets/poses/pose_024.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_025",
      "name": "双手比耶侧踢腿",
      "nameI18n": {
        "en": "Both hands peace sign, side kick",
        "zh_Hant": "雙手比耶側踢腿"
      },
      "imageAsset": "assets/poses/pose_025.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_026",
      "name": "一手眼前比耶侧踢腿",
      "nameI18n": {
        "en": "One hand peace sign before eyes, side kick",
        "zh_Hant": "一手眼前比耶側踢腿"
      },
      "imageAsset": "assets/poses/pose_026.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_027",
      "name": "撩发双腿交叉",
      "nameI18n": {
        "en": "Flipping hair, legs crossed",
        "zh_Hant": "撩發雙腿交叉"
      },
      "imageAsset": "assets/poses/pose_027.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_028",
      "name": "双手伸展右腿抬起",
      "nameI18n": {
        "en": "Arms stretched, right leg raised",
        "zh_Hant": "雙手伸展右腿抬起"
      },
      "imageAsset": "assets/poses/pose_028.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_029",
      "name": "单膝站立双手摆动",
      "nameI18n": {
        "en": "Standing on one knee, hands swaying",
        "zh_Hant": "單膝站立雙手擺動"
      },
      "imageAsset": "assets/poses/pose_029.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_030",
      "name": "一手插兜双腿叉开",
      "nameI18n": {
        "en": "One hand in pocket, legs apart",
        "zh_Hant": "一手插兜雙腿叉開"
      },
      "imageAsset": "assets/poses/pose_030.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_031",
      "name": "双手顶头身体倾斜",
      "nameI18n": {
        "en": "Hands on head, body leaning",
        "zh_Hant": "雙手頂頭身體傾斜"
      },
      "imageAsset": "assets/poses/pose_031.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_032",
      "name": "头上比耶一脚抬起",
      "nameI18n": {
        "en": "Peace sign on head, one foot raised",
        "zh_Hant": "頭上比耶一腳抬起"
      },
      "imageAsset": "assets/poses/pose_032.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_033",
      "name": "叉腰回头双腿分开",
      "nameI18n": {
        "en": "Hands on hips, looking back, legs apart",
        "zh_Hant": "叉腰回頭雙腿分開"
      },
      "imageAsset": "assets/poses/pose_033.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_034",
      "name": "双手比耶踢腿",
      "nameI18n": {
        "en": "Both hands peace sign, kicking",
        "zh_Hant": "雙手比耶踢腿"
      },
      "imageAsset": "assets/poses/pose_034.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_035",
      "name": "伸手比耶蹲姿",
      "nameI18n": {
        "en": "Arm extended peace sign, squat",
        "zh_Hant": "伸手比耶蹲姿"
      },
      "imageAsset": "assets/poses/pose_035.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_036",
      "name": "侧头双手后撑",
      "nameI18n": {
        "en": "Head to side, hands bracing behind",
        "zh_Hant": "側頭雙手後撐"
      },
      "imageAsset": "assets/poses/pose_036.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_037",
      "name": "回头双手比耶",
      "nameI18n": {
        "en": "Looking back, both hands peace sign",
        "zh_Hant": "回頭雙手比耶"
      },
      "imageAsset": "assets/poses/pose_037.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_038",
      "name": "侧身比耶回头",
      "nameI18n": {
        "en": "Side peace sign, looking back",
        "zh_Hant": "側身比耶回頭"
      },
      "imageAsset": "assets/poses/pose_038.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_039",
      "name": "摸帽一手撑包",
      "nameI18n": {
        "en": "Touching hat, one hand on bag",
        "zh_Hant": "摸帽一手撐包"
      },
      "imageAsset": "assets/poses/pose_039.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_040",
      "name": "侧身比耶后抬腿",
      "nameI18n": {
        "en": "Side peace sign, leg raised back",
        "zh_Hant": "側身比耶後抬腿"
      },
      "imageAsset": "assets/poses/pose_040.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_041",
      "name": "双手遮阳侧伸腿",
      "nameI18n": {
        "en": "Hands shading sun, leg extended sideways",
        "zh_Hant": "雙手遮陽側伸腿"
      },
      "imageAsset": "assets/poses/pose_041.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    },
    {
      "id": "pose_042",
      "name": "捂脸后摆抬腿",
      "nameI18n": {
        "en": "Hands covering face, leg swinging back",
        "zh_Hant": "捂臉後襬抬腿"
      },
      "imageAsset": "assets/poses/pose_042.png",
      "designWidth": 570,
      "designHeight": 760,
      "keyPoints": [],
      "tips": [],
      "tipsI18n": {
        "en": [],
        "zh_Hant": [],
        "ja": [],
        "ko": [],
        "fr": [],
        "de": [],
        "th": [],
        "pt": [],
        "es": [],
        "tr": []
      }
    }
  ]
}
''';

/// 解析内置默认姿势数据包（单机版唯一数据源）。
///
/// [lang] 为多语言选取短码（en / zh / zh_Hant / ja / ...），按
/// nameI18n / tipsI18n / 风格 nameI18n 就近选取，缺失回退默认中文。
PoseResult parseDefaultPoseResult({String lang = 'zh'}) =>
    PoseResult.fromJson(jsonDecode(kDefaultPoseJson) as Map<String, dynamic>,
        lang: lang);
