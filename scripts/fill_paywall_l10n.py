#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fill the 9 purchase/paywall I10n keys into the 9 locales that lack them.

Keys (value + needed @metadata):
  unlockAllPoses
  unlockAllPosesBody   (placeholder: count:String)
  buyForPrice          (placeholder: price:String)
  restorePurchase
  purchasePending
  purchaseSuccess
  purchaseRestored
  purchaseFailed       (placeholder: error:String)
  storeUnavailable
"""
import json
import os

L10N_DIR = r"D:\work\photo-assistant\lib\l10n"

# Translations per locale. Order matches the block inserted after "back".
TR = {
    "zh_Hant": {
        "unlockAllPoses": "解鎖全部姿勢",
        "unlockAllPosesBody": "再解鎖 {count} 個姿勢，包含每種風格。一次購買，永久使用。",
        "buyForPrice": "解鎖 — {price}",
        "restorePurchase": "恢復購買",
        "purchasePending": "購買處理中…",
        "purchaseSuccess": "已全部解鎖",
        "purchaseRestored": "購買已恢復",
        "purchaseFailed": "購買失敗：{error}",
        "storeUnavailable": "商店暫不可用，請稍後再試。",
    },
    "ja": {
        "unlockAllPoses": "すべてのポーズのロックを解除",
        "unlockAllPosesBody": "すべてのスタイルのポーズがあと {count} 種類ロック解除できます。一度の購入で永久にご利用いただけます。",
        "buyForPrice": "ロック解除 — {price}",
        "restorePurchase": "購入を復元",
        "purchasePending": "購入処理中…",
        "purchaseSuccess": "すべてのポーズが解除されました",
        "purchaseRestored": "購入を復元しました",
        "purchaseFailed": "購入に失敗しました：{error}",
        "storeUnavailable": "ストアは利用できません。後ほど再度お試しください。",
    },
    "ko": {
        "unlockAllPoses": "모든 포즈 잠금 해제",
        "unlockAllPosesBody": "모든 스타일의 포즈 {count}개를 추가로 잠금 해제합니다. 한 번 구매하면 영구적으로 사용할 수 있습니다.",
        "buyForPrice": "잠금 해제 — {price}",
        "restorePurchase": "구매 복원",
        "purchasePending": "구매 처리 중…",
        "purchaseSuccess": "모든 포즈 잠금 해제됨",
        "purchaseRestored": "구매가 복원되었습니다",
        "purchaseFailed": "구매 실패: {error}",
        "storeUnavailable": "스토어를 사용할 수 없습니다. 나중에 다시 시도해 주세요.",
    },
    "fr": {
        "unlockAllPoses": "Débloquer toutes les poses",
        "unlockAllPosesBody": "Débloque {count} poses supplémentaires dans chaque style. Achat unique, à jamais.",
        "buyForPrice": "Débloquer — {price}",
        "restorePurchase": "Restaurer l'achat",
        "purchasePending": "Achat en cours…",
        "purchaseSuccess": "Toutes les poses sont débloquées",
        "purchaseRestored": "Achat restauré",
        "purchaseFailed": "Échec de l'achat : {error}",
        "storeUnavailable": "Le store est indisponible. Veuillez réessayer plus tard.",
    },
    "de": {
        "unlockAllPoses": "Alle Posen freischalten",
        "unlockAllPosesBody": "Schaltet {count} weitere Posen in jedem Stil frei. Einmalige Zahlung, für immer.",
        "buyForPrice": "Freischalten — {price}",
        "restorePurchase": "Kauf wiederherstellen",
        "purchasePending": "Kauf läuft…",
        "purchaseSuccess": "Alle Posen freigeschaltet",
        "purchaseRestored": "Kauf wiederhergestellt",
        "purchaseFailed": "Kauf fehlgeschlagen: {error}",
        "storeUnavailable": "Store ist nicht verfügbar. Bitte versuchen Sie es später erneut.",
    },
    "th": {
        "unlockAllPoses": "ปลดล็อกท่าทางทั้งหมด",
        "unlockAllPosesBody": "ปลดล็อกท่าทางเพิ่มอีก {count} แบบในทุกสไตล์ ซื้อครั้งเดียว ใช้ได้ตลอดไป",
        "buyForPrice": "ปลดล็อก — {price}",
        "restorePurchase": "กู้คืนการซื้อ",
        "purchasePending": "กำลังดำเนินการซื้อ…",
        "purchaseSuccess": "ปลดล็อกท่าทางทั้งหมดแล้ว",
        "purchaseRestored": "กู้คืนการซื้อแล้ว",
        "purchaseFailed": "การซื้อล้มเหลว: {error}",
        "storeUnavailable": "สโตร์ไม่พร้อมใช้งาน กรุณาลองใหม่ภายหลัง",
    },
    "pt": {
        "unlockAllPoses": "Desbloquear todas as poses",
        "unlockAllPosesBody": "Desbloqueia mais {count} poses em cada estilo. Compra única, para sempre.",
        "buyForPrice": "Desbloquear — {price}",
        "restorePurchase": "Restaurar compra",
        "purchasePending": "Compra em andamento…",
        "purchaseSuccess": "Todas as poses desbloqueadas",
        "purchaseRestored": "Compra restaurada",
        "purchaseFailed": "Falha na compra: {error}",
        "storeUnavailable": "A loja está indisponível. Tente novamente mais tarde.",
    },
    "es": {
        "unlockAllPoses": "Desbloquear todas las poses",
        "unlockAllPosesBody": "Desbloquea {count} poses más de cada estilo. Compra única, para siempre.",
        "buyForPrice": "Desbloquear — {price}",
        "restorePurchase": "Restaurar compra",
        "purchasePending": "Compra en curso…",
        "purchaseSuccess": "Todas las poses desbloqueadas",
        "purchaseRestored": "Compra restaurada",
        "purchaseFailed": "Error en la compra: {error}",
        "storeUnavailable": "La tienda no está disponible. Inténtalo de nuevo más tarde.",
    },
    "tr": {
        "unlockAllPoses": "Tüm Pozların Kilidini Aç",
        "unlockAllPosesBody": "Her stilde {count} poz daha kilidini açar. Tek seferlik alım, sonsuza kadar.",
        "buyForPrice": "Kilidi Aç — {price}",
        "restorePurchase": "Satın Almayı Geri Yükle",
        "purchasePending": "Satın alma sürüyor…",
        "purchaseSuccess": "Tüm pozların kilidi açıldı",
        "purchaseRestored": "Satın alma geri yüklendi",
        "purchaseFailed": "Satın alma başarısız: {error}",
        "storeUnavailable": "Mağaza kullanılamıyor. Lütfen daha sonra tekrar deneyin.",
    },
}

# keys that need @metadata (placeholder declarations)
PLACEHOLDERS = {
    "unlockAllPosesBody": {"count": "String"},
    "buyForPrice": {"price": "String"},
    "purchaseFailed": {"error": "String"},
}

# insertion order (after "back")
ORDER = [
    "unlockAllPoses",
    "unlockAllPosesBody",
    "buyForPrice",
    "restorePurchase",
    "purchasePending",
    "purchaseSuccess",
    "purchaseRestored",
    "purchaseFailed",
    "storeUnavailable",
]


def build_block():
    """Return an ordered dict of the new keys (+ @metadata) in insertion order."""
    block = {}
    for k in ORDER:
        block[k] = TR[None]  # placeholder, replaced per-locale
    return block


for locale, texts in TR.items():
    path = os.path.join(L10N_DIR, f"intl_{locale}.arb")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f, object_pairs_hook=dict)

    if "unlockAllPoses" in data:
        print(f"[skip] {locale}: already has unlockAllPoses")
        continue

    new_data = {}
    inserted = False
    for k, v in data.items():
        new_data[k] = v
        if k == "back" and not inserted:
            for key in ORDER:
                new_data[key] = texts[key]
                if key in PLACEHOLDERS:
                    ph = PLACEHOLDERS[key]
                    meta = {"description": key, "placeholders": {p: {"type": t} for p, t in ph.items()}}
                    new_data["@" + key] = meta
            inserted = True

    with open(path, "w", encoding="utf-8") as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"[done] {locale}: added {len(ORDER)} keys")
