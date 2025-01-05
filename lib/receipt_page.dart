import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  const ReceiptPage({super.key, required this.transactions});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
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
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xff2367fb)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.share_outlined,
                      color: Color(0xff2367fb),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
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
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 75,
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
                    style:
                        DefaultTextStyle.of(context).style.copyWith(fontSize: 28),
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
                    fontWeight: FontWeight.bold,
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
                        '接收者',
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
                widget.transactions[0]['merchants']['type'] == 'sme'
                    ? Padding(
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
                      )
                    : SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '日期与时间',
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
                        '钱包参考号',
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
    );
  }
}
