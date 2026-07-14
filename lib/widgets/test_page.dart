import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'datasssss ssssss ssssssssssssss ssssssssss sssss  d def fe ssss'),
          ],
        )),
        SizedBox(
          width: 100,
          height: 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 50,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: CircleFlag(
                      'sg',
                      size: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: CircleFlag(
                      'th',
                      size: 30,
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
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
