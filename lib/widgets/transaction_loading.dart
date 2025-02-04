import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionLoading extends StatelessWidget {
  const TransactionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffc0dffe),
      bottomNavigationBar: const Image(
        image: AssetImage('assets/images/cny-bottom-ads.png'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 200,
              child: Image(
                image: const AssetImage('assets/images/cloud.png'),
                width: MediaQuery.of(context).size.width / 3,
              )
                  .animate(
                    onComplete: (controller) => controller.repeat(),
                  )
                  .moveX(
                      duration: const Duration(seconds: 2),
                      begin: MediaQuery.of(context).size.width + 100,
                      end: -MediaQuery.of(context).size.width),
            ),
            Positioned(
              top: 300,
              child: Image(
                image: const AssetImage('assets/images/cloud.png'),
                width: MediaQuery.of(context).size.width / 2,
              )
                  .animate(
                    onComplete: (controller) => controller.repeat(),
                  )
                  .moveX(
                      duration: const Duration(seconds: 1),
                      begin: MediaQuery.of(context).size.width,
                      end: -MediaQuery.of(context).size.width),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 125,
                ),
                Center(
                    child: Image(
                  image: const AssetImage('assets/images/transfer_money.png'),
                  width: MediaQuery.of(context).size.width / 2.5,
                )
                        .animate(
                          // onComplete: (controller) => controller.repeat(),
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          duration: const Duration(milliseconds: 500),
                          begin: 1.0,
                          end: 1.2,
                          delay: const Duration(milliseconds: 500),
                        )),
                const SizedBox(
                  height: 50,
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
                  height: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
