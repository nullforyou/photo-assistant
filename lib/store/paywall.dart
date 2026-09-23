import 'package:flutter/material.dart';
import 'package:photo_assistant/api/api.dart';
import 'package:photo_assistant/l10n/generated/app_localizations.dart';
import 'package:photo_assistant/poses/pose_library.dart';
import 'package:photo_assistant/store/purchase_service.dart';
import 'package:photo_assistant/theme/brand.dart';

/// 底部弹出「解锁全部姿势」付费墙。
///
/// 展示本地货币价格、购买按钮、恢复购买入口。购买成功后自动关闭弹层并刷新解锁状态。
Future<void> showPaywall(BuildContext context) async {
  final s = S.of(context);
  final ps = PurchaseService.instance;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PaywallSheet(s: s, ps: ps),
  );
}

class _PaywallSheet extends StatefulWidget {
  const _PaywallSheet({required this.s, required this.ps});

  final S s;
  final PurchaseService ps;

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<_PaywallSheet> {
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    // 解锁状态变化（购买/恢复成功）时关闭弹层
    widget.ps.unlocked.addListener(_onUnlocked);
    widget.ps.statusMessage.addListener(_onStatus);
  }

  @override
  void dispose() {
    widget.ps.unlocked.removeListener(_onUnlocked);
    widget.ps.statusMessage.removeListener(_onStatus);
    super.dispose();
  }

  void _onUnlocked() {
    if (widget.ps.unlocked.value && mounted) {
      // 关闭付费墙，回到上一级
      Navigator.of(context).maybePop();
    }
  }

  void _onStatus() {
    final msg = widget.ps.statusMessage.value;
    if (msg == null || !mounted) return;
    if (msg == 'granted' || msg == 'pending') {
      // granted 由 _onUnlocked 处理；pending 仅提示
      if (msg == 'pending' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.s.purchasePending)),
        );
      }
      widget.ps.statusMessage.value = null;
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.s.purchaseFailed(msg))),
      );
    }
    widget.ps.statusMessage.value = null;
    setState(() => _buying = false);
  }

  Future<void> _onBuy() async {
    setState(() => _buying = true);
    await widget.ps.buy();
    // buy 内部已在购买流处理；若未解锁（如商店不可用），恢复按钮可兜底
    if (mounted && !widget.ps.unlocked.value) {
      setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final ps = widget.ps;
    final product = ps.product;
    final priceText = product?.price ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(Icons.auto_awesome_rounded, size: 40, color: kBrandPinkDeep),
          const SizedBox(height: 10),
          Text(
            s.unlockAllPoses,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kInkPlum,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.unlockAllPosesBody(kFreePoseLimit == 0
                ? '0'
                : '${poseDataCount - kFreePoseLimit}'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: kMutedPlum),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kBrandPinkDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _buying ? null : _onBuy,
              child: _buying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(priceText.isEmpty
                      ? s.unlockAllPoses
                      : s.buyForPrice(priceText)),
            ),
          ),
          if (!ps.storeAvailable) ...[
            const SizedBox(height: 10),
            Text(
              s.storeUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.red.shade300),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: _buying ? null : () => ps.restore(),
            child: Text(
              s.restorePurchase,
              style: const TextStyle(color: kMutedPlum),
            ),
          ),
        ],
      ),
    );
  }
}

/// 总姿势数（用于付费墙文案显示「解锁 N 个」）。
/// 直接从内置数据包计数，避免引入额外依赖。
int get poseDataCount {
  // kDefaultPoseJson 内的 poses 数组长度，这里直接复用 parseDefaultPoseResult。
  return PoseApi.defaultResult.poses.length;
}
