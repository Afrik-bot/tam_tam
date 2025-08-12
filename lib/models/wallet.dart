import './user_profile.dart';

class Wallet {
  final String id;
  final String userId;
  final double usdBalance;
  final double tamTokenBalance;
  final double btcBalance;
  final double ethBalance;
  final double eurBalance;
  final double totalEarned;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    this.usdBalance = 0.0,
    this.tamTokenBalance = 0.0,
    this.btcBalance = 0.0,
    this.ethBalance = 0.0,
    this.eurBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      usdBalance: (json['usd_balance'] as num?)?.toDouble() ?? 0.0,
      tamTokenBalance: (json['tam_token_balance'] as num?)?.toDouble() ?? 0.0,
      btcBalance: (json['btc_balance'] as num?)?.toDouble() ?? 0.0,
      ethBalance: (json['eth_balance'] as num?)?.toDouble() ?? 0.0,
      eurBalance: (json['eur_balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'usd_balance': usdBalance,
      'tam_token_balance': tamTokenBalance,
      'btc_balance': btcBalance,
      'eth_balance': ethBalance,
      'eur_balance': eurBalance,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get totalBalance =>
      usdBalance + tamTokenBalance + btcBalance + ethBalance + eurBalance;

  String getFormattedBalance(WalletCurrency currency) {
    switch (currency) {
      case WalletCurrency.usd:
        return '\$${usdBalance.toStringAsFixed(2)}';
      case WalletCurrency.eur:
        return '€${eurBalance.toStringAsFixed(2)}';
      case WalletCurrency.btc:
        return '${btcBalance.toStringAsFixed(8)} BTC';
      case WalletCurrency.eth:
        return '${ethBalance.toStringAsFixed(6)} ETH';
      case WalletCurrency.tamToken:
        return '${tamTokenBalance.toStringAsFixed(2)} TAM';
    }
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String? fromUserId;
  final String? toUserId;
  final double amount;
  final WalletCurrency currency;
  final String transactionType;
  final PaymentStatus status;
  final double feeAmount;
  final String? referenceId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final UserProfile? fromUser;
  final UserProfile? toUser;

  WalletTransaction({
    required this.id,
    required this.walletId,
    this.fromUserId,
    this.toUserId,
    required this.amount,
    required this.currency,
    required this.transactionType,
    this.status = PaymentStatus.pending,
    this.feeAmount = 0.0,
    this.referenceId,
    this.metadata = const {},
    required this.createdAt,
    this.fromUser,
    this.toUser,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    UserProfile? fromUser;
    UserProfile? toUser;

    if (json['from_user'] != null) {
      fromUser =
          UserProfile.fromJson(json['from_user'] as Map<String, dynamic>);
    }

    if (json['to_user'] != null) {
      toUser = UserProfile.fromJson(json['to_user'] as Map<String, dynamic>);
    }

    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      fromUserId: json['from_user_id'] as String?,
      toUserId: json['to_user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: WalletCurrency.values.firstWhere(
        (e) => e.toString().split('.').last == json['currency'],
        orElse: () => WalletCurrency.tamToken,
      ),
      transactionType: json['transaction_type'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0.0,
      referenceId: json['reference_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      fromUser: fromUser,
      toUser: toUser,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedAmount {
    final prefix = transactionType == 'tip' || transactionType == 'transfer'
        ? (toUserId != null ? '+' : '-')
        : '';

    switch (currency) {
      case WalletCurrency.usd:
        return '$prefix\$${amount.toStringAsFixed(2)}';
      case WalletCurrency.eur:
        return '$prefix€${amount.toStringAsFixed(2)}';
      case WalletCurrency.btc:
        return '$prefix${amount.toStringAsFixed(8)} BTC';
      case WalletCurrency.eth:
        return '$prefix${amount.toStringAsFixed(6)} ETH';
      case WalletCurrency.tamToken:
        return '$prefix${amount.toStringAsFixed(2)} TAM';
    }
  }
}

enum WalletCurrency {
  usd,
  eur,
  btc,
  eth,
  tamToken,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}
