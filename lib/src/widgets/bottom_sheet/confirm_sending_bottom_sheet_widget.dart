import 'package:cake_wallet/generated/i18n.dart';
import 'package:cake_wallet/src/widgets/standard_slide_button_widget.dart';
import 'package:cake_wallet/themes/extensions/balance_page_theme.dart';
import 'package:cake_wallet/themes/extensions/cake_text_theme.dart';
import 'package:cake_wallet/themes/extensions/filter_theme.dart';
import 'package:cake_wallet/themes/extensions/sync_indicator_theme.dart';
import 'package:cake_wallet/themes/theme_base.dart';
import 'package:cake_wallet/utils/address_formatter.dart';
import 'package:cake_wallet/view_model/send/output.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/pending_transaction.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:flutter/material.dart';

import 'base_bottom_sheet_widget.dart';

class ConfirmSendingBottomSheet extends BaseBottomSheet {
  final CryptoCurrency currency;
  final ThemeBase currentTheme;
  final String? paymentId;
  final String? paymentIdValue;
  final String? expirationTime;
  final String amount;
  final String amountValue;
  final String fiatAmountValue;
  final String fee;
  final String feeValue;
  final String feeFiatAmount;
  final List<Output> outputs;
  final VoidCallback onSlideComplete;
  final WalletType walletType;
  final PendingChange? change;
  final bool isOpenCryptoPay;

  ConfirmSendingBottomSheet({
    required String titleText,
    String? titleIconPath,
    required this.currency,
    required this.currentTheme,
    this.paymentId,
    this.paymentIdValue,
    this.expirationTime,
    required this.amount,
    required this.amountValue,
    required this.fiatAmountValue,
    required this.fee,
    required this.feeValue,
    required this.feeFiatAmount,
    required this.outputs,
    required this.onSlideComplete,
    required this.walletType,
    this.change,
    this.isOpenCryptoPay = false,
    Key? key,
  })  : showScrollbar = outputs.length > 3,
        super(titleText: titleText, titleIconPath: titleIconPath);

  final bool showScrollbar;
  final ScrollController scrollController = ScrollController();

  @override
  Widget contentWidget(BuildContext context) {
    final itemTitleTextStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      color: Theme.of(context).extension<CakeTextTheme>()!.titleColor,
      decoration: TextDecoration.none,
    );
    final itemSubTitleTextStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600,
      color: currentTheme.type == ThemeType.bright
          ? Theme.of(context).extension<CakeTextTheme>()!.titleColor
          : Theme.of(context).extension<BalancePageTheme>()!.labelTextColor,
      decoration: TextDecoration.none,
    );

    final tileBackgroundColor = currentTheme.type == ThemeType.light
        ? Theme.of(context).extension<SyncIndicatorTheme>()!.syncedBackgroundColor
        : currentTheme.type == ThemeType.oled
        ? Colors.black.withOpacity(0.5)
        : Theme.of(context).extension<FilterTheme>()!.buttonColor;

    Widget content = Padding(
      padding: EdgeInsets.fromLTRB(8, 0, showScrollbar ? 16 : 8, 8),
      child: Column(
        children: [
          if (paymentId != null && paymentIdValue != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AddressTile(
                itemTitle: paymentId!,
                currentTheme: currentTheme,
                itemTitleTextStyle: itemTitleTextStyle,
                walletType: walletType,
                isBatchSending: false,
                amount: '',
                address: paymentIdValue!,
                itemSubTitleTextStyle: itemSubTitleTextStyle,
                tileBackgroundColor: tileBackgroundColor,
              ),
            ),
          StandardTile(
            itemTitle: amount,
            itemValue: amountValue + ' ${currency.title}',
            itemTitleTextStyle: itemTitleTextStyle,
            itemSubTitle: fiatAmountValue,
            itemSubTitleTextStyle: itemSubTitleTextStyle,
            tileBackgroundColor: tileBackgroundColor,
          ),
          const SizedBox(height: 8),
          StandardTile(
            itemTitle: fee,
            itemValue: feeValue,
            itemTitleTextStyle: itemTitleTextStyle,
            itemSubTitle: feeFiatAmount,
            itemSubTitleTextStyle: itemSubTitleTextStyle,
            tileBackgroundColor: tileBackgroundColor,
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              ListView.separated(
                padding: const EdgeInsets.only(top: 0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: outputs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final bool isBatchSending = outputs.length > 1;
                  final item = outputs[index];
                  final contactName = item.parsedAddress.name;
                  final batchContactTitle =
                      '${index + 1}/${outputs.length} - ${contactName.isEmpty ? 'Address' : contactName}';
                  final _address = item.isParsedAddress ? item.extractedAddress : item.address;
                  final _amount = item.cryptoAmount.replaceAll(',', '.') + ' ${currency.title}';
                  return isBatchSending || contactName.isNotEmpty
                      ? AddressExpansionTile(
                          contactType: isOpenCryptoPay ? 'Open CryptoPay' : S.of(context).contact,
                          currentTheme: currentTheme,
                          name: isBatchSending ? batchContactTitle : contactName,
                          address: _address,
                          amount: _amount,
                          walletType: walletType,
                          isBatchSending: isBatchSending,
                          itemTitleTextStyle: itemTitleTextStyle,
                          itemSubTitleTextStyle: itemSubTitleTextStyle,
                          tileBackgroundColor: tileBackgroundColor,
                        )
                      : AddressTile(
                          itemTitle: S.of(context).address,
                          currentTheme: currentTheme,
                          itemTitleTextStyle: itemTitleTextStyle,
                          isBatchSending: isBatchSending,
                          walletType: walletType,
                          amount: _amount,
                          address: _address,
                          itemSubTitleTextStyle: itemSubTitleTextStyle,
                          tileBackgroundColor: tileBackgroundColor,
                        );
                },
              ),
              if (change != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AddressExpansionTile(
                    contactType: 'Change',
                    currentTheme: currentTheme,
                    name: S.of(context).send_change_to_you,
                    address: change!.address,
                    amount: change!.amount + ' ${currency.title}',
                    isBatchSending: true,
                    walletType: walletType,
                    itemTitleTextStyle: itemTitleTextStyle,
                    itemSubTitleTextStyle: itemSubTitleTextStyle,
                    tileBackgroundColor: tileBackgroundColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (showScrollbar) {
      return SizedBox(
        height: 380,
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: content,
          ),
        ),
      );
    } else {
      return content;
    }
  }

  @override
  Widget footerWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 34),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        boxShadow: [
          if (showScrollbar)
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: StandardSlideButton(
        onSlideComplete: onSlideComplete,
        buttonText: 'Swipe to send',
        currentTheme: currentTheme,
        accessibleNavigationModeButtonText: S.of(context).send,
      ),
    );
  }
}

class StandardTile extends StatelessWidget {
  const StandardTile({
    super.key,
    required this.itemTitle,
    required this.itemValue,
    required this.itemTitleTextStyle,
    this.itemSubTitle,
    required this.itemSubTitleTextStyle,
    required this.tileBackgroundColor,
  });

  final String itemTitle;
  final String itemValue;
  final TextStyle itemTitleTextStyle;
  final String? itemSubTitle;
  final TextStyle itemSubTitleTextStyle;
  final Color tileBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: itemTitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: tileBackgroundColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(itemTitle, style: itemTitleTextStyle),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(itemValue, style: itemTitleTextStyle),
                itemSubTitle == null
                    ? Container()
                    : Text(itemSubTitle!, style: itemSubTitleTextStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.itemTitle,
    required this.currentTheme,
    required this.itemTitleTextStyle,
    required this.isBatchSending,
    required this.amount,
    required this.address,
    required this.itemSubTitleTextStyle,
    required this.tileBackgroundColor,
    required this.walletType,
  });

  final String itemTitle;
  final ThemeBase currentTheme;
  final TextStyle itemTitleTextStyle;
  final bool isBatchSending;
  final String amount;
  final String address;
  final TextStyle itemSubTitleTextStyle;
  final Color tileBackgroundColor;
  final WalletType walletType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: tileBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(itemTitle, style: itemTitleTextStyle),
              if (isBatchSending) Text(amount, style: itemTitleTextStyle),
            ],
          ),
          AddressFormatter.buildSegmentedAddress(
            address: address,
            walletType: walletType,
            evenTextStyle: TextStyle(
                fontSize: 12,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).extension<CakeTextTheme>()!.titleColor,
                decoration: TextDecoration.none)
          ),
        ],
      ),
    );
  }
}

class AddressExpansionTile extends StatelessWidget {
  const AddressExpansionTile({
    super.key,
    required this.contactType,
    required this.currentTheme,
    required this.name,
    required this.address,
    required this.amount,
    required this.isBatchSending,
    required this.itemTitleTextStyle,
    required this.itemSubTitleTextStyle,
    required this.tileBackgroundColor,
    required this.walletType,
  });

  final String contactType;
  final ThemeBase currentTheme;
  final String name;
  final String address;
  final String amount;
  final bool isBatchSending;
  final TextStyle itemTitleTextStyle;
  final TextStyle itemSubTitleTextStyle;
  final Color tileBackgroundColor;
  final WalletType walletType;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: name,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: tileBackgroundColor,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: isBatchSending ? 0 : 8),
            child: ExpansionTile(
              childrenPadding: isBatchSending ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
              tilePadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(isBatchSending ? name : contactType,
                          style: itemTitleTextStyle, softWrap: true)),
                  Text(isBatchSending ? amount : name,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).extension<CakeTextTheme>()!.titleColor,
                        decoration: TextDecoration.none,
                      )),
                ],
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AddressFormatter.buildSegmentedAddress(
                          address: address,
                          walletType: walletType,
                          evenTextStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).extension<CakeTextTheme>()!.titleColor,
                              decoration: TextDecoration.none)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
