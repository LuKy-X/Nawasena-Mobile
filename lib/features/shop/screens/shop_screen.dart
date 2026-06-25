import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/bouncy_tap.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/shop/models/shop_item_model.dart';
import 'package:nawasena/features/shop/providers/shop_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShop();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _ShopHeader(tabController: _tab),
          Expanded(
            child: Consumer<ShopProvider>(
              builder: (context, sp, _) {
                if (sp.isLoading) {
                  return Center(
                    child: MascotWidget(
                      pose: MascotPose.searching,
                      size: 100,
                      animate: true,
                    ),
                  );
                }
                if (sp.state == ShopState.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MascotWidget(pose: MascotPose.thinking, size: 100),
                        const SizedBox(height: 12),
                        Text(sp.error ?? 'Gagal memuat toko.',
                            style: const TextStyle(fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600, color: AppColors.mediumText)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => sp.loadShop(forceRefresh: true),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                if (sp.data == null) return const SizedBox.shrink();

                final utility  = sp.data!.items.where((i) => i.type == 'utility').toList();
                final cosmetic = sp.data!.items.where((i) => i.type == 'cosmetic').toList();

                return TabBarView(
                  controller: _tab,
                  children: [
                    _ItemGrid(items: utility),
                    _ItemGrid(items: cosmetic),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final TabController tabController;
  const _ShopHeader({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Title row + currency
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Row(
              children: [
                const Text(
                  '🏪 Toko',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 22,
                      fontWeight: FontWeight.w900, color: AppColors.darkText),
                ),
                const Spacer(),
                // Saldo diamonds
                Consumer<ShopProvider>(builder: (_, sp, __) {
                  if (sp.data == null) return const SizedBox.shrink();
                  return Row(
                    children: [
                      _CurrencyBadge(
                          emoji: '🪙', amount: sp.data!.coins,
                          color: AppColors.warningYellow),
                      const SizedBox(width: 8),
                      _CurrencyBadge(
                          emoji: '💎', amount: sp.data!.diamonds,
                          color: AppColors.primaryBrown),
                    ],
                  );
                }),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: tabController,
            labelStyle: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 14),
            unselectedLabelStyle: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14),
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.mediumText,
            indicatorColor: AppColors.primaryOrange,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Utilitas'),
              Tab(text: 'Kosmetik'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  final String emoji;
  final int    amount;
  final Color  color;
  const _CurrencyBadge({required this.emoji, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25), width: 1.5),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 4),
      Text('$amount',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800,
              fontSize: 13, color: color)),
    ]),
  );
}

class _ItemGrid extends StatelessWidget {
  final List<ShopItemModel> items;
  const _ItemGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          MascotWidget(pose: MascotPose.searching, size: 100),
          SizedBox(height: 12),
          Text('Tidak ada item saat ini.',
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                  color: AppColors.mediumText)),
        ]),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ShopCard(item: items[i]),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopItemModel item;
  const _ShopCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final emoji   = _emoji(item.slug);
    final color   = item.isDiamondItem ? AppColors.primaryBrown : AppColors.warningYellow;
    final canAfford = item.canAfford;

    return Consumer<ShopProvider>(builder: (context, sp, _) {
      final isBuying = sp.buyingItemId == item.id;
      return BouncyTap(
        enabled: canAfford && !isBuying,
        onTap: canAfford ? () => _confirmPurchase(context, sp) : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: canAfford ? color.withOpacity(0.3) : AppColors.borderGrey,
              width: 1.5,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: (canAfford ? color : AppColors.lockedGrey).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: canAfford ? AppColors.darkText : AppColors.lockedGrey,
                ),
              ),
              const SizedBox(height: 4),
              if (item.description != null)
                Text(
                  item.description!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              const Spacer(),
              // Harga
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (canAfford ? color : AppColors.lockedGrey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isBuying
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.isDiamondItem ? '💎' : '🪙',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.priceAmount}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: canAfford ? color : AppColors.lockedGrey,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _confirmPurchase(BuildContext context, ShopProvider sp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(item: item),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final msg = await sp.purchaseItem(item.id);
      if (context.mounted) {
        context.showSnack(msg ?? 'Pembelian berhasil! 🎉');
        // Update user data di AuthProvider
        // (user.coins/diamonds akan direfresh dari API di loadShop)
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnack(e.toString().replaceAll('ApiException(', '').replaceAll(')', ''),
            isError: true);
      }
    }
  }

  String _emoji(String slug) => switch (slug) {
    'heart_refill'          => '❤️',
    'streak_freeze'         => '🧊',
    String s when s.contains('blangkon') => '🪖',
    String s when s.contains('batik')  => '👘',
    String s when s.contains('frame')  => '🖼️',
    _                       => '🎁',
  };
}

class _ConfirmDialog extends StatelessWidget {
  final ShopItemModel item;
  const _ConfirmDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotWidget(pose: MascotPose.thinking, size: 90, animate: true),
            const SizedBox(height: 16),
            Text(
              'Beli "${item.name}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                fontSize: 18, color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu akan mengeluarkan ${item.priceAmount} '
              '${item.isDiamondItem ? 'Diamond' : 'Coin'}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                fontSize: 14, color: AppColors.mediumText,
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: NawasenaButton.outlined(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(context, false),
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NawasenaButton(
                  label: 'Beli',
                  color: AppColors.successGreen,
                  onPressed: () => Navigator.pop(context, true),
                  height: 48,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
