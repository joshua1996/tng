import 'package:circle_flags/circle_flags.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/payment_page.dart';
import 'package:tng/scanner_error_widget.dart';
import 'package:tng/show_dialog.dart';
import 'package:tng/transfer_page.dart';
import 'package:vibration/vibration.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  String scannedCode = '';

  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(
      begin: -220,
      end: 70,
    ).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _scanAnimationController.dispose();
    await controller.dispose();
  }

  Future<List<Map<String, dynamic>>> getMerchants() async {
    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> merchants =
        await supabase.from('merchants').select().eq('qrcode', scannedCode);
    if (merchants.isNotEmpty) {
      // Fluttertoast.showToast(
      //   msg: "Valid",
      //   fontSize: 12,
      //   backgroundColor: Colors.grey,
      // );
      Vibration.vibrate();
      return merchants;
    }
    merchants =
        await supabase.from('merchants').select().eq('active', true).limit(1);
    return merchants;
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 3.3,
      ),
      width: MediaQuery.of(context).size.width - 120,
      height: MediaQuery.of(context).size.width - 120,
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text(
          '扫码',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(
          0xff005abe,
        ),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
              onDetect: (barcodes) async {
                if (scannedCode.isEmpty) {
                  scannedCode =
                      barcodes.barcodes.firstOrNull?.displayValue ?? '';
                  ShowDialog.loadingDialog(context);
                  final merchants = await getMerchants();
                  await controller.stop();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (merchants[0]['type'] == 'sme') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          merchant: merchants.isEmpty ? {} : merchants[0],
                        ),
                      ),
                    );
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransferPage(
                          merchant: merchants.isEmpty ? {} : merchants[0],
                        ),
                      ),
                    );
                  }
                  scannedCode = '';
                  await controller.start();
                }
              },
            ),

            // ValueListenableBuilder(
            //   valueListenable: controller,
            //   builder: (context, value, child) {
            //     if (!value.isInitialized ||
            //         !value.isRunning ||
            //         value.error != null) {
            //       return const SizedBox();
            //     }

            //     return CustomPaint(
            //       painter: ScannerOverlay(scanWindow: scanWindow),
            //     );
            //   },
            // ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, _scanAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 98, 244, 247),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 98, 244, 247)
                              .withValues(alpha: 0.9),
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, -20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: const Text(
                '扫条码或二维码',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.55,
              left: MediaQuery.of(context).size.width / 2 - 66,
              child: Row(
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_library, color: Colors.white),
                            SizedBox(
                              width: 8,
                            ),
                            Text('图库'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/torch_light.png'),
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   top: MediaQuery.of(context).size.height * 0.5,
            //   right: 16,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey,
            //       shape: BoxShape.circle,
            //       border: Border.all(color: Colors.white, width: 1),
            //     ),
            //     child: const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Image(
            //         image: AssetImage('assets/images/torch_light.png'),
            //         height: 24,
            //         width: 24,
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.63,
              left: 0,
              right: 0,
              child: Container(
                height: 48,
                width: double.infinity,

                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 15, 37, 91),
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 4,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: 0 == 0 ? Colors.white : Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '扫码',
                            style: TextStyle(
                              color: 0 == 0
                                  ? const Color(0xff2253CC)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: 0 == 1 ? Colors.white : Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '付款',
                            style: TextStyle(
                              color: 0 == 1 ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: 0 == 2 ? Colors.white : Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '收款',
                            style: TextStyle(
                              color: 0 == 2 ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Expanded(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius:
                //               const BorderRadius.all(Radius.circular(100)),
                //           color: _tabIndex == 0 ? Colors.red : Colors.transparent,
                //         ),
                //         child: Text('扫码'),
                //       ),
                //     ),
                //     Expanded(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius:
                //               const BorderRadius.all(Radius.circular(100)),
                //           color: _tabIndex == 0 ? Colors.red : Colors.transparent,
                //         ),
                //         child: Text('扫码'),
                //       ),
                //     ),
                //     Expanded(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius:
                //               const BorderRadius.all(Radius.circular(100)),
                //           color: _tabIndex == 0 ? Colors.red : Colors.transparent,
                //         ),
                //         child: Text('扫码'),
                //       ),
                //     ),
                //   ],
                // ),

                // TabBar(
                //   indicatorWeight: 0,
                //   dividerColor: Colors.transparent,
                //   controller: tabController,
                //   indicator: BoxDecoration(
                //     borderRadius: BorderRadius.circular(
                //       100.0,
                //     ),
                //     color: Colors.red,
                //   ),
                //   labelStyle: const TextStyle(
                //     color: Colors.white,
                //     fontSize: 13,
                //     fontWeight: FontWeight.w600,
                //   ),
                //   unselectedLabelColor: Colors.grey,
                //   splashBorderRadius: BorderRadius.circular(20),
                //   padding: EdgeInsets.symmetric(
                //     vertical: 4,
                //   ),
                //   tabs: [
                //     Tab(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Flexible(child: Text('data')),
                //         ],
                //       ),
                //     ),
                //     Tab(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Flexible(child: Text('data')),
                //         ],
                //       ),
                //     ),
                //     Tab(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Flexible(child: Text('data')),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Container(
              //     margin: const EdgeInsets.symmetric(horizontal: 16,),
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       color: Colors.red,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('扫码'),
              //         Text('付款'),
              //         Text('收款'),
              //       ],
              //     )
              //   ),
              // ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xff2963F3),
                ),
                child: const Text(
                  '扫码功能已升级，可扫描任意二维码！',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '只需一个应用即可扫描菜单，入境卡和链接',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '查看所有支持的国家',
                            style: TextStyle(
                              color: Color(0xff2963F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 86,
                      height: 50,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: CircleFlag(
                                  'sg',
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: CircleFlag(
                                  'th',
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: CircleFlag(
                                'cn',
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         ToggleFlashlightButton(controller: controller),
            //         SwitchCameraButton(controller: controller),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 0.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    // canvas.drawRRect(borderRect, borderPaint);

    final paint = Paint()
      ..color = const Color(
        0xff005abe,
      )
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 12.0;

    // 左上角
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + const Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + const Offset(0, cornerLength),
      paint,
    );

    // 右上角
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + const Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + const Offset(0, cornerLength),
      paint,
    );

    // 左下角
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + const Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + const Offset(0, -cornerLength),
      paint,
    );

    // 右下角
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + const Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + const Offset(0, -cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
