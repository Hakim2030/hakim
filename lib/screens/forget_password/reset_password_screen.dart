import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String emailOrPhone;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.emailOrPhone,
    required this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  bool passwordResetSuccessfully = false;
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
    passwordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();

    final String password = passwordController.text;

    if (password.isEmpty) {
      setState(() {
        passwordError = 'يرجى إدخال كلمة المرور الجديدة';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        passwordError = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
      });
      return;
    }

    setState(() {
      passwordError = null;
      isLoading = true;
    });

    try {
      await ApiService.instance.resetPassword(
        emailOrPhone: widget.emailOrPhone,
        otpCode: widget.otpCode,
        newPassword: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        passwordResetSuccessfully = true;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(error.message);
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

  void goToLogin() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  OutlineInputBorder passwordBorder(
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

  InputDecoration passwordDecoration() {
    final Color currentBorder =
    passwordError == null ? borderColor : errorColor;

    return InputDecoration(
      hintText: 'أدخل كلمة المرور الجديدة',
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
      ),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: 22,
        color: Color(0xFF999999),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
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
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: passwordBorder(currentBorder),
      enabledBorder: passwordBorder(currentBorder),
      focusedBorder: passwordBorder(
        passwordError == null ? primaryColor : errorColor,
        width: 1.3,
      ),
    );
  }

  Widget buildMainScreen() {
    return LayoutBuilder(
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
                  const _ResetPasswordHeader(),
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
                              'كلمة المرور الجديدة',
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
                                controller: passwordController,
                                obscureText: obscurePassword,
                                keyboardType:
                                TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                onChanged: (_) {
                                  if (passwordError != null) {
                                    setState(() {
                                      passwordError = null;
                                    });
                                  }
                                },
                                onSubmitted: (_) {
                                  resetPassword();
                                },
                                style: const TextStyle(
                                  fontFamily: fontFamily,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                decoration: passwordDecoration(),
                              ),
                            ),
                            if (passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  passwordError!,
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
                                onPressed:
                                isLoading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  disabledBackgroundColor: primaryColor,
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
                                  'إعادة تعيين',
                                  textDirection:
                                  TextDirection.rtl,
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
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
            child: Stack(
              children: [
                buildMainScreen(),
                if (passwordResetSuccessfully)
                  _SuccessOverlay(
                    onLogin: goToLogin,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

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
                    'إعادة تعيين كلمة المرور',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'قم بإدخال كلمة المرور الجديدة',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
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

class _SuccessOverlay extends StatelessWidget {
  final VoidCallback onLogin;

  const _SuccessOverlay({
    required this.onLogin,
  });

  static const Color primaryColor = Color(0xFF0C3468);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.40),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                12,
              ),
              padding: const EdgeInsets.fromLTRB(
                26,
                30,
                26,
                34,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/success_check.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9BE5B3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 58,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تم تعيين كلمة المرور',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton(
                      onPressed: onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
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