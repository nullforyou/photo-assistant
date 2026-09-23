import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// App Store Connect 中创建的非消耗型产品 ID（一次性买断，永久解锁全部姿势）。
/// 在 App Store Connect → Monetization → In-App Purchases 创建，类型 Non-Consumable。
const String kProUnlockProductId = 'com.chunyanyang.photoassistant.pro_unlock';

/// 本地存储解锁状态的 key（持久化于 Keychain / EncryptedSharedPreferences）。
const String _kUnlockedStorageKey = 'pro_unlock_granted_v1';

/// 内购服务（单例）。
///
/// 纯本地 App 也能做 IAP：付款与收据验证由 Apple / Google 在设备本地完成，
/// 本服务只负责发起购买、监听购买结果、把「已解锁」状态持久化到安全存储。
/// 不依赖任何自建后端。
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final _storage = const FlutterSecureStorage(
    // iOS 解锁后即使设备锁屏也能读取；Android 用加密 SharedPreferences
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// 是否已解锁全部姿势（已购买或已恢复）。用 ValueNotifier 便于 UI 响应式更新。
  final ValueNotifier<bool> unlocked = ValueNotifier<bool>(false);

  /// 商店是否可用（设备支持 IAP）。模拟器 / 未配置商店时可能返回 false。
  bool get storeAvailable => _storeAvailable;
  bool _storeAvailable = false;

  /// 当前加载到的 pro_unlock 商品详情（含本地货币价格）。未加载完成时为 null。
  ProductDetails? get product => _product;
  ProductDetails? _product;

  /// 初始化时是否发生过错误（如商店不可用），仅供 UI 提示。
  String? lastError;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// 首次初始化：读取本地解锁状态、探测商店、拉取商品价格、订阅购买流。
  Future<void> init() async {
    final stored = await _storage.read(key: _kUnlockedStorageKey);
    if (stored == '1') unlocked.value = true;

    try {
      _storeAvailable = await _iap.isAvailable();
    } catch (e) {
      _storeAvailable = false;
      lastError = e.toString();
    }
    if (!_storeAvailable) return;

    try {
      final resp = await _iap.queryProductDetails({kProUnlockProductId});
      if (resp.productDetails.isNotEmpty) {
        _product = resp.productDetails.firstWhere(
          (p) => p.id == kProUnlockProductId,
          orElse: () => resp.productDetails.first,
        );
      }
    } catch (e) {
      lastError = e.toString();
    }

    _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(_handlePurchaseUpdates);
  }

  /// 购买失败/成功的最新提示文案（供 UI 弹 SnackBar）。
  final ValueNotifier<String?> statusMessage = ValueNotifier<String?>(null);

  void _handlePurchaseUpdates(List<PurchaseDetails> details) {
    for (final d in details) {
      if (d.status == PurchaseStatus.purchased ||
          d.status == PurchaseStatus.restored) {
        _grant();
      } else if (d.status == PurchaseStatus.error) {
        lastError = d.error?.message ?? 'purchase error';
        statusMessage.value = lastError;
      } else if (d.status == PurchaseStatus.pending) {
        statusMessage.value = 'pending';
      }
      // 必须补全交易，否则 iOS 会一直挂起、重复弹窗
      if (d.pendingCompletePurchase) {
        _iap.completePurchase(d);
      }
    }
  }

  Future<void> _grant() async {
    await _storage.write(key: _kUnlockedStorageKey, value: '1');
    unlocked.value = true;
    statusMessage.value = 'granted';
  }

  /// 发起购买（非消耗型一次性解锁）。
  /// 返回是否最终已解锁；无法购买（无商品 / 商店不可用）时返回当前状态。
  Future<bool> buy() async {
    final p = _product;
    if (p == null || !_storeAvailable) {
      // 没拿到商品详情时尝试恢复一次（也许之前买过）
      await restore();
      return unlocked.value;
    }
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: p),
      );
    } catch (e) {
      lastError = e.toString();
      statusMessage.value = lastError;
    }
    return unlocked.value;
  }

  /// 恢复购买（Apple 强制要求提供入口）。
  Future<void> restore() async {
    if (!_storeAvailable) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      lastError = e.toString();
      statusMessage.value = lastError;
    }
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
  }
}
