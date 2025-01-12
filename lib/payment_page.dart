import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/payment_receipt_page.dart';
import 'package:tng/show_dialog.dart';

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
      }).select('*, merchants(*)');
    } else {
      transactions = await supabase.from('transactions').insert({
        'merchant_id': widget.merchant['id'],
        'amount': controller.text,
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
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isPaymentProcessing
        ? Scaffold(
            backgroundColor: Color(0xffc0dffe),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image(
                    image: AssetImage('assets/images/transfer_money.png'),
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ),
                SizedBox(
                  height: 75,
                ),
                Text(
                  'Transferring your\nmoney safely...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 75,
                ),
                Image(
                  image: AssetImage('assets/images/cloud.png'),
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
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
                      Image(
                        image: AssetImage('assets/images/merchant_icon.png'),
                        height: 42,
                        width: 42,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          merchantNameFromClipboard.isEmpty
                              ? widget.merchant['name']
                              : merchantNameFromClipboard,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
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
                        cursorColor: Color(0xff0064ff),
                        decoration: InputDecoration(
                          labelText: '金额',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: WidgetStateTextStyle.resolveWith(
                              (Set<WidgetState> states) {
                            final Color color =
                                states.contains(WidgetState.focused)
                                    ? Color(0xff0064ff)
                                    : Color(0xff646464);
                            return TextStyle(color: color);
                          }),
                          prefix: Padding(
                            padding: const EdgeInsets.only(
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
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff646464),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff0064ff),
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: TextStyle(
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
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
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
                  SizedBox(
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
                              isKeyin ? Color(0xff0064ff) : Color(0xffe9e9e9),
                        ),
                        onPressed: isKeyin ? saveTransaction : null,
                        child: Text(
                          '确认',
                          style: TextStyle(
                            color: isKeyin ? Colors.white : Color(0xff969696),
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
