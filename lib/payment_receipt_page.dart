import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentReceiptPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  const PaymentReceiptPage({super.key, required this.transactions});

  @override
  State<PaymentReceiptPage> createState() => _PaymentReceiptPageState();
}

class _PaymentReceiptPageState extends State<PaymentReceiptPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).popUntil((ModalRoute.withName('/')));
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 16.0,
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xff2665fe),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((ModalRoute.withName('/')));
                },
                child: Text('完成'),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff52d865),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check_outlined,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'RM ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontSize: 28),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              ' ${widget.transactions[0]['amount'].toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    '已付',
                    style: TextStyle(
                      color: Color(0xff787878),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '商家',
                          style: TextStyle(
                            color: Color(0xff777777),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.transactions[0]['merchants']['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '交易类型',
                            style: TextStyle(
                              color: Color(0xff777777),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image(
                                image: AssetImage('assets/images/duitnow.png'),
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Flexible(
                                child: Text(
                                  'DuitNow QR TNGD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '日期/时间',
                          style: TextStyle(
                            color: Color(0xff777777),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy HH:mm:ss').format(
                            DateTime.parse(widget.transactions[0]['datetime'])
                                .toLocal(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '电子钱包参考编号',
                          style: TextStyle(
                            color: Color(0xff777777),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${DateFormat('yyyyMMdd').format(DateTime.now())}10110000010000TNGOW3MY171353140408728',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '付款方式',
                          style: TextStyle(
                            color: Color(0xff777777),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '电子钱包余额',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
