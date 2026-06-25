class ShopItemModel {
  final int    id;
  final String name;
  final String slug;
  final String type; // 'utility' | 'cosmetic'
  final String? description;
  final String? iconUrl;
  final int    priceAmount;
  final String priceCurrency; // 'coins' | 'diamonds'
  final bool   canAfford;
  final int    userBalance;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.description,
    this.iconUrl,
    required this.priceAmount,
    required this.priceCurrency,
    this.canAfford = false,
    this.userBalance = 0,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) => ShopItemModel(
    id:             (json['id']           as num).toInt(),
    name:           json['name']          as String? ?? '',
    slug:           json['slug']          as String? ?? '',
    type:           json['type']          as String? ?? 'utility',
    description:    json['description']   as String?,
    iconUrl:        json['icon_url']      as String?,
    priceAmount:    (json['price_amount'] as num?)?.toInt() ?? 0,
    priceCurrency:  json['price_currency'] as String? ?? 'coins',
    canAfford:      json['can_afford']    as bool? ?? false,
    userBalance:    (json['user_balance'] as num?)?.toInt() ?? 0,
  );

  bool get isDiamondItem => priceCurrency == 'diamonds';
}

class ShopResponse {
  final Map<String, int> userCurrencies; // {'coins': 500, 'diamonds': 30}
  final List<ShopItemModel> items;

  const ShopResponse({required this.userCurrencies, required this.items});

  int get coins    => userCurrencies['coins']    ?? 0;
  int get diamonds => userCurrencies['diamonds'] ?? 0;
}
