import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Transaction row (DESIGN.md §5.2/§5.6). Income: green with `+`; expense:
/// neutral text with `-` (red reserved for system errors — DESIGN.md §2.3).
class TransactionListItem extends StatefulWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.accountName,
    this.onTap,
  });

  final TransactionEntity transaction;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountName;
  final VoidCallback? onTap;

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _syncController;

  @override
  void initState() {
    super.initState();
    _syncController = AnimationController(
      vsync: this,
      duration: AppMotion.idle,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPendingAnimation();
  }

  @override
  void didUpdateWidget(covariant TransactionListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPendingAnimation();
  }

  void _syncPendingAnimation() {
    final pending = widget.transaction.syncStatus == SyncStatus.pendingSync;
    if (pending && !MediaQuery.disableAnimationsOf(context)) {
      if (!_syncController.isAnimating) _syncController.repeat(reverse: true);
    } else {
      _syncController.stop();
      _syncController.value = 1;
    }
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final transaction = widget.transaction;
    final isIncome = transaction.type == TransactionType.income;
    final accent = tryParseColor(widget.categoryColor) ?? colors.primary;

    final title =
        transaction.merchant ??
        transaction.note ??
        widget.categoryName ??
        AppStrings.transactionDefault;

    return ListTile(
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(iconForName(widget.categoryIcon), color: accent),
      ),
      title: Row(
        children: [
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          if (transaction.syncStatus == SyncStatus.pendingSync)
            FadeTransition(
              opacity: Tween(begin: 0.5, end: 1.0).animate(_syncController),
              child: Tooltip(
                message: AppStrings.notSynced,
                child: Icon(Icons.cloud_off, size: 14, color: colors.warning),
              ),
            ),
        ],
      ),
      subtitle: Text(
        [
          if (widget.accountName != null) widget.accountName!,
          DateFormatter.format(transaction.date),
        ].join(' • '),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isIncome ? colors.success : colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
