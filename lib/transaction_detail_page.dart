import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;
  final String status;
  const TransactionDetailPage({super.key, required this.transactionId, required this.status});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final supabase = Supabase.instance.client;
  late Future transactionFuture;

  @override
  void initState() {
    super.initState();
    transactionFuture = getTransactionDetail();
  }

  Future<List<dynamic>> getTransactionDetail() async {
    final merchants = await supabase.rpc('fetch_transaction_detail', params: {
      'transaction_id': widget.transactionId,
    });
    return merchants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         toolbarHeight: 47,
        title: const Text(
          '详情',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder(
          future: transactionFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data.isEmpty) {
              return const Center(
                child: Text('No data found'),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xffD8D8D8),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '-RM${snapshot.data[0]['amount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xff2962F7),
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  transactionDetailCard(
                    '交易类型',
                    '支付',
                  ),
                  transactionDetailCard(
                    '商家',
                    snapshot.data[0]['name'].toString(),
                  ),
                  transactionDetailCard(
                    '款项详情',
                    '支付 - ${snapshot.data[0]['name'].toString()}',
                  ),
                  transactionDetailCard(
                    '付款方式',
                    '电子钱包余额',
                  ),
                  transactionDetailCard(
                    '日期/时间',
                    DateFormat('dd/MM/yyyy hh:mm:ss')
                          .format(DateTime.parse(snapshot.data[0]['created_at']).toLocal()),
                  ),
                  transactionDetailCard(
                    '钱包参考号',
                    snapshot.data[0]['reference'].toString(),
                  ),
                  transactionDetailCard(
                    '状态',
                    widget.status,
                  ),
                  transactionDetailCard(
                    '交易编号',
                    '2JLifG2n',
                  ),
                ],
              ),
            );
          }),
    );
  }
}

Widget transactionDetailCard(
  String title,
  String value,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xffD8D8D8),
          width: 1.0,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xff787878),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(color: Color(0xff282828)),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
