import 'package:flutter/material.dart';
import 'package:genshin_characters/model/code_model.dart';
import 'package:genshin_characters/utils/functions.dart';

class ItemCode extends StatefulWidget {
  const ItemCode(
      {required this.dataModel, required this.isNotClaimed, Key? key})
      : super(key: key);

  final CodeModel dataModel;
  final bool isNotClaimed;

  @override
  State<ItemCode> createState() => _ItemCodeState();
}

class _ItemCodeState extends State<ItemCode> {
  bool isNewCode = false;

  @override
  Widget build(BuildContext context) {
    bool isNotClaimed = widget.isNotClaimed;

    String? expDate = widget.dataModel.expirationDate;

    if (expDate != null) {
      if (expDate != 'TBD' && expDate != 'Unknown' && expDate != 'Permanent') {
        DateTime temp = DateTime.parse(expDate);
        expDate = formatDateTime(temp.toLocal());
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isNotClaimed ? Colors.white : Colors.grey.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.dataModel.code}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text('${widget.dataModel.codeDetail}',
                              style: TextStyle(color: Colors.grey[500])),
                        ]),
                  )
                ]),
              ),
              GestureDetector(
                onTap: () {
                  debugPrint('clicked');
                },
                child: AnimatedContainer(
                    height: 35,
                    padding: const EdgeInsets.all(5),
                    duration: const Duration(milliseconds: 300),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: isNewCode
                    //           ? Colors.red.shade100
                    //           : Colors.grey.shade300,
                    //     )),
                    child: Center(
                        child: isNewCode
                            ? Icon(
                          Icons.fiber_new,
                          color: Colors.red.shade700,
                        )
                            : null)),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200),
                      child: Text(
                        '${widget.dataModel.codeSource}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$expDate',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
