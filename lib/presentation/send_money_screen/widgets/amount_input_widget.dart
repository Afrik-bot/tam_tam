import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String selectedCurrency;
  final Map<String, double> exchangeRates;
  final Function(String) onAmountChanged;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.selectedCurrency,
    required this.exchangeRates,
    required this.onAmountChanged,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  final List<String> _quickAmounts = ['10', '25', '50', '100', '250', '500'];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      widget.onAmountChanged(widget.controller.text);
    });
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'TAM':
        return 'T';
      case 'NGN':
        return '₦';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      default:
        return currency[0];
    }
  }

  double _convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = widget.exchangeRates[fromCurrency] ?? 1.0;
    final toRate = widget.exchangeRates[toCurrency] ?? 1.0;

    return (amount / fromRate) * toRate;
  }

  @override
  Widget build(BuildContext context) {
    final currentAmount = double.tryParse(widget.controller.text) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _getCurrencySymbol(widget.selectedCurrency),
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Quick amount buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _quickAmounts.map((amount) {
              final isSelected = widget.controller.text == amount;
              return GestureDetector(
                onTap: () {
                  widget.controller.text = amount;
                  widget.onAmountChanged(amount);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${_getCurrencySymbol(widget.selectedCurrency)}$amount',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (currentAmount > 0 && widget.exchangeRates.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversion Preview',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...widget.exchangeRates.entries
                      .where((entry) => entry.key != widget.selectedCurrency)
                      .take(3)
                      .map((entry) {
                    final convertedAmount = _convertAmount(
                        currentAmount, widget.selectedCurrency, entry.key);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${_getCurrencySymbol(entry.key)}${convertedAmount.toStringAsFixed(entry.key == 'BTC' || entry.key == 'ETH' ? 6 : 2)}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
