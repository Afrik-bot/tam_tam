import '../models/wallet.dart';
import './supabase_service.dart';

class WalletService {
  static final _supabase = SupabaseService.instance;

  static Future<Wallet> getUserWallet() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('wallets')
          .select('*')
          .eq('user_id', userId)
          .single();

      return Wallet.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load wallet: $e');
    }
  }

  static Future<List<WalletTransaction>> getTransactionHistory() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('wallet_transactions')
          .select('''
            *,
            from_user:user_profiles!from_user_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
            ),
            to_user:user_profiles!to_user_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
            )
          ''')
          .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
          .order('created_at', ascending: false);

      return response
          .map<WalletTransaction>((json) => WalletTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  static Future<void> sendTip(
      String toUserId, double amount, String contentId) async {
    final fromUserId = _supabase.currentUser?.id;
    if (fromUserId == null) throw Exception('User not authenticated');

    try {
      final wallet = await getUserWallet();
      await _supabase.client.from('wallet_transactions').insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'wallet_id': wallet.id,
        'amount': amount,
        'currency': 'tam_token',
        'transaction_type': 'tip',
        'status': 'completed',
        'metadata': {'content_id': contentId},
      });
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
        'wallet_id': wallet.id,
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
      final wallet = await getUserWallet();
      final transactions = await getTransactionHistory();

      final received = transactions
          .where((t) => t.toUserId == userId)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final sent = transactions
          .where((t) => t.fromUserId == userId)
          .fold<double>(0, (sum, t) => sum + t.amount);

      return {
        'total_balance': wallet.totalBalance,
        'usd_balance': wallet.usdBalance,
        'tam_token_balance': wallet.tamTokenBalance,
        'btc_balance': wallet.btcBalance,
        'eth_balance': wallet.ethBalance,
        'eur_balance': wallet.eurBalance,
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
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
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
      'eur_to_usd': 1.08,
      'usd_to_eur': 0.93,
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
        'wallet_id': wallet.id,
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
        'wallet_id': wallet.id,
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
      final eurRate = await getExchangeRate('eur', 'usd');

      final usdValue = wallet.usdBalance;
      final tamValue = wallet.tamTokenBalance * usdRate;
      final btcValue = wallet.btcBalance * btcRate;
      final ethValue = wallet.ethBalance * ethRate;
      final eurValue = wallet.eurBalance * eurRate;

      final totalValue = usdValue + tamValue + btcValue + ethValue + eurValue;

      return {
        'total_value': totalValue,
        'usd_percentage': totalValue > 0 ? (usdValue / totalValue) * 100 : 0,
        'tam_percentage': totalValue > 0 ? (tamValue / totalValue) * 100 : 0,
        'btc_percentage': totalValue > 0 ? (btcValue / totalValue) * 100 : 0,
        'eth_percentage': totalValue > 0 ? (ethValue / totalValue) * 100 : 0,
        'eur_percentage': totalValue > 0 ? (eurValue / totalValue) * 100 : 0,
        'daily_change': 0.0, // Would need historical data for this
        'weekly_change': 0.0, // Would need historical data for this
      };
    } catch (e) {
      throw Exception('Failed to calculate portfolio stats: $e');
    }
  }
}
