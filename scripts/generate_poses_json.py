r"""
按 image/ 文件夹生成 WSL poses.json 的 poses 数组，并把完整 JSON 写到：
- WSL : \\wsl$\Ubuntu\www\wwwroot\task-api\storage\photo_assistant\poses.json
- 本地: D:\work\photo-assistant\scripts\_generated_poses.json（调试副本，不要放 assets/ 下以免被打包进 app）
- Dart: D:\work\photo-assistant\lib\poses\pose_data.dart（离线兜底，与 WSL 保持一致）

重要：每条姿势都会带 tips（摆姿文字提示）。
  - 默认通用占位提示（所有姿势先用这一条，后续可逐条改写）。
  - TIPS_OVERRIDE 里可放个别姿势的专用提示，覆盖通用占位。
  - 若现有 poses.json 里某 pose 已手写 tips，会优先保留，避免重新生成时丢失。
这样以后再来批量重跑本脚本，tips 不会被抹掉。
"""
import json, re, glob, os

# 简->繁（台湾用词）转换；用于生成接口数据的 zh_Hant 多语言。
# 仅在隔离 venv（含 opencc-python-reimplemented）下运行本脚本才会真正转换，
# 否则回退为恒等（仅输出简体，并打印警告）。
try:
    from opencc import OpenCC
    _cc = OpenCC("s2twp")
    def to_traditional(s):
        return _cc.convert(s) if isinstance(s, str) else s
except Exception:  # pragma: no cover
    def to_traditional(s):
        return s
    print("[警告] 未检测到 opencc，zh_Hant 将回退为简体（请使用含 opencc 的 venv 运行）")

from pose_i18n_extra import EXTRA_LANGS, EXTRA_STYLE_NAMES, EXTRA_TIP_TRANS

WSL = r"\\wsl$\Ubuntu\www\wwwroot\task-api\storage\photo_assistant\poses.json"
SRC = r"D:\work\photo-assistant\image"
LOCAL = r"D:\work\photo-assistant\scripts\_generated_poses.json"
DART = r"D:\work\photo-assistant\lib\poses\pose_data.dart"

# 通用占位提示（所有姿势先用这一条，后续可逐条改写）
GENERIC_TIPS = ["请参照示意图，摆出对应姿势"]
# 个别姿势的专用提示（覆盖通用占位）。
# 每条 tip 形如 {"text": "提示文字", "x": 设计空间 x, "y": 设计空间 y}，
# 也支持纯字符串（无坐标，按默认位置居中显示）。
# 设计空间：图片姿势为 570x760（PNG 宽高比 0.75）。
TIPS_OVERRIDE = {
    "pose_001": [
        {"text": "【侧身微笑】位置在左肩", "x": 180, "y": 230},
        {"text": "【腿抬起】位置在左腿膝盖", "x": 340, "y": 440},
    ],
}

# ---- 接口数据多语言（AI 初稿，待母语校对）----
# 仅先出英文；其余语言后续按需在 generate_poses_json 增补。
# 中文名恒为默认 `name`，按 lang 取 `nameI18n[lang] ?? name`。
EN_GENERIC_TIP = "Please follow the illustration and strike the corresponding pose"
# 个别姿势的英文提示 override（覆盖 en 留空）。
# 每条 tip 形如 {"text": 英文, "x": 设计空间 x, "y": 设计空间 y}，
# x/y 必须与 base / zh_Hant 的同一 tip 一致，气泡定位才不会错位。
# 仅对“有真实摆姿指导”的姿势（pose_001~015）给出英文；其余 27 条通用占位
# 姿势 en 仍留空（不显示无意义英文）。
EN_TIPS_OVERRIDE = {
    "pose_001": [
        {"text": "Smile — at left shoulder", "x": 180, "y": 230},
        {"text": "Raise leg — at left knee", "x": 340, "y": 440},
    ],
    "pose_002": [
        {"text": "One hand shading hat", "x": 322, "y": 220},
        {"text": "Peace sign forward", "x": 452, "y": 380},
        {"text": "Turn to side", "x": 78, "y": 584},
        {"text": "Foot extended forward", "x": 410, "y": 750},
    ],
    "pose_003": [
        {"text": "One arm raised sideways", "x": 400, "y": 186},
        {"text": "Side kick", "x": 129, "y": 658},
    ],
    "pose_004": [
        {"text": "Pulling hair", "x": 209, "y": 223},
        {"text": "Sitting, head tilted", "x": 277, "y": 415},
    ],
    "pose_005": [
        {"text": "Holding bag", "x": 114, "y": 280},
        {"text": "Pulling hair", "x": 400, "y": 333},
        {"text": "Legs crossed", "x": 360, "y": 700},
    ],
    "pose_006": [
        {"text": "Both hands in hair", "x": 364, "y": 229},
        {"text": "Bend to the side", "x": 208, "y": 556},
        {"text": "Toes pointing up", "x": 138, "y": 745},
    ],
    "pose_007": [
        {"text": "Head down", "x": 319, "y": 172},
        {"text": "Arms crossed at chest", "x": 350, "y": 388},
        {"text": "Legs crossed", "x": 322, "y": 686},
    ],
    "pose_008": [
        {"text": "Hands moving up and down", "x": 460, "y": 61},
        {"text": "Body slightly turned", "x": 400, "y": 396},
        {"text": "Legs apart, wide stance", "x": 260, "y": 733},
    ],
    "pose_009": [
        {"text": "Arms apart", "x": 214, "y": 46},
        {"text": "Body leaning, hip thrust", "x": 70, "y": 430},
    ],
    "pose_010": [
        {"text": "Hands over eyes", "x": 220, "y": 25},
        {"text": "Body leaning", "x": 476, "y": 367},
        {"text": "Legs apart, wide stance", "x": 267, "y": 821},
    ],
    "pose_011": [
        {"text": "Right hand on head", "x": 380, "y": 112},
        {"text": "Left hand in pocket, hip out", "x": 403, "y": 421},
    ],
    "pose_012": [
        {"text": "Head slightly tilted", "x": 352, "y": 81},
        {"text": "Arms wrapped", "x": 472, "y": 360},
        {"text": "One foot lifted", "x": 5, "y": 722},
    ],
    "pose_013": [
        {"text": "Head turned, hair falling", "x": 242, "y": 76},
        {"text": "Arms wrapped", "x": 466, "y": 267},
    ],
    "pose_014": [
        {"text": "Head turned left, salute", "x": 259, "y": 112},
        {"text": "From behind", "x": 425, "y": 352},
        {"text": "Legs apart", "x": 217, "y": 826},
    ],
    "pose_015": [
        {"text": "Peace sign raised", "x": 205, "y": 85},
        {"text": "Peace sign lowered", "x": 464, "y": 392},
        {"text": "One foot lifted, balance", "x": 316, "y": 779},
    ],
}
EN_NAMES = {
    "pose_001": "Side smile, leg raised",
    "pose_002": "One hand shading hat, peace sign forward",
    "pose_003": "One arm extended, side kick",
    "pose_004": "Sitting, head tilted, fixing hair",
    "pose_005": "Holding bag, fixing hair, crossed legs",
    "pose_006": "Both hands in hair, bending sideways",
    "pose_007": "Head down, arms wrapped",
    "pose_008": "Hands up and down, legs apart",
    "pose_009": "Legs apart, hip thrust",
    "pose_010": "Hands over eyes, body leaning",
    "pose_011": "Right hand on head, hip out",
    "pose_012": "Head tilted, arms crossed",
    "pose_013": "Head tilted, arms crossed at chest",
    "pose_014": "Back view, salute behind head",
    "pose_015": "Both hands peace sign, up and down",
    "pose_016": "Hands forward peace sign, leg back",
    "pose_017": "One peace sign, one hand on hip",
    "pose_018": "One hand circle before eyes, fixing hair",
    "pose_019": "Hands up and down, feet together",
    "pose_020": "Side kick, both hands peace sign",
    "pose_021": "Hands on hips, leg to side",
    "pose_022": "Head tilted, palms together, leg raised",
    "pose_023": "Head down",
    "pose_024": "Chin up peace sign, hands on hips",
    "pose_025": "Both hands peace sign, side kick",
    "pose_026": "One hand peace sign before eyes, side kick",
    "pose_027": "Flipping hair, legs crossed",
    "pose_028": "Arms stretched, right leg raised",
    "pose_029": "Standing on one knee, hands swaying",
    "pose_030": "One hand in pocket, legs apart",
    "pose_031": "Hands on head, body leaning",
    "pose_032": "Peace sign on head, one foot raised",
    "pose_033": "Hands on hips, looking back, legs apart",
    "pose_034": "Both hands peace sign, kicking",
    "pose_035": "Arm extended peace sign, squat",
    "pose_036": "Head to side, hands bracing behind",
    "pose_037": "Looking back, both hands peace sign",
    "pose_038": "Side peace sign, looking back",
    "pose_039": "Touching hat, one hand on bag",
    "pose_040": "Side peace sign, leg raised back",
    "pose_041": "Hands shading sun, leg extended sideways",
    "pose_042": "Hands covering face, leg swinging back",
}
# 风格名多语言（仅英文初稿）
EN_STYLE_NAMES = {
    "无光影": "No lighting",
    "极简单线": "Minimal single line",
    "蓝调描边": "Blue outline",
    "霓虹": "Neon",
    "柔光暖黄": "Soft warm yellow",
}

# ---- 兜底：`none`（无光影）风格规范定义 ----
# 该风格曾在某次重跑/后端重写 poses.json 时整块丢失，导致 activeStyle='none'
# 指向不存在的风格，App 回退到 styles.values.first（minimal）。
# 这里把规范定义固化进脚本，缺失时自动补回，避免再次回归。
# 依据 2026-08-27 备忘：外框 #0A0E14 + 内线 #FFFFFF，tint 为 null（不染色=无光影），
# 双层描边（不设 singleLayer）。
NONE_STYLE = {
    "name": "无光影",
    "tint": None,
    "outerColor": "#0A0E14",
    "outerWidth": 4.0,
    "innerColor": "#FFFFFF",
    "innerWidth": 2.0,
    "glow": False,
    "glowColor": "#FFFFFF",
    "glowBlur": 0.0,
    "fillColor": "#FFFFFF",
    "fillOpacity": 0.05,
    "showKeyPoints": False,
    "keyPointColor": "#FFFFFF",
    "keyPointRadius": 3.0,
    "keyPointGlow": False,
    "showTips": True,
    "nameI18n": {"en": "No lighting"},
}

# 读取现有 WSL JSON 以保留 styles / thumbnail / activeStyle 等配置
with open(WSL, "r", encoding="utf-8") as f:
    data = json.load(f)

# 兜底：若 `none`（无光影）风格缺失则补回规范定义
styles = data.setdefault("styles", {})
if "none" not in styles:
    styles["none"] = dict(NONE_STYLE)
    print("[兜底] 已补回缺失的 none（无光影）风格")

# 兜底：activeStyle 必须指向存在的风格，否则回落到默认的 'none'
if data.get("activeStyle") not in styles:
    data["activeStyle"] = "none"
    print("[兜底] activeStyle 指向不存在的风格，已回落到 'none'")

# 保留现有 poses 里已手写的 tips（按 id 索引），避免重新生成时丢失
existing_tips = {}
for p in data.get("poses", []):
    if isinstance(p, dict) and p.get("tips"):
        existing_tips[p.get("id")] = p["tips"]

# 按文件名 001_xxx.png 顺序生成 42 条 imageAsset 姿势
poses = []
for path in sorted(glob.glob(os.path.join(SRC, "*.png"))):
    name = os.path.basename(path)
    m = re.match(r"(\d{3})_(.+)\.png", name)
    if not m:
        continue
    num, pname = m.group(1), m.group(2)
    pid = f"pose_{num}"
    tips = TIPS_OVERRIDE.get(pid) or existing_tips.get(pid) or list(GENERIC_TIPS)
    # 真实英文提示：仅当存在专门 override 时才给，否则留空——
    # 不再回退到无意义的 "Please follow the illustration..." 通用占位文案。
    en_tips = list(EN_TIPS_OVERRIDE.get(pid) or [])

    # 若该姿势仅含通用占位提示（无实际摆姿指导），则清空所有语言的 tips，
    # 避免界面显示无意义的“请参照示意图”/“Please follow the illustration...”。
    if tips == GENERIC_TIPS:
        tips = []
        en_tips = []

    # 繁体 tips：保留 dict 结构（text/x/y），仅转换 text；纯字符串则直接转换。
    zh_hant_tips = []
    for t in tips:
        if isinstance(t, dict):
            d = dict(t)
            d["text"] = to_traditional(t.get("text", ""))
            zh_hant_tips.append(d)
        elif isinstance(t, str):
            zh_hant_tips.append(to_traditional(t))
        else:
            zh_hant_tips.append(t)

    # 8 种语言的提示：仅替换文字，保留 base tip 的坐标(x/y)
    tipsI18n = {"en": en_tips, "zh_Hant": zh_hant_tips}
    for lang in EXTRA_LANGS:
        trans = []
        for t in tips:
            if isinstance(t, dict):
                d = dict(t)
                d["text"] = EXTRA_TIP_TRANS.get(t.get("text", ""), {}).get(lang, t.get("text", ""))
                trans.append(d)
            elif isinstance(t, str):
                trans.append(EXTRA_TIP_TRANS.get(t, {}).get(lang, t))
            else:
                trans.append(t)
        tipsI18n[lang] = trans

    poses.append({
        "id": pid,
        "name": pname,
        "nameI18n": {"en": EN_NAMES.get(pid, pname), "zh_Hant": to_traditional(pname)},
        "imageAsset": f"assets/poses/pose_{num}.png",
        # 源图 1728x2304，宽高比 0.75，归一为 570x760 让所有姿势在屏幕缩放一致
        "designWidth": 570,
        "designHeight": 760,
        # 图片姿势无 SVG 路径，置空避免 deriveKeyPoints 推出 (0,0) 杂点
        "keyPoints": [],
        "tips": tips,
        "tipsI18n": tipsI18n,
    })

data["poses"] = poses

# 风格名多语言（英文 + 繁体 + 8 语言）
for sid, style in data.get("styles", {}).items():
    if isinstance(style, dict) and isinstance(style.get("name"), str):
        zh = style["name"]
        ni = {
            "en": EN_STYLE_NAMES.get(zh, zh),
            "zh_Hant": to_traditional(zh),
        }
        if zh in EXTRA_STYLE_NAMES:
            for lang in EXTRA_LANGS:
                if lang in EXTRA_STYLE_NAMES[zh]:
                    ni[lang] = EXTRA_STYLE_NAMES[zh][lang]
        style["nameI18n"] = ni

# 写 WSL
with open(WSL, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")

# 写本地副本（调试用）
with open(LOCAL, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")

# 写 Dart 离线兜底（保持与 WSL 一致）
dart_header = (
    "import 'dart:convert';\n\n"
    "import 'pose_library.dart';\n\n"
    "/// 内置默认姿势数据包（单机版唯一数据源，等效原服务端契约）。\n"
    "/// 由 scripts/generate_poses_json.py 从 image/ 生成，并与 WSL 源 / 本地副本保持同步。\n"
    "/// 全部 42 条姿势均为 imageAsset 透明 PNG（来自 D:\\work\\photo-assistant\\image），\n"
    "/// 不再携带 SVG 路径（paths / headRect / parts）数据。\n"
    "/// 每条姿势带 tips 摆姿文字提示；无实际指导的姿势 tips 为空数组，不显示无意义占位文案。\n"
    "const String kDefaultPoseJson = r'''\n"
)
dart_footer = (
    "\n''';"
    "\n\n"
    "/// 解析内置默认姿势数据包（单机版唯一数据源）。\n"
    "///\n"
    "/// [lang] 为多语言选取短码（en / zh / zh_Hant / ja / ...），按\n"
    "/// nameI18n / tipsI18n / 风格 nameI18n 就近选取，缺失回退默认中文。\n"
    "PoseResult parseDefaultPoseResult({String lang = 'zh'}) =>\n"
    "    PoseResult.fromJson(jsonDecode(kDefaultPoseJson) as Map<String, dynamic>,\n"
    "        lang: lang);\n"
)
with open(DART, "w", encoding="utf-8") as f:
    f.write(dart_header)
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write(dart_footer)

print(f"已生成 {len(poses)} 条姿势（均带 tips）")
print(f"  WSL : {WSL}")
print(f"  本地: {LOCAL}")
print(f"  Dart: {DART}")
print(f"  活动风格: {data.get('activeStyle')}, 风格数: {len(data.get('styles', {}))}")
print(f"  pose_001 tips: {poses[0]['tips']}")
