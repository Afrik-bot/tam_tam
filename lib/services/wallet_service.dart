import './supabase_service.dart';

class WalletService {
  static final _supabase = SupabaseService.instance;

  // Remove all mock data and use real Supabase data
  static Future<Map<String, dynamic>> getUserWallet() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      return await _supabase.getUserWallet(userId);
    } catch (e) {
      throw Exception('Failed to load wallet: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      return await _supabase.getWalletTransactions(userId);
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  static Future<void> sendTip(
      String toUserId, double amount, String contentId) async {
    final fromUserId = _supabase.currentUser?.id;
    if (fromUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.sendTip(fromUserId, toUserId, amount, contentId);
    } catch (e) {
      throw Exception('Failed to send tip: $e');
    }
  }

  static Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required String currency,
    String? message,
  }) async {
    final fromUserId = _supabase.currentUser?.id;
    if (fromUserId == null) throw Exception('User not authenticated');

    try {
      final wallet = await getUserWallet();
      await _supabase.client.from('wallet_transactions').insert({
        'from_user_id': fromUserId,
        'to_user_id': recipientId,
        'wallet_id': wallet['id'],
        'amount': amount,
        'currency': currency,
        'transaction_type': 'transfer',
        'status': 'completed',
        'metadata': {'message': message ?? 'Money transfer'},
      });
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  static Future<Map<String, dynamic>> getWalletStats() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Get wallet data
      final wallet = await getUserWallet();

      // Get transaction stats
      final transactions = await getTransactionHistory();
      final received = transactions
          .where((t) => t['to_user_id'] == userId)
          .fold<double>(0, (sum, t) => sum + (t['amount'] ?? 0));
      final sent = transactions
          .where((t) => t['from_user_id'] == userId)
          .fold<double>(0, (sum, t) => sum + (t['amount'] ?? 0));

      return {
        'total_balance': wallet['usd_balance'] + wallet['tam_token_balance'],
        'usd_balance': wallet['usd_balance'],
        'tam_token_balance': wallet['tam_token_balance'],
        'btc_balance': wallet['btc_balance'],
        'eth_balance': wallet['eth_balance'],
        'total_received': received,
        'total_sent': sent,
        'recent_transactions': transactions.take(5).toList(),
      };
    } catch (e) {
      throw Exception('Failed to load wallet stats: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentRecipients() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('wallet_transactions')
          .select('''
            to_user:user_profiles!to_user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('from_user_id', userId)
          .not('to_user_id', 'is', null)
          .order('created_at', ascending: false)
          .limit(10);

      // Remove duplicates and return unique recipients
      final recipients = <String, Map<String, dynamic>>{};
      for (final tx in response) {
        final user = tx['to_user'] as Map<String, dynamic>;
        recipients[user['id']] = user;
      }

      return recipients.values.toList();
    } catch (e) {
      throw Exception('Failed to load recent recipients: $e');
    }
  }

  static Future<double> getExchangeRate(
      String fromCurrency, String toCurrency) async {
    // Mock exchange rates - in production, you'd call a real API
    final rates = {
      'usd_to_tam_token': 10.0,
      'tam_token_to_usd': 0.1,
      'usd_to_btc': 0.000023,
      'btc_to_usd': 43500.0,
      'usd_to_eth': 0.00041,
      'eth_to_usd': 2450.0,
    };

    final key = '${fromCurrency.toLowerCase()}_to_${toCurrency.toLowerCase()}';
    return rates[key] ?? 1.0;
  }

  static Future<void> buyTamTokens(double usdAmount) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final rate = await getExchangeRate('usd', 'tam_token');
      final tamAmount = usdAmount * rate;

      final wallet = await getUserWallet();
      await _supabase.client.from('wallet_transactions').insert({
        'to_user_id': userId,
        'wallet_id': wallet['id'],
        'amount': tamAmount,
        'currency': 'tam_token',
        'transaction_type': 'purchase',
        'status': 'completed',
        'metadata': {'usd_amount': usdAmount, 'exchange_rate': rate},
      });
    } catch (e) {
      throw Exception('Failed to buy TAM tokens: $e');
    }
  }

  static Future<void> sellTamTokens(double tamAmount) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final rate = await getExchangeRate('tam_token', 'usd');
      final usdAmount = tamAmount * rate;

      final wallet = await getUserWallet();
      await _supabase.client.from('wallet_transactions').insert({
        'from_user_id': userId,
        'wallet_id': wallet['id'],
        'amount': tamAmount,
        'currency': 'tam_token',
        'transaction_type': 'sale',
        'status': 'completed',
        'metadata': {'usd_amount': usdAmount, 'exchange_rate': rate},
      });
    } catch (e) {
      throw Exception('Failed to sell TAM tokens: $e');
    }
  }

  static Future<Map<String, dynamic>> getPortfolioStats() async {
    try {
      final wallet = await getUserWallet();
      final usdRate = await getExchangeRate('tam_token', 'usd');
      final btcRate = await getExchangeRate('btc', 'usd');
      final ethRate = await getExchangeRate('eth', 'usd');

      final usdValue = (wallet['usd_balance'] ?? 0.0) as double;
      final tamValue =
          ((wallet['tam_token_balance'] ?? 0.0) as double) * usdRate;
      final btcValue = ((wallet['btc_balance'] ?? 0.0) as double) * btcRate;
      final ethValue = ((wallet['eth_balance'] ?? 0.0) as double) * ethRate;

      final totalValue = usdValue + tamValue + btcValue + ethValue;

      return {
        'total_value': totalValue,
        'usd_percentage': totalValue > 0 ? (usdValue / totalValue) * 100 : 0,
        'tam_percentage': totalValue > 0 ? (tamValue / totalValue) * 100 : 0,
        'btc_percentage': totalValue > 0 ? (btcValue / totalValue) * 100 : 0,
        'eth_percentage': totalValue > 0 ? (ethValue / totalValue) * 100 : 0,
        'daily_change': 0.0, // Would need historical data for this
        'weekly_change': 0.0, // Would need historical data for this
      };
    } catch (e) {
      throw Exception('Failed to calculate portfolio stats: $e');
    }
  }
}
