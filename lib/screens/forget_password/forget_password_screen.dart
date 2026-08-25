import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import 'verification_code_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFCFCFCF);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String? emailError;

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
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> continueToVerification() async {
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailError = 'يرجى إدخال البريد الإلكتروني';
      });
      return;
    }

    final bool isValidEmail =
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

    if (!isValidEmail) {
      setState(() {
        emailError = 'يرجى إدخال بريد إلكتروني صحيح';
      });
      return;
    }

    setState(() {
      emailError = null;
      isLoading = true;
    });

    try {
      await ApiService.instance.requestOtp(email);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(
            emailOrPhone: email,
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

  OutlineInputBorder emailBorder(
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

  InputDecoration emailDecoration() {
    final Color currentBorder =
    emailError == null ? borderColor : errorColor;

    return InputDecoration(
      hintText: 'example@gmail.com',
      hintTextDirection: TextDirection.ltr,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: const Icon(
        Icons.mail_outline_rounded,
        size: 22,
        color: Color(0xFF999999),
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
      ),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: emailBorder(currentBorder),
      enabledBorder: emailBorder(currentBorder),
      focusedBorder: emailBorder(
        emailError == null ? primaryColor : errorColor,
        width: 1.3,
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
                          const _ForgetPasswordHeader(),
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
                                  28,
                                  20,
                                  30,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'حساب الإيميل',
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: fontFamily,
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 53,
                                      child: TextField(
                                        controller: emailController,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                        textInputAction:
                                        TextInputAction.done,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.right,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        onChanged: (_) {
                                          if (emailError != null) {
                                            setState(() {
                                              emailError = null;
                                            });
                                          }
                                        },
                                        onSubmitted: (_) {
                                          continueToVerification();
                                        },
                                        style: const TextStyle(
                                          fontFamily: fontFamily,
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        decoration: emailDecoration(),
                                      ),
                                    ),
                                    if (emailError != null)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 6),
                                        child: Text(
                                          emailError!,
                                          textDirection: TextDirection.rtl,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: fontFamily,
                                            color: errorColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      height: 53,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : continueToVerification,
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

class _ForgetPasswordHeader extends StatelessWidget {
  const _ForgetPasswordHeader();

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
              right: 20,
              left: 20,
              top: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'نسيت كلمة المرور',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'أدخل حساب الإيميل لإرسال\nكود التحقق',
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