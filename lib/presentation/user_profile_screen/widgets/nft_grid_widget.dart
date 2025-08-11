import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NftGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> nfts;
  final Function(Map<String, dynamic>) onNftTap;

  const NftGridWidget({
    Key? key,
    required this.nfts,
    required this.onNftTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nfts.isEmpty) {
      return Container(
        height: 30.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'token',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              "No NFTs to display",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 1.h),
              child: Text(
                "NFT badges and collectibles will appear here",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(6.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 0.8,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        final nft = nfts[index];
        return GestureDetector(
          onTap: () => onNftTap(nft),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NFT Image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      children: [
                        CustomImageWidget(
                          imageUrl: nft["image"] as String? ??
                              "https://images.pexels.com/photos/7567443/pexels-photo-7567443.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        // Rarity Badge
                        Positioned(
                          top: 2.w,
                          right: 2.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 1.w),
                            decoration: BoxDecoration(
                              color: _getRarityColor(
                                  nft["rarity"] as String? ?? "common"),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (nft["rarity"] as String? ?? "common")
                                  .toUpperCase(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // NFT Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NFT Name
                        Text(
                          nft["name"] as String? ?? "Unnamed NFT",
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 1.h),

                        // Price and Collection
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nft["collection"] as String? ?? "Unknown",
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (nft["price"] != null)
                                    Text(
                                      "${nft["price"]} ETH",
                                      style: AppTheme
                                          .lightTheme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Blockchain Icon
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'currency_bitcoin',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 4.w,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
