import 'package:nawasena/core/network/api_client.dart';
import 'package:nawasena/features/shop/models/shop_item_model.dart';

class ShopRepository {
  ShopRepository._();
  static final ShopRepository instance = ShopRepository._();

  final _api = ApiClient.instance;

  Future<ShopResponse> fetchShop() async {
    return await _api.get<ShopResponse>(
      '/v1/shop',
      parser: (data) {
        final d = (data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        final currencies = (d['user_currencies'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt()));
        final items = (d['items'] as List<dynamic>? ?? [])
            .map((e) {
              final itemMap = e is Map<String, dynamic> ? e : (e as Map).cast<String, dynamic>();
              return ShopItemModel.fromJson(itemMap);
            })
            .toList();
        return ShopResponse(userCurrencies: currencies, items: items);
      },
    );
  }

  Future<Map<String, dynamic>> purchaseItem(int itemId) async {
    return await _api.post<Map<String, dynamic>>(
      '/v1/shop/$itemId/buy',
      parser: (data) => (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }
}
