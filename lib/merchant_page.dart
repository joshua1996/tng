import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/widgets/infinite_scroll_pagination_error.dart';

class MerchantPage extends StatefulWidget {
  const MerchantPage({super.key});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();
  late final PagingController<int, dynamic> _pagingController =
      PagingController(
    fetchPage: (pageKey) => getMerchants(pageKey),
    getNextPageKey: (state) {
      if (state.pages != null && state.pages!.last.isEmpty) return null;
      return (state.keys?.last ?? 0) + 1;
    },
  );
  String sortOrder = 'last_transaction';

  @override
  void initState() {
    super.initState();
    // _pagingController.addPageRequestListener(getMerchants);
    _pagingController.addListener(_showError);
  }

  Future<List<dynamic>> getMerchants(int pageKey) async {
    final merchants = await supabase
        .rpc('fetch_merchants_sorted_by_recent_transaction', params: {
      'p_name': controller.text,
      'page_number': pageKey,
      'limit_number': 20,
      'sort_order': sortOrder,
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
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant'),
        actions: [
          IconButton(
            onPressed: () {
              sortOrder = sortOrder == 'last_transaction'
                  ? 'created_at'
                  : 'last_transaction';
              _pagingController.refresh();
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final controller = TextEditingController();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  String merchantType = 'sme';

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: StatefulBuilder(builder: (context, setStateModal) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Merchant Name',
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            DropdownButton<String>(
                              value: merchantType,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) async {
                                setStateModal(() {
                                  merchantType = value!;
                                });
                              },
                              items: [
                                'sme',
                                'p2p'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await supabase
                                    .from('merchants')
                                    .update({'active': false}).eq(
                                  'active',
                                  true,
                                );
                                await supabase.from('merchants').upsert({
                                  'name': controller.text,
                                  'type': merchantType,
                                  'active': true,
                                }, onConflict: 'name');
                                if (!context.mounted) return;
                                _pagingController.refresh();
                                Navigator.pop(context);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Merchant Name',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                controller.clear();
                                _pagingController.refresh();
                              });
                            },
                          )),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _pagingController.refresh();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PagingListener(
                  controller: _pagingController,
                  builder: (context, state, fetchNextPage) {
                    return PagedListView<int, dynamic>.separated(
                      // pagingController: _pagingController,
                      fetchNextPage: fetchNextPage,
                      state: state,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      builderDelegate: PagedChildBuilderDelegate(
                        animateTransitions: true,
                        itemBuilder: (context, item, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: Text(item['name'])),
                                    DropdownButton<String>(
                                      value: item['type'],
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? value) async {
                                        setState(() {
                                          item['type'] = value!;
                                        });
                                        await supabase
                                            .from('merchants')
                                            .update({'type': value}).eq(
                                                'id', item['id']);
                                      },
                                      items: ['sme', 'p2p']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    Text(item['remark'] ?? ''),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: item['active'],
                                onChanged: (bool? newValue) async {
                                  // setState(() {
                                  //   for (var i = 0;
                                  //       i < _pagingController.itemList!.length;
                                  //       i++) {
                                  //     _pagingController.itemList![i]['active'] =
                                  //         false;
                                  //   }
                                  //   item['active'] = newValue;
                                  // });
                                  await supabase
                                      .from('merchants')
                                      .update({'active': false}).eq(
                                    'active',
                                    true,
                                  );
                                  await supabase
                                      .from('merchants')
                                      .update({'active': newValue}).eq(
                                    'id',
                                    item['id'],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        firstPageErrorIndicatorBuilder: (context) =>
                            CustomFirstPageError(
                                pagingController: _pagingController),
                        newPageErrorIndicatorBuilder: (context) =>
                            CustomNewPageError(
                                pagingController: _pagingController),
                      ),
                      separatorBuilder: (context, index) => const Divider(),
                      // itemCount: snapshot.data.length,
                    );
                  }),
            ),
          ],
        ),
      ),

      // FutureBuilder(
      //   future: merchantFuture,
      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     switch (snapshot.connectionState) {
      //       case ConnectionState.waiting:
      //         return Center(child: CircularProgressIndicator());
      //       default:
      //         if (snapshot.hasError) {
      //           return Center(child: Text('Error: ${snapshot.error}'));
      //         }
      //     }
      //     if (snapshot.hasData) {
      //       return Column(
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Row(
      //               children: [
      //                 Expanded(
      //                   child: TextField(
      //                     controller: controller,
      //                     decoration: InputDecoration(
      //                         border: OutlineInputBorder(),
      //                         labelText: 'Merchant Name',
      //                         suffixIcon: IconButton(
      //                           icon: Icon(Icons.clear),
      //                           onPressed: () {
      //                             setState(() {
      //                               controller.clear();
      //                               getMerchants();
      //                             });
      //                           },
      //                         )),
      //                   ),
      //                 ),
      //                 IconButton(
      //                   icon: Icon(Icons.search),
      //                   onPressed: () {
      //                     setState(() {
      //                       getMerchants();
      //                     });
      //                   },
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Expanded(
      //             child: ListView.separated(
      //               padding: const EdgeInsets.symmetric(
      //                 vertical: 16,
      //                 horizontal: 16,
      //               ),
      //               itemBuilder: (context, index) {
      //                 return Row(
      //                   children: [
      //                     Expanded(
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         mainAxisSize: MainAxisSize.min,
      //                         children: [
      //                           Flexible(
      //                               child: Text(snapshot.data[index]['name'])),
      //                           DropdownButton<String>(
      //                             value: snapshot.data[index]['type'],
      //                             icon: const Icon(Icons.arrow_downward),
      //                             elevation: 16,
      //                             style:
      //                                 const TextStyle(color: Colors.deepPurple),
      //                             underline: Container(
      //                               height: 2,
      //                               color: Colors.deepPurpleAccent,
      //                             ),
      //                             onChanged: (String? value) async {
      //                               setState(() {
      //                                 snapshot.data[index]['type'] = value!;
      //                               });
      //                               await supabase
      //                                   .from('merchants')
      //                                   .update({'type': value}).eq(
      //                                       'id', snapshot.data[index]['id']);
      //                             },
      //                             items: ['sme', 'p2p']
      //                                 .map<DropdownMenuItem<String>>(
      //                                     (String value) {
      //                               return DropdownMenuItem<String>(
      //                                 value: value,
      //                                 child: Text(value),
      //                               );
      //                             }).toList(),
      //                           ),
      //                           Text(snapshot.data[index]['remark'] ?? ''),
      //                         ],
      //                       ),
      //                     ),
      //                     // const Spacer(),
      //                     Checkbox(
      //                       value: snapshot.data[index]['active'],
      //                       onChanged: (bool? newValue) async {
      //                         setState(() {
      //                           snapshot.data[index]['active'] = newValue;
      //                         });
      //                         await supabase
      //                             .from('merchants')
      //                             .update({'active': newValue}).eq(
      //                                 'id', snapshot.data[index]['id']);
      //                       },
      //                     ),
      //                   ],
      //                 );
      //               },
      //               separatorBuilder: (context, index) => const Divider(),
      //               itemCount: snapshot.data.length,
      //             ),
      //           ),
      //         ],
      //       );
      //     } else if (snapshot.hasError) {
      //       return Text('${snapshot.error}');
      //     } else {
      //       return Center(child: const CircularProgressIndicator());
      //     }
      //   },
      // ),
    );
  }
}
