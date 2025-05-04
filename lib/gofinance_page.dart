import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/scan_page.dart';
import 'package:tng/transaction_detail_page.dart';
import 'package:tng/transaction_history_page.dart';

class GofinancePage extends StatefulWidget {
  const GofinancePage({super.key});

  @override
  State<GofinancePage> createState() => _GofinancePageState();
}

class _GofinancePageState extends State<GofinancePage>
    with SingleTickerProviderStateMixin {
  late final _tabController =
      TabController(length: 2, vsync: this, initialIndex: 1);
  final supabase = Supabase.instance.client;
  late Future transactionFuture;

  @override
  void initState() {
    super.initState();
    transactionFuture = getTransactions(1);
  }

  Future<List<dynamic>> getTransactions(int pageKey) async {
    final merchants = await supabase.rpc('fetch_transactions', params: {
      'page_number': pageKey,
      'limit_number': 3,
    });
    return merchants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        toolbarHeight: 38,
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text(
          'GOfinance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(
          0xff2459B7,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.yellow,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xffAABBD5),
          tabs: [
            const Tab(
              text: '简述',
            ),
            const Tab(
              text: '资金流动',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home_filled,
                      color: Color(0xff2962F7),
                    ),
                    Text(
                      '首页',
                      style: TextStyle(
                        color: Color(0xff2962F7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xff6d6d6d),
                    ),
                    Text(
                      'eShop',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScanPage(),
                    ),
                  );
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xff2052CD),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/scan.png',
                        width: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xff2962F7),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/gofinance.png',
                      width: 28,
                    ),
                    const Text(
                      'GOfinance',
                      style: TextStyle(
                        color: Color(0xff2962F7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xff6d6d6d),
                    ),
                    Text(
                      'Near Me',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                DateFormat('MMM yyyy').format(DateTime.now()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          Image.asset(
                            'assets/images/donut_chart.png',
                            width: double.infinity,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '查看详情',
                                style: TextStyle(
                                  color: Color(0xff2962F7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xff2962F7),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xff6D6D6D),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/ads_ctos.png',
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionHistoryPage(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text(
                                  '交易记录',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '查看全部',
                                  style: TextStyle(
                                    color: Color(0xff2962F7),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Color(0xff787878),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailPage(
                                        transactionId: snapshot.data[index]
                                            ['id'],
                                        status: '成功',
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                   Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailPage(
                                        transactionId: snapshot.data[index]
                                            ['id'],
                                        status: '处理中',
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          snapshot.data[index]['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '-RM${snapshot.data[index]['amount'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '支付',
                                          style: TextStyle(
                                            color: Color(0xff787878),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm')
                                              .format(DateTime.parse(
                                                      snapshot.data[index]
                                                          ['created_at'])
                                                  .toLocal()),
                                          style: const TextStyle(
                                            color: Color(0xff787878),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(
                                color: Color(0xffE4E9F2),
                                height: 24,
                                thickness: 1,
                              );
                            },
                            itemCount: snapshot.data.length,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
