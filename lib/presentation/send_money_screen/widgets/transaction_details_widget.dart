import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionDetailsWidget extends StatefulWidget {
  final TextEditingController messageController;
  final String selectedCurrency;
  final double amount;
  final Function(String) onMessageChanged;

  const TransactionDetailsWidget({
    super.key,
    required this.messageController,
    required this.selectedCurrency,
    required this.amount,
    required this.onMessageChanged,
  });

  @override
  State<TransactionDetailsWidget> createState() =>
      _TransactionDetailsWidgetState();
}

class _TransactionDetailsWidgetState extends State<TransactionDetailsWidget> {
  bool _showAdvancedOptions = false;
  String _selectedPriority = 'standard';
  bool _scheduleTransaction = false;
  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() {
      widget.onMessageChanged(widget.messageController.text);
    });
  }

  double _calculateFee() {
    double baseFee = 0.0;

    switch (widget.selectedCurrency) {
      case 'BTC':
        baseFee = _selectedPriority == 'high'
            ? 0.0005
            : _selectedPriority == 'standard'
                ? 0.0003
                : 0.0001;
        break;
      case 'ETH':
        baseFee = _selectedPriority == 'high'
            ? 0.005
            : _selectedPriority == 'standard'
                ? 0.003
                : 0.001;
        break;
      case 'USD':
      case 'EUR':
      case 'NGN':
      case 'INR':
      case 'BRL':
        baseFee = widget.amount * 0.01; // 1% fee
        break;
      case 'TAM':
        baseFee = widget.amount * 0.005; // 0.5% fee
        break;
      default:
        baseFee = widget.amount * 0.01;
    }

    return baseFee;
  }

  String _getEstimatedTime() {
    if (_selectedPriority == 'high') return '1-5 minutes';
    if (_selectedPriority == 'standard') return '5-15 minutes';
    return '15-60 minutes';
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

  @override
  Widget build(BuildContext context) {
    final fee = _calculateFee();
    final total = widget.amount + fee;

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
            'Transaction Details',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),

          // Message field
          TextFormField(
            controller: widget.messageController,
            maxLines: 3,
            maxLength: 200,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Add a message (optional) 💬',
              hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
          ),
          SizedBox(height: 3.h),

          // Fee breakdown
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${_getCurrencySymbol(widget.selectedCurrency)}${widget.amount.toStringAsFixed(widget.selectedCurrency == 'BTC' || widget.selectedCurrency == 'ETH' ? 6 : 2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Network Fee',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${_getCurrencySymbol(widget.selectedCurrency)}${fee.toStringAsFixed(widget.selectedCurrency == 'BTC' || widget.selectedCurrency == 'ETH' ? 6 : 2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_getCurrencySymbol(widget.selectedCurrency)}${total.toStringAsFixed(widget.selectedCurrency == 'BTC' || widget.selectedCurrency == 'ETH' ? 6 : 2)}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Estimated time
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Estimated time: ${_getEstimatedTime()}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Advanced options toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _showAdvancedOptions = !_showAdvancedOptions;
              });
            },
            child: Row(
              children: [
                CustomIconWidget(
                  iconName:
                      _showAdvancedOptions ? 'expand_less' : 'expand_more',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Advanced Options',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (_showAdvancedOptions) ...[
            SizedBox(height: 2.h),

            // Priority selection
            Text(
              'Transaction Priority',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: ['low', 'standard', 'high'].map((priority) {
                final isSelected = _selectedPriority == priority;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    },
                    child: Container(
                      margin:
                          EdgeInsets.only(right: priority != 'high' ? 2.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1)
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),

            // Schedule transaction
            Row(
              children: [
                Switch(
                  value: _scheduleTransaction,
                  onChanged: (value) {
                    setState(() {
                      _scheduleTransaction = value;
                      if (!value) _scheduledDate = null;
                    });
                  },
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Schedule Transaction',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            if (_scheduleTransaction) ...[
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _scheduledDate = date;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Select date',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: _scheduledDate != null
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
