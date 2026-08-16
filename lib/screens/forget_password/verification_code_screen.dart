import 'dart:async';
import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends State<VerificationCodeScreen> {
  static const Color primaryColor = Color(0xFF0C3468);

  final List<TextEditingController> controllers =
  List.generate(5, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(5, (_) => FocusNode());

  Timer? timer;
  int secondsRemaining = 50;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();

    setState(() {
      secondsRemaining = 50;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (secondsRemaining > 0) {
          setState(() {
            secondsRemaining--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  void verifyCode() {
    String code = '';

    for (final controller in controllers) {
      code += controller.text;
    }

    if (code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال رمز التحقق كاملًا',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ResetPasswordScreen(),
      ),
    );
  }

  void resendCode() {
    if (secondsRemaining > 0) {
      return;
    }

    for (final controller in controllers) {
      controller.clear();
    }

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in controllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 205,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 205,
                        color: primaryColor,
                      ),

                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/forget_password_pattern.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Positioned(
                        left: 18,
                        top: 40,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 13,
                        top: 67,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'تم إرسال الكود',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'تحقق من حسابك الإيميل\nأو تطبيق الرسائل',
                              textAlign:
                              TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -1),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      13,
                      25,
                      13,
                      20,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'قم بإدخال الرمز',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          textDirection:
                          TextDirection.ltr,
                          children: List.generate(
                            5,
                                (index) {
                              return SizedBox(
                                width: 42,
                                height: 56,
                                child: TextField(
                                  controller:
                                  controllers[index],
                                  focusNode:
                                  focusNodes[index],
                                  keyboardType:
                                  TextInputType.number,
                                  maxLength: 1,
                                  textAlign:
                                  TextAlign.center,
                                  textDirection:
                                  TextDirection.ltr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty &&
                                        index < 4) {
                                      focusNodes[index + 1]
                                          .requestFocus();
                                    }

                                    if (value.isEmpty &&
                                        index > 0) {
                                      focusNodes[index - 1]
                                          .requestFocus();
                                    }
                                  },
                                  decoration:
                                  InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor:
                                    const Color(
                                      0xFFF8F8F8,
                                    ),
                                    border:
                                    OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(7),
                                      borderSide:
                                      const BorderSide(
                                        color:
                                        Color(
                                          0xFFCFCFCF,
                                        ),
                                      ),
                                    ),
                                    enabledBorder:
                                    OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(7),
                                      borderSide:
                                      const BorderSide(
                                        color:
                                        Color(
                                          0xFFCFCFCF,
                                        ),
                                      ),
                                    ),
                                    focusedBorder:
                                    OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(7),
                                      borderSide:
                                      const BorderSide(
                                        color:
                                        primaryColor,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: resendCode,
                          child: Text(
                            secondsRemaining > 0
                                ? 'سيتم إرسال الكود مرة أخرى خلال ${secondsRemaining.toString().padLeft(2, '0')} ثانية'
                                : 'إعادة إرسال الكود',
                            style: TextStyle(
                              fontSize: 9,
                              color:
                              secondsRemaining > 0
                                  ? Colors.grey
                                  : primaryColor,
                              decoration:
                              secondsRemaining == 0
                                  ? TextDecoration
                                  .underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 43,
                          child: ElevatedButton(
                            onPressed: verifyCode,
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              primaryColor,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'إستمرار',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 170),

                        Center(
                          child: Container(
                            width: 80,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}