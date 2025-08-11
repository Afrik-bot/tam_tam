import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletBalanceCard extends StatelessWidget {
  final Map<String, dynamic> wallet;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onConvert;

  const WalletBalanceCard({
    Key? key,
    required this.wallet,
    this.onDeposit,
    this.onWithdraw,
    this.onConvert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade800,
            Colors.blue.shade800,
            Colors.teal.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tam Tam Wallet',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 6.w,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Currency Balances
          _buildCurrencyBalance(
            'USD',
            wallet['usd_balance']?.toString() ?? '0.00',
            '\$',
            Colors.green.shade300,
          ),

          SizedBox(height: 2.h),

          _buildCurrencyBalance(
            'EUR',
            wallet['eur_balance']?.toString() ?? '0.00',
            '€',
            Colors.blue.shade300,
          ),

          SizedBox(height: 2.h),

          _buildCurrencyBalance(
            'TAM Token',
            wallet['tam_token_balance']?.toString() ?? '0.00',
            'TAM',
            Colors.yellow.shade300,
          ),

          SizedBox(height: 2.h),

          _buildCryptoCurrency(
            'Bitcoin',
            wallet['btc_balance']?.toString() ?? '0.00000000',
            'BTC',
            Colors.orange.shade300,
          ),

          SizedBox(height: 2.h),

          _buildCryptoCurrency(
            'Ethereum',
            wallet['eth_balance']?.toString() ?? '0.000000000000000000',
            'ETH',
            Colors.indigo.shade300,
          ),

          SizedBox(height: 4.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Deposit',
                  Icons.add_circle_outline,
                  Colors.green.shade400,
                  onDeposit,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  'Withdraw',
                  Icons.remove_circle_outline,
                  Colors.red.shade400,
                  onWithdraw,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  'Convert',
                  Icons.swap_horiz,
                  Colors.blue.shade400,
                  onConvert,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Total Stats
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildCurrencyBalance(
    String currency,
    String balance,
    String symbol,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              currency,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.white.withAlpha(204),
              ),
            ),
          ],
        ),
        Text(
          '$symbol$balance',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoCurrency(
    String currency,
    String balance,
    String symbol,
    Color accentColor,
  ) {
    // Format crypto balance to show meaningful digits
    final balanceValue = double.tryParse(balance) ?? 0.0;
    final formattedBalance = balanceValue == 0.0
        ? '0.00'
        : balanceValue < 0.001
            ? balanceValue.toStringAsExponential(3)
            : balanceValue.toStringAsFixed(8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  symbol.substring(0, 1),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              currency,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.white.withAlpha(204),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$formattedBalance $symbol',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (balanceValue > 0) ...[
              Text(
                '≈ \$${(balanceValue * (symbol == 'BTC' ? 45000 : 3000)).toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: Colors.white.withAlpha(153),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: color.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 5.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalEarned = wallet['total_earned']?.toString() ?? '0.00';
    final totalSpent = wallet['total_spent']?.toString() ?? '0.00';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Total Earned',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: Colors.white.withAlpha(179),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '\$$totalEarned',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade300,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 5.h,
            color: Colors.white.withAlpha(51),
          ),
          Column(
            children: [
              Text(
                'Total Spent',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: Colors.white.withAlpha(179),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '\$$totalSpent',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
