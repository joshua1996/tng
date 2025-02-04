import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/merchant_page.dart';
import 'package:tng/models/shortcut.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tng/payment_page.dart';
import 'package:tng/scan_page.dart';
import 'package:tng/transaction_history_page.dart';
import 'package:tng/transfer_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'sme') {
        goToPaymentPage();
      } else if (shortcutType == 'p2p') {
        goToTransferPage();
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'sme',
        localizedTitle: 'SME',
        localizedSubtitle: 'Action one subtitle',
        icon: 'AppIcon',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'p2p',
        localizedTitle: 'P2P',
        icon: 'ic_launcher',
      ),
    ]);
  }

  List<ShortcutButton> shortcutButtons = [
    ShortcutButton(
      title: '收费站',
      image: 'toll',
    ),
    ShortcutButton(
      title: '停车费',
      image: 'parking',
    ),
    ShortcutButton(
      title: 'GOpinjam',
      image: 'go_pinjam',
    ),
    ShortcutButton(
      title: 'GOprotect',
      image: 'go_protect',
    ),
    ShortcutButton(
      title: '手机预付',
      image: 'topup',
    ),
    ShortcutButton(
      title: '账单缴费',
      image: 'bill',
    ),
    ShortcutButton(
      title: 'GOinvest',
      image: 'go_invest',
    ),
    ShortcutButton(
      title: 'ASNB',
      image: 'asnb',
    ),
    ShortcutButton(
      title: 'CTOS Report',
      image: 'ctos',
    ),
    ShortcutButton(
      title: 'A+ Rewards',
      image: 'a_plus_reward',
    ),
    ShortcutButton(
      title: '商家',
      image: 'merchant',
    ),
    ShortcutButton(
      title: '其他',
      image: 'more',
    ),
  ];

  void showBalance() {
    showModalBottomSheet<void>(
      context: context,
      // showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 364,
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xffe8e8e8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '可用余额',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'RM 29,559.06',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      'assets/images/wallet_safe_white.jpg',
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/go_plus.jpg',
                      height: 24,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    const Text(
                      'GO+ 余额',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(
                      width: 24 + 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'RM 9559.06',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'RM 0.88',
                          style: TextStyle(
                            color: Color(0xff69b475),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xff005abe),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                const Divider(
                  thickness: 0.5,
                  color: Color(
                    0xffb6b6b6,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ewallet.jpg',
                      height: 24,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    const Text(
                      '电子钱包余额',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(
                      width: 24 + 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'RM 20,000.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xff005abe),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xffe3f6fe),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(text: '您可用转账至 '),
                            TextSpan(
                              text: 'RM 29,559.06',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xff2463f3),
                        size: 26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '当电子钱包余额不足时，GO+余额可被用来支付所有交易。',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const TextSpan(
                        text: '了解更多',
                        style: TextStyle(
                          color: Color(0xff436de9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> goToPaymentPage() async {
    final merchants = await supabase
        .from('merchants')
        .select()
        .eq('name', 'default sme')
        .limit(1);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          merchant: merchants.isEmpty ? {} : merchants[0],
        ),
      ),
    );
  }

  Future<void> goToTransferPage() async {
    final merchants = await supabase
        .from('merchants')
        .select()
        .eq('name', 'default p2p')
        .limit(1);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransferPage(
          merchant: merchants.isEmpty ? {} : merchants[0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff0064ff),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ),
                    Text(
                      '首页',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xff6d6d6d),
                    ),
                    Text(
                      'eShop',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/gold.png',
                      height: 24,
                    ),
                    const Text(
                      'GOfinance',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.redeem_outlined,
                      color: Color(0xff6d6d6d),
                    ),
                    Text(
                      'GOrewards',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xff6d6d6d),
                    ),
                    Text(
                      'Near Me',
                      style: TextStyle(
                        color: Color(0xff6d6d6d),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).viewPadding.top,
              color: const Color(
                0xff005abe,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: const Color(
                0xff005abe,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image(
                            image:
                                const AssetImage('assets/images/country_select.png'),
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              goToPaymentPage();
                            },
                            onLongPress: () {
                              goToTransferPage();
                            },
                            child: badges.Badge(
                              position: badges.BadgePosition.custom(
                                top: 0,
                                end: 0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xffcdeffc),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Icon(
                                  Icons.person_outlined,
                                  color: Color(0xff2a62f6),
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          showBalance();
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/walletsafe.jpg',
                              width: 20,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            const Text(
                              'RM 559.06',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MerchantPage(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        '查看余额详情',
                        style: TextStyle(
                          color: Color(0xff98b7ee),
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xff98b7ee),
                        size: 17,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            '+ 充值',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionHistoryPage(),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              '交易记录',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: 17,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Color(0xff005abe),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      )),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Card(
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MainButton(
                          image: 'scan',
                          title: '扫码',
                        ),
                        MainButton(
                          image: 'pay',
                          title: '付款',
                        ),
                        MainButton(
                          image: 'transfer',
                          title: '转账',
                        ),
                        MainButton(
                          image: 'tng',
                          title: 'TNG 卡',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 56,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: SizedBox(
                height: 66,
                child: Row(
                  children: [
                    SecondButton(
                      image: 'go_plus',
                      title: 'GO+',
                      subtitle: '日收益 >3.45%*',
                      badge: '',
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    SecondButton(
                      image: 'go_reward',
                      title: 'GO rewards',
                      subtitle: '',
                      badge: '1 个奖励',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Image.asset('assets/images/banner.jpg'),
            ),
            GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1 / .9,
              children: List.generate(shortcutButtons.length, (index) {
                ShortcutButton shortcutButton = shortcutButtons[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Image.asset(
                      'assets/images/${shortcutButton.image}.jpg',
                      width: 32,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      shortcutButton.title,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xfff0ce46),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '特选',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/images/banner.jpg'),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 16,
                        );
                      },
                      itemCount: 10,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String image;
  final String title;
  const MainButton({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ScanPage(),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Image.asset(
            'assets/images/$image.jpg',
            width: 34,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}

class SecondButton extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String badge;
  const SecondButton({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(
          left: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffedf1fd),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$image.jpg',
              width: 30,
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  badge == ''
                      ? Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
