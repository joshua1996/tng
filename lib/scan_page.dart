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

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  String scannedCode = '';

  @override
  Future<void> dispose() async {
    super.dispose();
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
        MediaQuery.of(context).size.height / 2.5,
      ),
      width: MediaQuery.of(context).size.width - 96,
      height: MediaQuery.of(context).size.width - 96,
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
      body: Stack(
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
                scannedCode = barcodes.barcodes.firstOrNull?.displayValue ?? '';
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
            // overlayBuilder: (context, constraints) {
            //   return Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Align(
            //       alignment: Alignment.bottomCenter,
            //       child: ScannedBarcodeLabel(barcodes: controller.barcodes),
            //     ),
            //   );
            // },
          ),
          // Container(
          //   height: double.infinity,
          //   width: double.infinity,
          //   child: Text('data'),
          // ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2.5 - 160,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: const Text(
              '扫条码或二维码',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2.5 + 150,
            left: MediaQuery.of(context).size.width / 2 - 66,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff0064ff),
              ),
              onPressed: () {},
              child: const Text('从图片库扫码'),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2.5 + 150,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
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
      ..color = Colors.black.withOpacity(0.5)
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
