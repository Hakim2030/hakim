import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import 'forget_password/forget_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  String? emailError;
  String? passwordError;

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
    passwordController.dispose();
    super.dispose();
  }

  void goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgetPasswordScreen(),
      ),
    );
  }

  void goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  void validateEmailWhileTyping(String value) {
    final String email = value.trim();

    final RegExp gmailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    );

    String? nextError;

    if (email.isNotEmpty &&
        !gmailPattern.hasMatch(email)) {
      nextError =
      'أدخل بريد Gmail صحيحًا مثل name@gmail.com';
    }

    if (emailError != nextError) {
      setState(() {
        emailError = nextError;
      });
    }
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();
    final String password = passwordController.text;

    final RegExp gmailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    );

    String? nextEmailError;
    String? nextPasswordError;

    if (email.isEmpty) {
      nextEmailError =
      'يرجى إدخال البريد الإلكتروني';
    } else if (!gmailPattern.hasMatch(email)) {
      nextEmailError =
      'أدخل بريد Gmail صحيحًا مثل name@gmail.com';
    }

    if (password.isEmpty) {
      nextPasswordError =
      'يرجى إدخال كلمة المرور';
    } else if (password.length < 8) {
      nextPasswordError =
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    setState(() {
      emailError = nextEmailError;
      passwordError = nextPasswordError;
    });

    if (nextEmailError != null ||
        nextPasswordError != null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.instance.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      showMessage('تم تسجيل الدخول بنجاح');
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

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    required bool hasError,
  }) {
    final Color activeBorder = hasError
        ? errorColor
        : const Color(0xFFC4C4C4);

    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.ltr,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: Icon(
        icon,
        size: 22,
        color: const Color(0xFF999999),
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      border: fieldBorder(activeBorder),
      enabledBorder: fieldBorder(activeBorder),
      focusedBorder: fieldBorder(
        hasError ? errorColor : primaryColor,
        width: 1.4,
      ),
    );
  }

  InputDecoration passwordDecoration() {
    final Color activeBorder = passwordError != null
        ? errorColor
        : const Color(0xFFC4C4C4);

    return InputDecoration(
      hintText: 'أدخل كلمة المرور',
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            obscurePassword = !obscurePassword;
          });
        },
        padding: EdgeInsets.zero,
        icon: Icon(
          obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 22,
          color: const Color(0xFF999999),
        ),
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      border: fieldBorder(activeBorder),
      enabledBorder: fieldBorder(activeBorder),
      focusedBorder: fieldBorder(
        passwordError != null
            ? errorColor
            : primaryColor,
        width: 1.4,
      ),
    );
  }

  OutlineInputBorder fieldBorder(
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.sizeOf(context).width;

    final double pageWidth =
    screenWidth > 440 ? 440 : screenWidth;

    final double rawScale = pageWidth / 440;

    final double scale =
    rawScale < 0.92 ? 0.92 : rawScale;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: pageWidth,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _LoginHeader(
                    scale: scale,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        30,
                        20,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          _FieldLabel(
                            text: 'حساب الإيميل',
                            scale: scale,
                          ),
                          const SizedBox(height: 7),
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: TextField(
                              controller: emailController,
                              keyboardType:
                              TextInputType.emailAddress,
                              textInputAction:
                              TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\s'),
                                ),
                              ],
                              textDirection:
                              TextDirection.ltr,
                              textAlign: TextAlign.right,
                              onChanged:
                              validateEmailWhileTyping,
                              style: const TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              decoration: fieldDecoration(
                                hint: 'example@gmail.com',
                                icon:
                                Icons.mail_outline_rounded,
                                hasError: emailError != null,
                              ),
                            ),
                          ),
                          _ErrorText(
                            message: emailError,
                            scale: scale,
                          ),
                          const SizedBox(height: 22),
                          _FieldLabel(
                            text: 'كلمة المرور',
                            scale: scale,
                          ),
                          const SizedBox(height: 7),
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: TextField(
                              controller:
                              passwordController,
                              obscureText: obscurePassword,
                              keyboardType:
                              TextInputType.visiblePassword,
                              textInputAction:
                              TextInputAction.done,
                              textDirection:
                              TextDirection.rtl,
                              textAlign: TextAlign.right,
                              onChanged: (_) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                              },
                              onSubmitted: (_) {
                                login();
                              },
                              style: const TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              decoration:
                              passwordDecoration(),
                            ),
                          ),
                          _ErrorText(
                            message: passwordError,
                            scale: scale,
                          ),
                          Align(
                            alignment:
                            Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                              goToForgotPassword,
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                              ),
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                textDirection:
                                TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w400,
                                  decoration:
                                  TextDecoration.underline,
                                  decorationColor:
                                  primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: ElevatedButton(
                              onPressed:
                              isLoading ? null : login,
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                primaryColor,
                                disabledBackgroundColor:
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
                                    10,
                                  ),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'تسجيل الدخول',
                                textDirection:
                                TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily:
                                  fontFamily,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: goToSignup,
                              child: RichText(
                                textDirection:
                                TextDirection.rtl,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                      'ليس لديك حساب؟ ',
                                      style: TextStyle(
                                        fontFamily:
                                        fontFamily,
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'إنشاء حساب',
                                      style: TextStyle(
                                        fontFamily:
                                        fontFamily,
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w500,
                                        decoration:
                                        TextDecoration
                                            .underline,
                                        decorationColor:
                                        primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // أيقونتا Google وApple بالحجم نفسه.
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                imagePath:
                                'assets/images/google_icon.png',
                                onTap: () {
                                  showMessage(
                                    'تسجيل Google غير مربوط بعد',
                                  );
                                },
                              ),
                              const SizedBox(width: 32),
                              _SocialButton(
                                imagePath:
                                'assets/images/apple_icon.png',
                                onTap: () {
                                  showMessage(
                                    'تسجيل Apple غير مربوط بعد',
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final double scale;

  const _LoginHeader({
    required this.scale,
  });

  static const Color primaryColor =
  Color(0xFF0C3468);

  static const String fontFamily =
      'ThmanyahSerifDisplay';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 245 * scale,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: ColoredBox(
              color: primaryColor,
            ),
          ),
          Positioned(
            left: -20 * scale,
            bottom: -15 * scale,
            child: Image.asset(
              'assets/images/login_pattern.png',
              width: 210 * scale,
              height: 210 * scale,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) {
                return const SizedBox.shrink();
              },
            ),
          ),
          Positioned(
            top: 70 * scale,
            right: 24 * scale,
            left: 24 * scale,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                Text(
                  'مرحباً بك في حكيم',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                SizedBox(
                  height: 8 * scale,
                ),
                Text(
                  'قم بتسجيل الدخول',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final double scale;

  const _FieldLabel({
    required this.text,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'ThmanyahSerifDisplay',
        fontSize: 19 * scale,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1.2,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String? message;
  final double scale;

  const _ErrorText({
    required this.message,
    required this.scale,
  });

  // تعريف اللون داخل الكلاس لمنع خطأ errorColor.
  static const Color errorColor =
  Color(0xFFD93025);

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 5 * scale,
      ),
      child: Text(
        message!,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily:
          'ThmanyahSerifDisplay',
          color: errorColor,
          fontSize: 12 * scale,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _SocialButton({
    required this.imagePath,
    required this.onTap,
  });

  // الحجم نفسه لكلا الأيقونتين.
  static const double buttonSize = 52;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.square(
        dimension: buttonSize,
        child: Image.asset(
          imagePath,
          width: buttonSize,
          height: buttonSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}