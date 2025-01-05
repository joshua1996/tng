import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantPage extends StatefulWidget {
  const MerchantPage({super.key});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  late Future merchantFuture;
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(getMerchants);
    _pagingController.addStatusListener(_showError);
  }

  Future<void> getMerchants(int pageKey) async {
    try {
      final merchants = await supabase
          .rpc('fetch_merchants_sorted_by_recent_transaction', params: {
        'p_name': controller.text,
        'page_number': pageKey,
        'limit_number': 20,
      });
      final isLastPage = merchants.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(merchants);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(merchants, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> _showError(PagingStatus status) async {
    if (status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.retryLastFailedRequest(),
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
        title: Text('Merchant'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
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
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Merchant Name',
                              ),
                            ),
                            SizedBox(
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
                                await supabase.from('merchants').upsert({
                                  'name': controller.text,
                                  'type': merchantType,
                                  'active': true,
                                }, onConflict: 'name');
                                if (!context.mounted) return;
                                _pagingController.refresh();
                                Navigator.pop(context);
                              },
                              child: Text('Add'),
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
                          border: OutlineInputBorder(),
                          labelText: 'Merchant Name',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
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
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _pagingController.refresh();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PagedListView<int, dynamic>.separated(
                pagingController: _pagingController,
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
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? value) async {
                                  setState(() {
                                    item['type'] = value!;
                                  });
                                  await supabase.from('merchants').update(
                                      {'type': value}).eq('id', item['id']);
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
                              Text(item['remark'] ?? ''),
                            ],
                          ),
                        ),
                        // const Spacer(),
                        Checkbox(
                          value: item['active'],
                          onChanged: (bool? newValue) async {
                            setState(() {
                              item['active'] = newValue;
                            });
                            await supabase.from('merchants').update(
                                {'active': newValue}).eq('id', item['id']);
                          },
                        ),
                      ],
                    );
                  },
                  firstPageErrorIndicatorBuilder: (context) =>
                      CustomFirstPageError(pagingController: _pagingController),
                  newPageErrorIndicatorBuilder: (context) =>
                      CustomNewPageError(pagingController: _pagingController),
                ),
                separatorBuilder: (context, index) => const Divider(),
                // itemCount: snapshot.data.length,
              ),
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

class CustomFirstPageError extends StatelessWidget {
  const CustomFirstPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<int, dynamic> pagingController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong :(',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (pagingController.error != null) ...[
            const SizedBox(
              height: 16,
            ),
            Text(
              pagingController.error.toString(),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(
            height: 48,
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: pagingController.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNewPageError extends StatelessWidget {
  const CustomNewPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<int, dynamic> pagingController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pagingController.retryLastFailedRequest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We didn\'t catch that. Try again?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Icon(
              Icons.refresh,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
