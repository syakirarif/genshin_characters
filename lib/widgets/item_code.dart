import 'package:flutter/material.dart';

class ItemCode extends StatefulWidget {
  const ItemCode({Key? key, required this.onClickItem}) : super(key: key);

  final Function({required String email}) onClickItem;

  @override
  State<ItemCode> createState() => _ItemCodeState();
}

class _ItemCodeState extends State<ItemCode> {
  bool isMyFav = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onClickItem(email: '');
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    // Container(
                    //     width: 60,
                    //     height: 60,
                    //     child: ClipRRect(
                    //       borderRadius: BorderRadius.circular(20),
                    //       child: Image.asset('companyLogo'),
                    //     )
                    // ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('title',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(
                              height: 5,
                            ),
                            Text('address',
                                style: TextStyle(color: Colors.grey[500])),
                          ]),
                    )
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    // setState(() {
                    //   // job.isMyFav = !job.isMyFav;
                    // });
                    debugPrint('clicked');
                  },
                  child: AnimatedContainer(
                      height: 35,
                      padding: EdgeInsets.all(5),
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMyFav
                                ? Colors.red.shade100
                                : Colors.grey.shade300,
                          )),
                      child: Center(
                          child: isMyFav
                              ? Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_outline,
                                  color: Colors.grey.shade600,
                                ))),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200),
                        child: Text(
                          'type',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      // SizedBox(width: 10,),
                      // Container(
                      //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(12),
                      //       color: Color(int.parse("0xff000000")).withAlpha(20)
                      //   ),
                      //   child: Text('experienceLevel', style: TextStyle(color: Color(int.parse("0xff000000"))),),
                      // )
                    ],
                  ),
                  Text(
                    'timeAgo',
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
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
