#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Add the `iapProductMissing` key to every locale arb (inserted after storeUnavailable)."""
import json
import os

L10N_DIR = r"D:\work\photo-assistant\lib\l10n"

TR = {
    "en": "In-app purchase not found. In App Store Connect, attach 'pro_unlock' to this version and submit for review.",
    "zh": "未找到内购商品：请在 App Store Connect 把 pro_unlock 关联到本版本并提交审核。",
    "zh_Hant": "未找到內購商品：請在 App Store Connect 把 pro_unlock 關聯到本版本並提交審核。",
    "ja": "アプリ内購入が見つかりません。App Store Connect で pro_unlock をこのバージョンに紐づけ、審査に提出してください。",
    "ko": "인앱 결제를 찾을 수 없습니다. App Store Connect에서 pro_unlock을 이 버전에 연결하고 심사에 제출하세요.",
    "fr": "Achat intégré introuvable. Dans App Store Connect, associez « pro_unlock » à cette version et soumettez-la pour révision.",
    "de": "In-App-Kauf nicht gefunden. Verknüpfen Sie in App Store Connect „pro_unlock“ mit dieser Version und reichen Sie sie zur Prüfung ein.",
    "th": "ไม่พบการซื้อในแอป โปรดผูก pro_unlock กับเวอร์ชันนี้ใน App Store Connect และส่งเข้าระบบตรวจสอบ",
    "pt": "Compra integrada não encontrada. No App Store Connect, associe o „pro_unlock“ a esta versão e envie para revisão.",
    "es": "No se encontró la compra integrada. En App Store Connect, vincula «pro_unlock» a esta versión y envíala a revisión.",
    "tr": "Uygulama içi satın alma bulunamadı. App Store Connect'te pro_unlock ürününü bu sürüme bağlayıp incelemeye gönderin.",
}

for locale, text in TR.items():
    path = os.path.join(L10N_DIR, f"intl_{locale}.arb")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f, object_pairs_hook=dict)
    if "iapProductMissing" in data:
        print(f"[skip] {locale}: already present")
        continue
    new_data = {}
    inserted = False
    for k, v in data.items():
        new_data[k] = v
        if k == "storeUnavailable" and not inserted:
            new_data["iapProductMissing"] = text
            inserted = True
    if not inserted:
        new_data["iapProductMissing"] = text
    with open(path, "w", encoding="utf-8") as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"[done] {locale}")
