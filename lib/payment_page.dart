import 'dart:math';

import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/payment_receipt_page.dart';
import 'package:tng/show_dialog.dart';
import 'package:tng/widgets/transaction_loading.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> merchant;
  const PaymentPage({super.key, required this.merchant});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with WidgetsBindingObserver {
  bool isKeyin = false;
  bool isPaymentProcessing = false;
  CurrencyTextFieldController controller = CurrencyTextFieldController(
      currencySymbol: '', decimalSymbol: '.', thousandSymbol: ',');
  String merchantNameFromClipboard = '';
  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    copyFromClipboard();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      copyFromClipboard();
    }
  }

  void copyFromClipboard() async {
    if (widget.merchant['name'] != 'default sme') return;
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data == null) return;
    if (merchantNameFromClipboard == data.text) return;
    setState(() {
      merchantNameFromClipboard = data.text ?? '';
    });
  }

  Future<void> saveTransaction() async {
    ShowDialog.loadingDialog(context);
    await _authenticate();
    if (!authenticated) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> transactions = [];
    if (widget.merchant['name'] == 'default sme') {
      final merchants = await supabase.from('merchants').upsert({
        'name': merchantNameFromClipboard,
      }, onConflict: 'name').select();
      transactions = await supabase.from('transactions').insert({
        'merchant_id': merchants[0]['id'],
        'amount': controller.text,
        'reference': '${DateFormat('yyyyMMdd').format(DateTime.now())}10110000010000TNGOW3MY17135317${1000000 + Random().nextInt(9999999)}',
      }).select('*, merchants(*)');
    } else {
      transactions = await supabase.from('transactions').insert({
        'merchant_id': widget.merchant['id'],
        'amount': controller.text,
        'reference': '${DateFormat('yyyyMMdd').format(DateTime.now())}10110000010000TNGOW3MY17135317${1000000 + Random().nextInt(9999999)}',
      }).select('*, merchants(*)');
    }

    if (!mounted) return;
    Navigator.pop(context);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isPaymentProcessing = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isPaymentProcessing = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentReceiptPage(
            transactions: transactions,
          ),
        ),
      );
    });
  }

  Future<void> _authenticate() async {
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return;
    }
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isPaymentProcessing
        ? const TransactionLoading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                '支付',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/merchant_icon.png'),
                        height: 42,
                        width: 42,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          merchantNameFromClipboard.isEmpty
                              ? widget.merchant['name']
                              : merchantNameFromClipboard,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xfffafafa),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        cursorColor: const Color(0xff0064ff),
                        decoration: InputDecoration(
                          labelText: '金额',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: WidgetStateTextStyle.resolveWith(
                              (Set<WidgetState> states) {
                            final Color color =
                                states.contains(WidgetState.focused)
                                    ? const Color(0xff0064ff)
                                    : const Color(0xff646464);
                            return TextStyle(color: color);
                          }),
                          prefix: const Padding(
                            padding: EdgeInsets.only(
                              right: 4,
                            ),
                            child: Text(
                              'RM',
                              style: TextStyle(
                                color: Color(0xff0064ff),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff646464),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff0064ff),
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0064ff),
                        ),
                        onChanged: (value) {
                          if (!isKeyin) {
                            setState(() {
                              isKeyin = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const TextField(
                    maxLength: 25,
                    decoration: InputDecoration(
                      labelText: '款项详情 (可选的)',
                      labelStyle: TextStyle(
                        color: Color(0xff787878),
                      ),
                      filled: true,
                      fillColor: Color(0xfff9f9f9),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xff0064ff),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff0064ff),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffb4b4b4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              isKeyin ? const Color(0xff0064ff) : const Color(0xffe9e9e9),
                        ),
                        onPressed: isKeyin ? saveTransaction : null,
                        child: Text(
                          '确认',
                          style: TextStyle(
                            color: isKeyin ? Colors.white : const Color(0xff969696),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
