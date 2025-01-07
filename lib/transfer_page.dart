import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/transfer_receipt_page.dart';
import 'package:tng/show_dialog.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> merchant;
  const TransferPage({super.key, required this.merchant});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with WidgetsBindingObserver {
  bool isKeyin = false;
  CurrencyTextFieldController controller = CurrencyTextFieldController(
      currencySymbol: '', decimalSymbol: '.', thousandSymbol: ',');
  bool isPaymentProcessing = false;
  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;
  String merchantNameFromClipboard = '';

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

  void copyFromClipboard() async {
    if (widget.merchant['name'] != 'default p2p') return;
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

    if (widget.merchant['name'] == 'default p2p') {
      final merchants = await supabase.from('merchants').insert({
        'name': merchantNameFromClipboard,
        'type': 'p2p',
      }).select();
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
          builder: (context) => TransferReceiptPage(
            transactions: transactions,
          ),
        ),
      );
    });
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
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                '转账',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
              ),
              color: Colors.white,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xff2665fe),
                ),
                onPressed: isKeyin ? saveTransaction : null,
                child: Text(
                  '确认转账',
                  style: TextStyle(
                      // color: isKeyin ? Colors.white : Color(0xff969696),
                      ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 105,
                        decoration: BoxDecoration(
                          color: Color(0xff005abe),
                        ),
                      ),
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '转账至',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade50),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey.withOpacity(0.2),
                                  //     spreadRadius: 1,
                                  //     blurRadius: 2,
                                  //     offset:
                                  //         Offset(0, 1), // changes position of shadow
                                  //   ),
                                  // ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 28,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xffc9efff),
                                            ),
                                            child: const Icon(
                                              Icons.person_outlined,
                                              color: Color(0xff2a62f6),
                                              size: 30,
                                            ),
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
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffebf3ff),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 12,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '转帐前, 请先验证收款人姓名。',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                      helper: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '您可以转账高达 RM 559.06',
                                              style: TextStyle(
                                                color: Color(
                                                  0xff787878,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(
                                            Icons.info_outline,
                                            color: Color(0xff1b3fec),
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle:
                                          WidgetStateTextStyle.resolveWith(
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
                                            // height: 1
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
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
                                  labelText: '转账说明',
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
                              Wrap(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  TransferOption(
                                    title: '资金转账',
                                  ),
                                  TransferOption(
                                    title: '餐饮',
                                  ),
                                  TransferOption(
                                    title: '礼物',
                                  ),
                                  TransferOption(
                                    title: '娱乐',
                                  ),
                                  TransferOption(
                                    title: '其他',
                                    isSelected: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class TransferOption extends StatefulWidget {
  final String title;
  final bool isSelected;
  const TransferOption(
      {super.key, required this.title, this.isSelected = false});

  @override
  State<TransferOption> createState() => _TransferOptionState();
}

class _TransferOptionState extends State<TransferOption> {
  @override
  Widget build(BuildContext context) {
    double? fontSize = 12.0;
    if (widget.isSelected) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xff0064ff),
              width: 1,
            )),
        child: Text(
          widget.title,
          style: TextStyle(
            color: Color(0xff0064ff),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xffefefef),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
