import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);

  static const String fontFamily = 'ThmanyahSerifDisplay';

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
    secondsRemaining = 50;

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (currentTimer) {
        if (!mounted) {
          currentTimer.cancel();
          return;
        }

        if (secondsRemaining > 0) {
          setState(() {
            secondsRemaining--;
          });
        } else {
          currentTimer.cancel();
        }
      },
    );
  }

  String get enteredCode {
    return controllers
        .map((controller) => controller.text)
        .join();
  }

  String get formattedTime {
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void verifyCode() {
    FocusScope.of(context).unfocus();

    if (enteredCode.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'يرجى إدخال رمز التحقق كاملًا',
              style: TextStyle(
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResetPasswordScreen(),
      ),
    );
  }

  void resendCode() {
    if (secondsRemaining > 0) return;

    for (final controller in controllers) {
      controller.clear();
    }

    focusNodes.first.requestFocus();

    setState(() {
      secondsRemaining = 50;
    });

    startTimer();
  }

  void handleCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < controllers.length - 1) {
      focusNodes[index + 1].requestFocus();
      return;
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in controllers) {
      controller.dispose();
    }

    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double pageWidth =
    screenWidth > 440 ? 440 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SizedBox(
            width: pageWidth,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const _VerificationHeader(),

                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(0, -28),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  13,
                                  47,
                                  13,
                                  28,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'قم بإدخال الرمز',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: fontFamily,
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    _buildCodeFields(),

                                    const SizedBox(height: 39),

                                    _buildTimer(),

                                    const SizedBox(height: 37),

                                    SizedBox(
                                      height: 75,
                                      child: ElevatedButton(
                                        onPressed: verifyCode,
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          primaryColor,
                                          foregroundColor:
                                          Colors.white,
                                          elevation: 0,
                                          shadowColor:
                                          Colors.transparent,
                                          padding: EdgeInsets.zero,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'استمرار',
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /*
                                      لا نضيف الخط الأسود السفلي؛
                                      فهو تابع للجهاز وليس للتطبيق.
                                    */
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeFields() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(
          controllers.length,
              (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right:
                  index == controllers.length - 1 ? 0 : 8,
                ),
                child: SizedBox(
                  height: 100,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    autofocus: index == 0,
                    keyboardType: TextInputType.number,
                    textInputAction: index == 4
                        ? TextInputAction.done
                        : TextInputAction.next,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) {
                      handleCodeChanged(value, index);
                    },
                    onSubmitted: (_) {
                      if (index == controllers.length - 1) {
                        verifyCode();
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: fieldColor,
                      contentPadding: EdgeInsets.zero,
                      border: _codeBorder(borderColor),
                      enabledBorder: _codeBorder(borderColor),
                      focusedBorder: _codeBorder(
                        primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimer() {
    if (secondsRemaining == 0) {
      return GestureDetector(
        onTap: resendCode,
        child: const Text(
          'إعادة إرسال الكود',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFamily,
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: primaryColor,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'يمكنك إعادة إرسال الكود بعد ',
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            formattedTime,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: fontFamily,
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _codeBorder(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader();

  static const Color primaryColor = Color(0xFF0C3468);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 330,
      color: primaryColor,
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -5,
              bottom: -12,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/forget_password_pattern.png',
                  width: 230,
                  height: 230,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            Positioned(
              left: 18,
              top: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),

            const Positioned(
              top: 82,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'تم إرسال الكود',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'تحقق من حسابك الإيميل\nأو تطبيق الرسائل',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}