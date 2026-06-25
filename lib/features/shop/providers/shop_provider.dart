import 'package:flutter/material.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/features/shop/models/shop_item_model.dart';
import 'package:nawasena/features/shop/repositories/shop_repository.dart';

enum ShopState { initial, loading, loaded, error }

class ShopProvider extends ChangeNotifier {
  final _repo = ShopRepository.instance;

  ShopState  _state  = ShopState.initial;
  ShopResponse? _data;
  String?    _error;
  int?       _buyingItemId;

  ShopState     get state       => _state;
  ShopResponse? get data        => _data;
  String?       get error       => _error;
  bool          get isLoading   => _state == ShopState.loading;
  int?          get buyingItemId => _buyingItemId;

  Future<void> loadShop({bool forceRefresh = false}) async {
    if (_state == ShopState.loaded && !forceRefresh) return;

    _state = ShopState.loading;
    notifyListeners();

    try {
      _data  = await _repo.fetchShop();
      _state = ShopState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = ShopState.error;
    } catch (_) {
      _error = 'Gagal memuat toko.';
      _state = ShopState.error;
    }
    notifyListeners();
  }

  /// Beli item, kembalikan pesan efek atau null jika gagal
  Future<String?> purchaseItem(int itemId) async {
    _buyingItemId = itemId;
    notifyListeners();

    try {
      final result = await _repo.purchaseItem(itemId);
      // Refresh data toko agar saldo & canAfford terupdate
      await loadShop(forceRefresh: true);
      _buyingItemId = null;
      notifyListeners();
      return result['effect_message'] as String?;
    } on ApiException catch (e) {
      _buyingItemId = null;
      notifyListeners();
      throw e;
    } catch (e) {
      _buyingItemId = null;
      notifyListeners();
      rethrow;
    }
  }
}
