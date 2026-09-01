import 'package:flutter/material.dart';

/// Maps icon names stored in Supabase (PLANNING.md §2.1 defaults) to
/// Material icons; unknown names fall back to [fallback].
IconData iconForName(String? icon, {IconData fallback = Icons.category}) {
  return switch (icon) {
    'cash_icon' => Icons.payments,
    'gopay_icon' => Icons.account_balance_wallet,
    'shopeepay_icon' => Icons.shopping_bag,
    'dana_icon' => Icons.wallet,
    'bca_icon' => Icons.account_balance,
    'food_icon' => Icons.restaurant,
    'transport_icon' => Icons.directions_car,
    'shopping_icon' => Icons.shopping_bag,
    'entertainment_icon' => Icons.movie,
    'bill_icon' => Icons.receipt_long,
    'salary_icon' => Icons.work,
    'freelance_icon' => Icons.laptop,
    'invest_icon' => Icons.trending_up,
    'other_icon' || 'other_income_icon' => Icons.category,
    _ => fallback,
  };
}
