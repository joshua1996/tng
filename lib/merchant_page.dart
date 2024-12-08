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

  @override
  void initState() {
    super.initState();
    getMerchants();
  }

  void getMerchants() {
    merchantFuture = supabase.from('merchants').select();
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
                                  getMerchants();
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
        future: merchantFuture, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
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
                          Flexible(child: Text(snapshot.data[index]['name'])),
                          DropdownButton<String>(
                            value: snapshot.data[index]['type'],
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
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
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
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
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
