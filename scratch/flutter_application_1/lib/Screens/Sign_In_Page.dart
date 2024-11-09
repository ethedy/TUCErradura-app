import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'LOGIN',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SvgPicture.asset(
            "assets/images/Background.svg",
            height: size.height * 0.35,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0),
              borderRadius: BorderRadius.circular(29),
            ),
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Color.fromRGBO(255, 255, 255, 0),
                ),
                hintText: "Your Email",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
