import 'package:cake_wallet/bitcoin/bitcoin.dart';
import 'package:cake_wallet/store/app_store.dart';
import 'package:cake_wallet/view_model/dashboard/action_list_item.dart';
import 'package:cake_wallet/view_model/dashboard/anonpay_transaction_list_item.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:cw_core/transaction_direction.dart';
import 'package:cake_wallet/view_model/dashboard/transaction_list_item.dart';

part 'transaction_filter_store.g.dart';

class TransactionFilterStore = TransactionFilterStoreBase with _$TransactionFilterStore;

abstract class TransactionFilterStoreBase with Store {
  TransactionFilterStoreBase(this._appStore)
      : displayIncoming = true,
        displayOutgoing = true,
        displaySilentPayments = true;

  final AppStore _appStore;

  @observable
  bool displayIncoming;

  @observable
  bool displayOutgoing;

  @observable
  bool displaySilentPayments;

  @observable
  DateTime? startDate;

  @observable
  DateTime? endDate;

  @computed
  bool get displayAll => displayIncoming && displayOutgoing && displaySilentPayments;

  @action
  void toggleAll() {
    if (displayAll) {
      displayOutgoing = false;
      displayIncoming = false;
      displaySilentPayments = false;
    } else {
      displayOutgoing = true;
      displayIncoming = true;
      displaySilentPayments = true;
    }
  }

  @action
  void toggleIncoming() {
    displayIncoming = !displayIncoming;
  }

  @action
  void toggleOutgoing() {
    displayOutgoing = !displayOutgoing;
  }

  @action
  void toggleSilentPayments() {
    displaySilentPayments = !displaySilentPayments;
  }

  @action
  void changeStartDate(DateTime date) => startDate = date;

  @action
  void changeEndDate(DateTime date) => endDate = date;

  List<ActionListItem> filtered({required List<ActionListItem> transactions}) {
    var _transactions = <ActionListItem>[];
    final needToFilter = !displayAll || (startDate != null && endDate != null);

    if (needToFilter) {
      _transactions = transactions.where((item) {
        var allowed = true;

        if (allowed && startDate != null && endDate != null) {
          if (item is TransactionListItem) {
            allowed = (startDate?.isBefore(item.transaction.date) ?? false) &&
                (endDate?.isAfter(item.transaction.date) ?? false);
          } else if (item is AnonpayTransactionListItem) {
            allowed = (startDate?.isBefore(item.transaction.createdAt) ?? false) &&
                (endDate?.isAfter(item.transaction.createdAt) ?? false);
          }
        }

        if (allowed && (!displayAll)) {
          if (item is TransactionListItem) {
            final canShowSilentPayment = _appStore.wallet?.type == WalletType.bitcoin &&
                (bitcoin?.txIsReceivedSilentPayment(item.transaction) ?? false);

            allowed =
                (displayOutgoing && item.transaction.direction == TransactionDirection.outgoing) ||
                    (displayIncoming &&
                        item.transaction.direction == TransactionDirection.incoming &&
                        !canShowSilentPayment) ||
                    (displaySilentPayments && canShowSilentPayment);
          } else if (item is AnonpayTransactionListItem) {
            allowed = displayIncoming;
          }
        }

        return allowed;
      }).toList();
    } else {
      _transactions = transactions;
    }

    return _transactions;
  }
}
