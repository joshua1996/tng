import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xffc0dffe),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image(
              image: const AssetImage('assets/images/transfer_money.png'),
              width: MediaQuery.of(context).size.width / 2,
            ),
          ),
          const SizedBox(
            height: 75,
          ),
          const Text(
            'Transferring your\nmoney safely...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 75,
          ),
          Image(
            image: const AssetImage('assets/images/cloud.png'),
            width: MediaQuery.of(context).size.width / 2,
          ),
        ],
      ),
    );
  }
}
