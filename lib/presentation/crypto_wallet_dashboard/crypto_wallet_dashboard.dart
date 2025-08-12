import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../models/wallet.dart';
import './widgets/currency_card.dart';
import './widgets/portfolio_value_card.dart';
import './widgets/quick_actions_fab.dart';
import './widgets/security_status_bar.dart';
import './widgets/tam_token_card.dart';

class CryptoWalletDashboard extends StatefulWidget {
  const CryptoWalletDashboard({super.key});

  @override
  State<CryptoWalletDashboard> createState() => _CryptoWalletDashboardState();
}

class _CryptoWalletDashboardState extends State<CryptoWalletDashboard> {
  Wallet? _wallet;
  Map<String, dynamic>? _portfolioStats;
  List<WalletTransaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    if (!AuthService.isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Load wallet data using real Supabase data
      final wallet = await WalletService.getUserWallet();
      final portfolioStats = await WalletService.getPortfolioStats();
      final transactions = await WalletService.getTransactionHistory();

      setState(() {
        _wallet = wallet;
        _portfolioStats = portfolioStats;
        _recentTransactions = transactions.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load wallet: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _refreshWallet() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: !AuthService.isAuthenticated
            ? _buildSignInRequired()
            : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35))))
                : _buildWalletContent(),
        floatingActionButton: AuthService.isAuthenticated && !_isLoading
            ? QuickActionsFab(
                onSendMoney: () {},
                onRequestPayment: () {},
                onBuyCrypto: () {},
              )
            : null);
  }

  Widget _buildSignInRequired() {
    return Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withAlpha(26),
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      size: 60.sp, color: const Color(0xFFFF6B35))),
              SizedBox(height: 3.h),
              Text('Secure Crypto Wallet',
                  style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 1.h),
              Text(
                  'Sign in to access your TAM tokens, Bitcoin, Ethereum, and transaction history',
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.white70, height: 1.4),
                  textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25))),
                  child: Text('Sign In to Access Wallet',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600))),
            ])));
  }

  Widget _buildWalletContent() {
    return RefreshIndicator(
        onRefresh: _refreshWallet,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              // Header
              Container(
                  padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 2.h),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Crypto Wallet',
                            style: TextStyle(
                                fontSize: 24.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () => _showWalletMenu(),
                            icon: Icon(Icons.more_vert,
                                color: Colors.white, size: 24.sp)),
                      ])),

              // Security Status
              SecurityStatusBar(
                isSecureConnection: true,
                isWalletSynced: true,
                lastSyncTime: DateTime.now(),
              ),

              SizedBox(height: 2.h),

              // Portfolio Value Card
              PortfolioValueCard(
                totalValue: _portfolioStats?['total_value'] ?? 0.0,
                percentageChange: 0.0,
                isPositive: true,
                isVisible: true,
                onToggleVisibility: () {},
              ),

              SizedBox(height: 3.h),

              // TAM Token Card (Featured)
              TamTokenCard(
                tamTokenBalance: _wallet?.tamTokenBalance ?? 0.0,
                tamTokenValue: (_wallet?.tamTokenBalance ?? 0.0) *
                    0.1, // Mock conversion rate
                onEarnMore: () {},
              ),

              SizedBox(height: 2.h),

              // Other Currencies
              CurrencyCard(
                currency: {
                  'name': 'US Dollar',
                  'symbol': 'USD',
                  'balance': _wallet?.usdBalance ?? 0.0,
                  'change': 0.0,
                  'icon': null,
                },
                onTap: () => _showCurrencyDetails('USD'),
                onSwipeLeft: () {},
                onSwipeRight: () {},
              ),

              SizedBox(height: 1.h),

              CurrencyCard(
                currency: {
                  'name': 'Bitcoin',
                  'symbol': 'BTC',
                  'balance': _wallet?.btcBalance ?? 0.0,
                  'change': 2.45,
                  'icon': null,
                },
                onTap: () => _showCurrencyDetails('BTC'),
                onSwipeLeft: () {},
                onSwipeRight: () {},
              ),

              SizedBox(height: 1.h),

              CurrencyCard(
                currency: {
                  'name': 'Ethereum',
                  'symbol': 'ETH',
                  'balance': _wallet?.ethBalance ?? 0.0,
                  'change': -1.23,
                  'icon': null,
                },
                onTap: () => _showCurrencyDetails('ETH'),
                onSwipeLeft: () {},
                onSwipeRight: () {},
              ),

              // Recent Transactions Section
              if (_recentTransactions.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Activity',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          TextButton(
                              onPressed: () => _viewAllTransactions(),
                              child: Text('View All',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFFFF6B35)))),
                        ])),
                ..._recentTransactions
                    .map((transaction) => _buildTransactionTile(transaction)),
              ],

              SizedBox(height: 10.h), // Space for FAB
            ])));
  }

  Widget _buildTransactionTile(WalletTransaction transaction) {
    final isReceived = transaction.toUserId == AuthService.currentUser?.id;
    final transactionType = transaction.transactionType;

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(13))),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  color: (isReceived ? Colors.green : Colors.red).withAlpha(26),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                  isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isReceived ? Colors.green : Colors.red,
                  size: 20.sp)),
          SizedBox(width: 3.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(transactionType.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                Text(transaction.timeAgo,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(transaction.formattedAmount,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: isReceived ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600)),
            Text(transaction.currency.toString().split('.').last.toUpperCase(),
                style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
          ]),
        ]));
  }

  void _showWalletMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.security, color: Colors.white),
                  title: Text('Security Settings',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to security settings
                  }),
              ListTile(
                  leading: const Icon(Icons.backup, color: Colors.white),
                  title: Text('Backup Wallet',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to backup
                  }),
              ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.white),
                  title: Text('Help & Support',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help
                  }),
              SizedBox(height: 2.h),
            ])));
  }

  void _showTamTokenDetails() {
    // Navigate to TAM token details or show modal
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                title: Text('TAM Token Details',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('TAM token management features coming soon!',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: const Color(0xFFFF6B35)))),
                ]));
  }

  void _showCurrencyDetails(String currency) {
    // Navigate to currency details
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                title: Text('$currency Details',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Currency management features coming soon!',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: const Color(0xFFFF6B35)))),
                ]));
  }

  void _viewAllTransactions() {
    // Navigate to transactions history
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                title: Text('Transaction History',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Full transaction history coming soon!',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: const Color(0xFFFF6B35)))),
                ]));
  }
}
