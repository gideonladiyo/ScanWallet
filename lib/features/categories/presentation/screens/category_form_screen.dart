import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/category_controller.dart';

/// Create/edit category form (TASKS.md 4C.3). Pass [category] to edit.
class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final CategoryEntity? category;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  late final TextEditingController _nameController;
  late TransactionType _type;
  late String _color;
  bool _submitting = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _type = widget.category?.transactionType ?? TransactionType.expense;
    _color = widget.category?.color ?? ColorPresets.hex.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(AppStrings.categoryNameEmpty);
      return;
    }
    setState(() => _submitting = true);
    final controller = ref.read(categoryControllerProvider.notifier);
    final result = widget.category == null
        ? await controller.create(name, _type, color: _color)
        : await controller.updateCategory(
            widget.category!.copyWith(
              name: name,
              transactionType: _type,
              color: _color,
            ),
          );
    if (!mounted) return;
    if (result case Failure(:final failure)) {
      setState(() => _submitting = false);
      _showError(failure.message);
      return;
    }
    setState(() {
      _submitting = false;
      _saved = true;
    });
    await Future<void>.delayed(AppMotion.resolve(context, AppMotion.fast));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteCategoryConfirmTitle),
        content: Text(AppStrings.deleteCategoryConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _submitting = true);
    final result = await ref
        .read(categoryControllerProvider.notifier)
        .delete(widget.category!.id);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => _showError(failure.message),
      (_) => Navigator.of(context).pop(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? AppStrings.addCategory
              : AppStrings.editCategory,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.categoryNameLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.categoryTypeLabel,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(AppStrings.expense),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(AppStrings.income),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.edit,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ColorPresets.hex
                  .map((hex) => _swatch(hex, colors))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: AppStrings.save,
              isLoading: _submitting,
              isSuccess: _saved,
              expanded: true,
              onPressed: _saved ? null : _submit,
            ),
            if (widget.category != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton.destructive(
                label: AppStrings.delete,
                isLoading: _submitting,
                expanded: true,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swatch(String hex, AppColors colors) {
    final color = tryParseColor(hex)!;
    final selected = _color == hex;
    return AnimatedScale(
      scale: selected ? 1.12 : 1,
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.emphasized,
      child: InkWell(
        onTap: () => setState(() => _color = hex),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.fast),
          curve: AppMotion.standard,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.textPrimary : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
