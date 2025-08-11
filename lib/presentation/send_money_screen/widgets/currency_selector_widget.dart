import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrencySelectorWidget extends StatelessWidget {
  final String selectedCurrency;
  final double balance;
  final Map<String, double> exchangeRates;
  final Function(String) onCurrencyChanged;

  const CurrencySelectorWidget({
    super.key,
    required this.selectedCurrency,
    required this.balance,
    required this.exchangeRates,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            'Send From',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCurrencySelector(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _getCurrencyColor(selectedCurrency),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getCurrencySymbol(selectedCurrency),
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCurrency,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Balance: ${_formatBalance(balance, selectedCurrency)}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (exchangeRates.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Exchange Rates',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              height: 6.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: exchangeRates.length,
                separatorBuilder: (context, index) => SizedBox(width: 3.w),
                itemBuilder: (context, index) {
                  final currency = exchangeRates.keys.elementAt(index);
                  final rate = exchangeRates[currency]!;
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currency,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          rate.toStringAsFixed(4),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final currencies = ['USD', 'EUR', 'BTC', 'ETH', 'TAM', 'NGN', 'INR', 'BRL'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Select Currency',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: currencies.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = currency == selectedCurrency;
                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    leading: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: _getCurrencyColor(currency),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getCurrencySymbol(currency),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      currency,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      _getCurrencyFullName(currency),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      onCurrencyChanged(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCurrencyColor(String currency) {
    switch (currency) {
      case 'USD':
        return const Color(0xFF2E7D32);
      case 'EUR':
        return const Color(0xFF1565C0);
      case 'BTC':
        return const Color(0xFFF57C00);
      case 'ETH':
        return const Color(0xFF6200EA);
      case 'TAM':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'NGN':
        return const Color(0xFF388E3C);
      case 'INR':
        return const Color(0xFFFF6F00);
      case 'BRL':
        return const Color(0xFF00796B);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
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

  String _getCurrencyFullName(String currency) {
    switch (currency) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum';
      case 'TAM':
        return 'Tam Token';
      case 'NGN':
        return 'Nigerian Naira';
      case 'INR':
        return 'Indian Rupee';
      case 'BRL':
        return 'Brazilian Real';
      default:
        return currency;
    }
  }

  String _formatBalance(double balance, String currency) {
    final symbol = _getCurrencySymbol(currency);
    if (currency == 'BTC' || currency == 'ETH') {
      return '$symbol${balance.toStringAsFixed(6)}';
    }
    return '$symbol${balance.toStringAsFixed(2)}';
  }
}
