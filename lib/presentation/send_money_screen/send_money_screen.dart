import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/wallet_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/recent_recipients_widget.dart';
import './widgets/recipient_input_widget.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _selectedCurrency = 'USD';
  bool _isLoading = false;
  bool _isRequestMode = false;
  bool _isValidAmount = false;
  bool _isValidRecipient = false;
  bool _showQRScanner = false;
  double _currentBalance = 0.0;

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
    _usernameController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    _recipientController.dispose();
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
      _usernameController.text = scannedData;
      _showQRScanner = false;
      _isValidRecipient = _isValidRecipientFormat(scannedData);
    });
  }

  void _onRecipientSelected(Map<String, dynamic> recipient) {
    setState(() {
      _usernameController.text = recipient['username'] as String;
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
              biometricOnly: false, stickyAuth: true));

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
                    title: Text('Confirm Transaction',
                        style: AppTheme.lightTheme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Please confirm your transaction details:',
                              style: AppTheme.lightTheme.textTheme.bodyMedium),
                          SizedBox(height: 2.h),
                          _buildTransactionSummary(),
                        ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel')),
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Confirm')),
                    ])) ??
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
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('To: ${_usernameController.text}',
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
        ]));
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

  Future<void> _sendMoney() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final username = _usernameController.text.trim();
      final message = _messageController.text.trim();

      if (_isRequestMode) {
        await WalletService.instance.requestMoney(
            recipientUsername: username,
            amount: amount,
            currency: _selectedCurrency.toLowerCase(),
            message: message.isEmpty ? null : message);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Money request sent successfully!"),
                  backgroundColor: Colors.green));
        }
      } else {
        await WalletService.instance.sendMoney(
            recipientUsername: username,
            amount: amount,
            currency: _selectedCurrency.toLowerCase(),
            message: message.isEmpty ? null : message);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Money sent successfully!"),
                  backgroundColor: Colors.green));
        }
      }

      _usernameController.clear();
      _amountController.clear();
      _messageController.clear();
      Navigator.pop(context);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('Insufficient balance')) {
        errorMessage =
            'Insufficient balance. Please add money to your wallet first.';
      } else if (errorMessage.contains('Recipient not found') ||
          errorMessage.contains('User not found')) {
        errorMessage =
            'User not found. Please check the username and try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage),
                backgroundColor: Colors.red));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool _validateForm() {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter recipient username"), 
              backgroundColor: Colors.red));
      return false;
    }

    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter amount"), 
              backgroundColor: Colors.red));
      return false;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a valid amount"), 
              backgroundColor: Colors.red));
      return false;
    }

    if (amount > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Amount cannot exceed \$10,000"), 
              backgroundColor: Colors.red));
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w),
                onPressed: () => Navigator.pop(context)),
            title: Text(_isRequestMode ? 'Request Money' : 'Send Money',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface)),
            actions: [
              // Toggle between send and request
              TextButton(
                  onPressed: () {
                    setState(() {
                      _isRequestMode = !_isRequestMode;
                    });
                  },
                  child: Text(_isRequestMode ? 'Send' : 'Request',
                      style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600))),
            ]),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode indicator
                      Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                              color: _isRequestMode
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _isRequestMode
                                      ? Colors.blue.withValues(alpha: 0.3)
                                      : AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.3))),
                          child: Row(children: [
                            CustomIconWidget(
                                iconName:
                                    _isRequestMode ? 'request_quote' : 'send',
                                color: _isRequestMode
                                    ? Colors.blue
                                    : AppTheme.lightTheme.colorScheme.primary,
                                size: 6.w),
                            SizedBox(width: 3.w),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      _isRequestMode
                                          ? 'Request Mode'
                                          : 'Send Mode',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                              color: _isRequestMode
                                                  ? Colors.blue
                                                  : AppTheme.lightTheme
                                                      .colorScheme.primary,
                                              fontWeight: FontWeight.w600)),
                                  Text(
                                      _isRequestMode
                                          ? 'Ask someone to send you money'
                                          : 'Send money to another user',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onSurfaceVariant)),
                                ])),
                          ])),

                      SizedBox(height: 4.h),

                      // Recipient input
                      RecipientInputWidget(
                          controller: _usernameController,
                          onQRScan: _onQRScanned,
                          onRecipientChanged: _onRecipientChanged),

                      SizedBox(height: 3.h),

                      // Amount input
                      AmountInputWidget(
                          controller: _amountController,
                          selectedCurrency: _selectedCurrency,
                          exchangeRates: _exchangeRates,
                          onAmountChanged: _onAmountChanged),

                      SizedBox(height: 3.h),

                      // Message input
                      TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                              labelText: 'Message (optional)',
                              hintText: _isRequestMode
                                  ? 'Why are you requesting money?'
                                  : 'Add a note for this transfer...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.3))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      width: 2)),
                              prefixIcon: CustomIconWidget(
                                  iconName: 'message',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 5.w)),
                          maxLines: 3,
                          maxLength: 200,
                          textCapitalization: TextCapitalization.sentences),

                      SizedBox(height: 4.h),

                      // Send/Request button
                      Container(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendMoney,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRequestMode
                                      ? Colors.blue
                                      : AppTheme.lightTheme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: (_isRequestMode
                                          ? Colors.blue
                                          : AppTheme
                                              .lightTheme.colorScheme.primary)
                                      .withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  disabledBackgroundColor: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.3)),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.white))),
                                          SizedBox(width: 3.w),
                                          Text(
                                              _isRequestMode
                                                  ? 'Requesting...'
                                                  : 'Sending...',
                                              style: AppTheme.lightTheme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ])
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                          CustomIconWidget(
                                              iconName: _isRequestMode
                                                  ? 'request_quote'
                                                  : 'send',
                                              color: Colors.white,
                                              size: 5.w),
                                          SizedBox(width: 2.w),
                                          Text(
                                              _isRequestMode
                                                  ? 'Send Request'
                                                  : 'Send Money',
                                              style: AppTheme.lightTheme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ]))),

                      SizedBox(height: 3.h),

                      // Recent recipients (keep existing implementation)
                      if (!_isRequestMode) ...[
                        Text('Recent Recipients',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(height: 2.h),
                        RecentRecipientsWidget(
                            onRecipientSelected: (recipient) {
                          setState(() {
                            _usernameController.text =
                                recipient['username'] ?? '';
                          });
                        }),
                      ],

                      // Quick request amounts for request mode
                      if (_isRequestMode) ...[
                        Text('Quick Amounts',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(height: 2.h),
                        Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: [10, 25, 50, 100, 250, 500].map((amount) {
                              return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _amountController.text =
                                          amount.toString();
                                    });
                                  },
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                          color: AppTheme
                                              .lightTheme.colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppTheme.lightTheme
                                                  .colorScheme.outline
                                                  .withValues(alpha: 0.3))),
                                      child: Text('\$${amount}',
                                          style: AppTheme.lightTheme.textTheme.labelLarge
                                              ?.copyWith(
                                                  color: AppTheme.lightTheme
                                                      .colorScheme.onSurface,
                                                  fontWeight: FontWeight.w500))));
                            }).toList()),
                      ],
                    ]))));
  }
}