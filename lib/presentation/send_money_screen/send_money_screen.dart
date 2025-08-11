import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/currency_selector_widget.dart';
import './widgets/qr_scanner_widget.dart';
import './widgets/recent_recipients_widget.dart';
import './widgets/recipient_input_widget.dart';
import './widgets/transaction_details_widget.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _selectedCurrency = 'USD';
  double _currentBalance = 2500.75;
  bool _isValidRecipient = false;
  bool _isValidAmount = false;
  bool _isProcessing = false;
  bool _showQRScanner = false;

  final Map<String, double> _exchangeRates = {
    'EUR': 0.85,
    'BTC': 0.000023,
    'ETH': 0.00035,
    'TAM': 125.50,
    'NGN': 1250.00,
    'INR': 83.25,
    'BRL': 5.15,
  };

  final Map<String, double> _balances = {
    'USD': 2500.75,
    'EUR': 2125.64,
    'BTC': 0.057500,
    'ETH': 0.875000,
    'TAM': 314000.25,
    'NGN': 3125000.00,
    'INR': 208125.00,
    'BRL': 12875.86,
  };

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onCurrencyChanged(String currency) {
    setState(() {
      _selectedCurrency = currency;
      _currentBalance = _balances[currency] ?? 0.0;
      _amountController.clear();
      _isValidAmount = false;
    });
  }

  void _onRecipientChanged(String recipient) {
    setState(() {
      _isValidRecipient =
          recipient.isNotEmpty && _isValidRecipientFormat(recipient);
    });
  }

  void _onAmountChanged(String amount) {
    final parsedAmount = double.tryParse(amount);
    setState(() {
      _isValidAmount = parsedAmount != null &&
          parsedAmount > 0 &&
          parsedAmount <= _currentBalance;
    });
  }

  void _onMessageChanged(String message) {
    // Message is optional, no validation needed
  }

  bool _isValidRecipientFormat(String text) {
    return _isValidEmail(text) ||
        _isValidPhone(text) ||
        _isValidUsername(text) ||
        _isValidWalletAddress(text);
  }

  bool _isValidEmail(String text) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
  }

  bool _isValidPhone(String text) {
    return RegExp(r'^\+?[1-9]\d{1,14}$')
        .hasMatch(text.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  bool _isValidUsername(String text) {
    return RegExp(r'^@?[a-zA-Z0-9_]{3,20}$').hasMatch(text);
  }

  bool _isValidWalletAddress(String text) {
    return text.length >= 26 &&
        text.length <= 62 &&
        RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
  }

  void _onQRScanned(String scannedData) {
    setState(() {
      _recipientController.text = scannedData;
      _showQRScanner = false;
      _isValidRecipient = _isValidRecipientFormat(scannedData);
    });
  }

  void _onRecipientSelected(Map<String, dynamic> recipient) {
    setState(() {
      _recipientController.text = recipient['username'] as String;
      _isValidRecipient = true;
    });
  }

  Future<bool> _authenticateUser() async {
    try {
      if (kIsWeb) {
        // Web fallback - show confirmation dialog
        return await _showWebConfirmationDialog();
      }

      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) {
        return await _showWebConfirmationDialog();
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to send money',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      return await _showWebConfirmationDialog();
    }
  }

  Future<bool> _showWebConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm Transaction',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please confirm your transaction details:',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                _buildTransactionSummary(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildTransactionSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final fee = _calculateTransactionFee(amount);
    final total = amount + fee;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To: ${_recipientController.text}',
              style: AppTheme.lightTheme.textTheme.bodySmall),
          Text(
              'Amount: ${_getCurrencySymbol(_selectedCurrency)}${amount.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.bodySmall),
          Text(
              'Fee: ${_getCurrencySymbol(_selectedCurrency)}${fee.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.bodySmall),
          Divider(height: 1.h),
          Text(
              'Total: ${_getCurrencySymbol(_selectedCurrency)}${total.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  double _calculateTransactionFee(double amount) {
    switch (_selectedCurrency) {
      case 'BTC':
        return 0.0003;
      case 'ETH':
        return 0.003;
      case 'TAM':
        return amount * 0.005;
      default:
        return amount * 0.01;
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

  Future<void> _processSendMoney() async {
    if (!_isValidRecipient || !_isValidAmount || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Authenticate user
      final authenticated = await _authenticateUser();
      if (!authenticated) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Simulate transaction processing
      await Future.delayed(const Duration(seconds: 3));

      // Show success dialog
      await _showSuccessDialog();

      // Reset form
      _resetForm();
    } catch (e) {
      _showErrorDialog('Transaction failed. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _recipientController.clear();
      _amountController.clear();
      _messageController.clear();
      _isValidRecipient = false;
      _isValidAmount = false;
    });
  }

  Future<void> _showSuccessDialog() async {
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Transaction Successful!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Your money has been sent successfully.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Transaction ID',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    transactionId,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: transactionId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transaction ID copied to clipboard')),
              );
            },
            child: Text('Copy ID'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get _canSendMoney =>
      _isValidRecipient && _isValidAmount && !_isProcessing;

  @override
  Widget build(BuildContext context) {
    if (_showQRScanner) {
      return Scaffold(
        body: QRScannerWidget(
          onQRScanned: _onQRScanned,
          onClose: () {
            setState(() {
              _showQRScanner = false;
            });
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Send Money',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/crypto-wallet-dashboard');
            },
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            // Currency Selector
            CurrencySelectorWidget(
              selectedCurrency: _selectedCurrency,
              balance: _currentBalance,
              exchangeRates: _exchangeRates,
              onCurrencyChanged: _onCurrencyChanged,
            ),
            SizedBox(height: 3.h),

            // Recent Recipients
            RecentRecipientsWidget(
              onRecipientSelected: _onRecipientSelected,
            ),
            SizedBox(height: 3.h),

            // Recipient Input
            RecipientInputWidget(
              controller: _recipientController,
              onQRScan: () {
                setState(() {
                  _showQRScanner = true;
                });
              },
              onRecipientChanged: _onRecipientChanged,
            ),
            SizedBox(height: 3.h),

            // Amount Input
            AmountInputWidget(
              controller: _amountController,
              selectedCurrency: _selectedCurrency,
              exchangeRates: _exchangeRates,
              onAmountChanged: _onAmountChanged,
            ),
            SizedBox(height: 3.h),

            // Transaction Details
            TransactionDetailsWidget(
              messageController: _messageController,
              selectedCurrency: _selectedCurrency,
              amount: double.tryParse(_amountController.text) ?? 0.0,
              onMessageChanged: _onMessageChanged,
            ),
            SizedBox(height: 4.h),

            // Send Button
            Container(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _canSendMoney ? _processSendMoney : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSendMoney
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  elevation: _canSendMoney ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Processing...',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'send',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Send Money',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
