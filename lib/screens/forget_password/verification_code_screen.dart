import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import 'reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String emailOrPhone;

  const VerificationCodeScreen({
    super.key,
    required this.emailOrPhone,
  });

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
  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    startTimer();
  }

  void startTimer() {
    timer?.cancel();

    setState(() {
      secondsRemaining = 50;
    });

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

  Future<void> verifyCode() async {
    FocusScope.of(context).unfocus();

    if (enteredCode.length != 5) {
      showMessage('يرجى إدخال رمز التحقق كاملًا');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.instance.verifyOtp(
        emailOrPhone: widget.emailOrPhone,
        otpCode: enteredCode,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            emailOrPhone: widget.emailOrPhone,
            otpCode: enteredCode,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendCode() async {
    if (secondsRemaining > 0 || isResending) return;

    setState(() {
      isResending = true;
    });

    try {
      await ApiService.instance.requestOtp(
        widget.emailOrPhone,
      );

      if (!mounted) return;

      for (final controller in controllers) {
        controller.clear();
      }

      focusNodes.first.requestFocus();
      startTimer();

      showMessage('تم إرسال رمز تحقق جديد');
    } on ApiException catch (error) {
      if (!mounted) return;
      showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
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

  OutlineInputBorder codeBorder(
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

  Widget buildCodeFields() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(
          controllers.length,
              (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == controllers.length - 1 ? 0 : 8,
                ),
                child: SizedBox(
                  height: 58,
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
                      fontSize: 23,
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
                      border: codeBorder(borderColor),
                      enabledBorder: codeBorder(borderColor),
                      focusedBorder: codeBorder(
                        primaryColor,
                        width: 1.3,
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

  Widget buildTimer() {
    if (secondsRemaining == 0) {
      return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: isResending ? null : resendCode,
          child: Text(
            isResending
                ? 'جارٍ إرسال الكود...'
                : 'إعادة إرسال الكود',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: fontFamily,
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: primaryColor,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'يمكنك إعادة إرسال الكود بعد',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formattedTime,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: fontFamily,
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double pageWidth = screenWidth > 440 ? 440 : screenWidth;

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
                              offset: const Offset(0, -20),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(22),
                                    topRight: Radius.circular(22),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  30,
                                  20,
                                  30,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'قم بإدخال رمز التحقق',
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: fontFamily,
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    buildCodeFields(),
                                    const SizedBox(height: 18),
                                    buildTimer(),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      height: 53,
                                      child: ElevatedButton(
                                        onPressed:
                                        isLoading ? null : verifyCode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          disabledBackgroundColor:
                                          primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                          width: 21,
                                          height: 21,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : const Text(
                                          'استمرار',
                                          textDirection:
                                          TextDirection.rtl,
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
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
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader();

  static const Color primaryColor = Color(0xFF0C3468);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 245,
      color: primaryColor,
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -4,
              bottom: 0,
              child: Image.asset(
                'assets/images/forget_password_pattern.png',
                width: 190,
                height: 190,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  return const SizedBox.shrink();
                },
              ),
            ),
            Positioned(
              left: 16,
              top: 17,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 70,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تم إرسال الكود',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'تحقق من حساب الإيميل\nللحصول على رمز التحقق',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      height: 1.28,
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