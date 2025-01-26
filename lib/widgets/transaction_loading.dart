import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionLoading extends StatelessWidget {
  const TransactionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffc0dffe),
      bottomNavigationBar: Image(
        image: AssetImage('assets/images/cny-bottom-ads.png'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 200,
              child: Image(
                image: AssetImage('assets/images/cloud.png'),
                width: MediaQuery.of(context).size.width / 3,
              )
                  .animate(
                    onComplete: (controller) => controller.repeat(),
                  )
                  .moveX(
                      duration: Duration(seconds: 2),
                      begin: MediaQuery.of(context).size.width + 100,
                      end: -MediaQuery.of(context).size.width),
            ),
            Positioned(
              top: 300,
              child: Image(
                image: AssetImage('assets/images/cloud.png'),
                width: MediaQuery.of(context).size.width / 2,
              )
                  .animate(
                    onComplete: (controller) => controller.repeat(),
                  )
                  .moveX(
                      duration: Duration(seconds: 1),
                      begin: MediaQuery.of(context).size.width,
                      end: -MediaQuery.of(context).size.width),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 125,
                ),
                Center(
                    child: Image(
                  image: AssetImage('assets/images/transfer_money.png'),
                  width: MediaQuery.of(context).size.width / 2.5,
                )
                        .animate(
                          // onComplete: (controller) => controller.repeat(),
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          duration: Duration(milliseconds: 500),
                          begin: 1.0,
                          end: 1.2,
                          delay: Duration(milliseconds: 500),
                        )),
                SizedBox(
                  height: 50,
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
