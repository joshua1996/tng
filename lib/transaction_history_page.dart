
import 'package:flutter/material.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/transaction_detail_page.dart';

// enum TransactionType {
//   transport,
//   food,
//   shopping,
//   entertainment,
//   health,
//   other,
// }

// class Transaction {
//   final String name;
//   final DateTime dateTime;
//   final double amount;
//   final TransactionType type;
//   Transaction({
//     required this.name,
//     required this.dateTime,
//     required this.amount,
//     required this.type,
//   });

//   @override
//   String toString() {
//     return '{name: $name, dateTime: $dateTime}';
//   }
// }

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final supabase = Supabase.instance.client;
  late final PagingController<int, dynamic> _pagingController =
      PagingController(
    fetchPage: (pageKey) => getTransactions(pageKey),
    getNextPageKey: (state) {
      if (state.pages != null && state.pages!.last.isEmpty) return null;
      return (state.keys?.last ?? 0) + 1;
    },
  );
  InfiniteGroupedListController<dynamic, DateTime, String> controller =
      InfiniteGroupedListController<dynamic, DateTime, String>();
  DateTime baseDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    // _pagingController.addListener(_showError);
  }

  Future<List> onLoadMore(int offset) async {
    print('offset: $offset');
    final merchants = await supabase.rpc('fetch_transactions', params: {
      'page_number': offset,
      'limit_number': 20,
    });
    return merchants;
  }

  // Future<List>onLoadMore(int offset) async {
  //   await Future.delayed(const Duration(seconds: 1));

  //   return List.generate(
  //     20,
  //     (index) {
  //       final tempDate = baseDate;
  //       baseDate = baseDate.subtract(const Duration(days: 1));
  //       return {
  //         'created_at': tempDate.toIso8601String(),
  //         'id': Random().nextInt(1000),
  //         'name': 'Transaction ${offset + index}',
  //       };
  //     },
  //   );
  // }

  Future<List<dynamic>> getTransactions(int pageKey) async {
    final merchants = await supabase.rpc('fetch_transactions', params: {
      'page_number': pageKey,
      'limit_number': 3,
    });
    return merchants;
  }

  Future<void> _showError() async {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.fetchNextPage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 46,
        title: const Text(
          '记录',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              '电邮',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(
                    alpha: 0.1,
                  ),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const IntrinsicHeight(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('07 Dec 24 - 05 Jan 25'),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xff5B9CF8),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: VerticalDivider(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Row(
                    children: [
                      Text('筛选'),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xff5B9CF8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child: PagingListener(
          //     controller: _pagingController,
          //     builder: (context, state, fetchNextPage) =>
          //         PagedListView<int, dynamic>.separated(
          //       state: state,
          //       fetchNextPage: fetchNextPage,
          //       itemExtent: 48,
          //       builderDelegate: PagedChildBuilderDelegate(
          //         animateTransitions: true,
          //         itemBuilder: (context, item, index) {
          //           return Text(item['name']);
          //         },
          //         firstPageErrorIndicatorBuilder: (context) =>
          //             CustomFirstPageError(pagingController: _pagingController),
          //         newPageErrorIndicatorBuilder: (context) =>
          //             CustomNewPageError(pagingController: _pagingController),
          //       ),
          //       separatorBuilder: (context, index) => const Divider(),
          //     ),
          //   ),
          // ),

          // Expanded(
          //   child: GroupedListView<dynamic, String>(
          //     elements: [
          //       {'name': 'John', 'group': 'Team A'},
          //       {'name': 'Will', 'group': 'Team B'},
          //       {'name': 'Beth', 'group': 'Team A'},
          //       {'name': 'Miranda', 'group': 'Team B'},
          //       {'name': 'Mike', 'group': 'Team C'},
          //       {'name': 'Danny', 'group': 'Team C'},
          //     ],
          //     groupBy: (element) => element['group'],
          //     groupSeparatorBuilder: (String groupByValue) =>
          //         Text(groupByValue),
          //     itemBuilder: (context, dynamic element) =>
          //         SizedBox(height: 300, child: Text(element['name'])),
          //     itemComparator: (item1, item2) =>
          //         item1['name'].compareTo(item2['name']), // optional
          //     useStickyGroupSeparators: false, // optional
          //     floatingHeader: true, // optional
          //     order: GroupedListOrder.ASC, // optional
          //     footer: Text("Widget at the bottom of list"), // optional
          //   ),
          // ),

//           Card(
//   color: Colors.white,
//   surfaceTintColor: Colors.white, // or Colors.transparent
//   elevation: 4,
//   child: Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Text('Your content here'),
//   ),
// ),

//           Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: Text('data')),

          Expanded(
            child: InfiniteGroupedList(
              stickyGroups: false,
              groupBy: (item) => DateTime.parse(item['created_at']),
              controller: controller,
              sortGroupBy: (item) => DateTime.parse(item['created_at']),
              initialItemsErrorWidget: (error) => GestureDetector(
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    color: Colors.blue,
                  ),
                ),
              ),
              groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
                  Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                color: const Color(0xffF5F5F5),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff777777),
                  ),
                ),
              ),
              itemBuilder: (item) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        transactionId: item['id'],
                        status: '成功',
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        transactionId: item['id'],
                        status: '处理中',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM, hh:mm').format(
                            DateTime.parse(item['created_at']).toLocal()),
                        style: const TextStyle(
                          color: Color(0xff777777),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '-RM${item['amount'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xff2B63EE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        '支付',
                        style: TextStyle(
                          color: Color(0xff777777),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onLoadMore: (info) => onLoadMore(info.page),
              groupCreator: (dateTime) {
                return DateFormat('MMM yyyy').format(dateTime);
              },
              seperatorBuilder: (p0) {
                return const Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.4,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
