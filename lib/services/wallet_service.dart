import 'package:flutter/foundation.dart';

import './supabase_service.dart';
import './auth_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  static WalletService get instance => _instance;

  // Get user wallet
  Future<Map<String, dynamic>?> getUserWallet() async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('wallets')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
      return null;
    }
  }

  // Add money to wallet
  Future<bool> addMoneyToWallet({
    required double amount,
    required String currency,
    String? paymentMethod,
    String? referenceId,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Start transaction
      await client.rpc('add_money_to_wallet', params: {
        'user_id_param': user.id,
        'amount_param': amount,
        'currency_param': currency,
        'payment_method_param': paymentMethod ?? 'credit_card',
        'reference_id_param':
            referenceId ?? 'ref_${DateTime.now().millisecondsSinceEpoch}',
      });

      return true;
    } catch (e) {
      debugPrint('Error adding money to wallet: $e');
      throw Exception('Failed to add money to wallet: ${e.toString()}');
    }
  }

  // Send money to another user
  Future<bool> sendMoney({
    required String recipientUsername,
    required double amount,
    required String currency,
    String? message,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Find recipient by username
      final recipientResponse = await client
          .from('user_profiles')
          .select('id, username')
          .eq('username', recipientUsername)
          .maybeSingle();

      if (recipientResponse == null) {
        throw Exception('Recipient not found');
      }

      final recipientId = recipientResponse['id'];

      // Check sender's wallet balance
      final senderWallet = await getUserWallet();
      if (senderWallet == null) {
        throw Exception('Sender wallet not found');
      }

      double currentBalance = 0.0;
      switch (currency.toLowerCase()) {
        case 'usd':
          currentBalance = (senderWallet['usd_balance'] ?? 0.0).toDouble();
          break;
        case 'eur':
          currentBalance = (senderWallet['eur_balance'] ?? 0.0).toDouble();
          break;
        case 'tam_token':
          currentBalance =
              (senderWallet['tam_token_balance'] ?? 0.0).toDouble();
          break;
        default:
          throw Exception('Unsupported currency');
      }

      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // Execute transfer
      await client.rpc('transfer_money', params: {
        'from_user_id_param': user.id,
        'to_user_id_param': recipientId,
        'amount_param': amount,
        'currency_param': currency,
        'message_param': message ?? 'Money transfer via Tam Tam',
      });

      return true;
    } catch (e) {
      debugPrint('Error sending money: $e');
      throw Exception('Failed to send money: ${e.toString()}');
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('wallet_transactions')
          .select('''
            id,
            amount,
            currency,
            transaction_type,
            status,
            created_at,
            metadata,
            from_user:user_profiles!from_user_id (
              id,
              username,
              full_name,
              avatar_url
            ),
            to_user:user_profiles!to_user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .or('from_user_id.eq.${user.id},to_user_id.eq.${user.id}')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      return [];
    }
  }

  // Request money from another user
  Future<bool> requestMoney({
    required String recipientUsername,
    required double amount,
    required String currency,
    String? message,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Find recipient by username
      final recipientResponse = await client
          .from('user_profiles')
          .select('id, username')
          .eq('username', recipientUsername)
          .maybeSingle();

      if (recipientResponse == null) {
        throw Exception('User not found');
      }

      final recipientId = recipientResponse['id'];

      // Create money request transaction
      await client.from('wallet_transactions').insert({
        'from_user_id': recipientId, // Who should send the money
        'to_user_id': user.id, // Who is requesting the money
        'amount': amount,
        'currency': currency,
        'transaction_type': 'money_request',
        'status': 'pending',
        'metadata': {
          'message': message ?? 'Money request via Tam Tam',
          'request_type': 'user_request'
        },
      });

      return true;
    } catch (e) {
      debugPrint('Error requesting money: $e');
      throw Exception('Failed to request money: ${e.toString()}');
    }
  }

  // Get pending money requests
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('wallet_transactions')
          .select('''
            id,
            amount,
            currency,
            created_at,
            metadata,
            to_user:user_profiles!to_user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('from_user_id', user.id)
          .eq('transaction_type', 'money_request')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      return [];
    }
  }

  // Accept money request
  Future<bool> acceptMoneyRequest(String transactionId) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get transaction details
      final transaction = await client
          .from('wallet_transactions')
          .select('*')
          .eq('id', transactionId)
          .eq('from_user_id', user.id)
          .eq('status', 'pending')
          .single();

      // Execute the actual transfer
      await sendMoney(
        recipientUsername: await _getUsernameById(transaction['to_user_id']),
        amount: transaction['amount'].toDouble(),
        currency: transaction['currency'],
        message: transaction['metadata']['message'] ?? 'Money request accepted',
      );

      // Update request status
      await client
          .from('wallet_transactions')
          .update({'status': 'completed'}).eq('id', transactionId);

      return true;
    } catch (e) {
      debugPrint('Error accepting money request: $e');
      throw Exception('Failed to accept money request: ${e.toString()}');
    }
  }

  // Decline money request
  Future<bool> declineMoneyRequest(String transactionId) async {
    try {
      final client = SupabaseService.instance.client;
      final user = AuthService.instance.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client
          .from('wallet_transactions')
          .update({'status': 'failed'})
          .eq('id', transactionId)
          .eq('from_user_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error declining money request: $e');
      throw Exception('Failed to decline money request: ${e.toString()}');
    }
  }

  // Helper method to get username by user ID
  Future<String> _getUsernameById(String userId) async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('user_profiles')
          .select('username')
          .eq('id', userId)
          .single();

      return response['username'];
    } catch (e) {
      debugPrint('Error fetching username: $e');
      throw Exception('User not found');
    }
  }

  // Get wallet balance for specific currency
  Future<double> getWalletBalance(String currency) async {
    try {
      final wallet = await getUserWallet();
      if (wallet == null) return 0.0;

      switch (currency.toLowerCase()) {
        case 'usd':
          return (wallet['usd_balance'] ?? 0.0).toDouble();
        case 'eur':
          return (wallet['eur_balance'] ?? 0.0).toDouble();
        case 'btc':
          return (wallet['btc_balance'] ?? 0.0).toDouble();
        case 'eth':
          return (wallet['eth_balance'] ?? 0.0).toDouble();
        case 'tam_token':
          return (wallet['tam_token_balance'] ?? 0.0).toDouble();
        default:
          return 0.0;
      }
    } catch (e) {
      debugPrint('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Static methods for backward compatibility
  static Future<Map<String, dynamic>?> getWallet() async {
    return await instance.getUserWallet();
  }

  static Future<bool> addFunds({
    required double amount,
    required String currency,
    String? paymentMethod,
  }) async {
    return await instance.addMoneyToWallet(
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
    );
  }

  static Future<List<Map<String, dynamic>>> getTransactions({
    int limit = 50,
  }) async {
    return await instance.getTransactionHistory(limit: limit);
  }
}
