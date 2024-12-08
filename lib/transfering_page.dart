import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/receipt_page.dart';

class TransferingPage extends StatefulWidget {
  const TransferingPage({super.key});

  @override
  State<TransferingPage> createState() => _TransferingPageState();
}

class _TransferingPageState extends State<TransferingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
