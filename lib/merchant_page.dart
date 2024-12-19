import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantPage extends StatefulWidget {
  const MerchantPage({super.key});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  late Future merchantFuture;
  bool? value = false;
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMerchants('');
  }

  void getMerchants(String pName) {
    merchantFuture =
        supabase.rpc('fetch_merchants_sorted_by_recent_transaction', params: {'p_name': pName});
        // .like('p_name', '%$pName%');
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
                                await supabase.from('merchants').insert({
                                  'name': controller.text,
                                  'type': merchantType,
                                  'active': true,
                                });
                                if (!context.mounted) return;
                                setState(() {
                                  getMerchants(controller.text);
                                });
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
      body: FutureBuilder(
        future: merchantFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
          }
          if (snapshot.hasData) {
            return Column(
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
                                  getMerchants('');
                                });
                              },
                            )
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            getMerchants(controller.text);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    child: Text(snapshot.data[index]['name'])),
                                DropdownButton<String>(
                                  value: snapshot.data[index]['type'],
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
                                      snapshot.data[index]['type'] = value!;
                                    });
                                    await supabase
                                        .from('merchants')
                                        .update({'type': value}).eq(
                                            'id', snapshot.data[index]['id']);
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
                                Text(snapshot.data[index]['remark'] ?? ''),
                              ],
                            ),
                          ),
                          // const Spacer(),
                          Checkbox(
                            value: snapshot.data[index]['active'],
                            onChanged: (bool? newValue) async {
                              setState(() {
                                snapshot.data[index]['active'] = newValue;
                              });
                              await supabase
                                  .from('merchants')
                                  .update({'active': newValue}).eq(
                                      'id', snapshot.data[index]['id']);
                            },
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: snapshot.data.length,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
