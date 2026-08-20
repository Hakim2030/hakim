import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);
  static const Color hintColor = Color(0xFFAAAAAA);

  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool passwordResetSuccessfully = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();

    final String password = passwordController.text.trim();

    if (password.isEmpty) {
      showMessage('يرجى إدخال كلمة المرور الجديدة');
      return;
    }

    if (password.length < 6) {
      showMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() {
      passwordResetSuccessfully = true;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  void closeSuccessDialog() {
    setState(() {
      passwordResetSuccessfully = false;
    });
  }

  void goToLogin() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  InputDecoration passwordDecoration() {
    return InputDecoration(
      hintText: 'أدخل كلمة المرور الجديدة',
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: hintColor,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),

      // القفل على يمين الحقل
      suffixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: 24,
        color: Color(0xFFAAAAAA),
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 55,
        minHeight: 55,
      ),

      // العين على يسار الحقل
      prefixIcon: IconButton(
        onPressed: () {
          setState(() {
            obscurePassword = !obscurePassword;
          });
        },
        icon: Icon(
          obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 27,
          color: const Color(0xFFAAAAAA),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 60,
        minHeight: 55,
      ),

      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 19,
      ),
      border: passwordBorder(borderColor),
      enabledBorder: passwordBorder(borderColor),
      focusedBorder: passwordBorder(
        primaryColor,
        width: 1.4,
      ),
    );
  }

  OutlineInputBorder passwordBorder(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
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
            child: Stack(
              children: [
                _buildMainScreen(),

                if (passwordResetSuccessfully)
                  _SuccessOverlay(
                    onClose: closeSuccessDialog,
                    onLogin: goToLogin,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
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
                          23,
                          38,
                          23,
                          28,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'كلمة المرور',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: Colors.black,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 7),

                            SizedBox(
                              height: 76,
                              child: TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                keyboardType:
                                TextInputType.visiblePassword,
                                textInputAction:
                                TextInputAction.done,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: fontFamily,
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: passwordDecoration(),
                                onSubmitted: (_) {
                                  resetPassword();
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              height: 75,
                              child: ElevatedButton(
                                onPressed: resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'إعادة تعيين',
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // لا نضيف Home Indicator الأسود.
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
}

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

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
                    'إعادة تعيين كلمة المرور',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'قم بإعادة تعيين كلمة المرور',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
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
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const _SuccessOverlay({
    required this.onClose,
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
          child: Stack(
            children: [
              // الضغط خارج النافذة لا يغلقها.
              const Positioned.fill(
                child: SizedBox.expand(),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                    14,
                    0,
                    14,
                    8,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    30,
                    30,
                    45,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(29),
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
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'تم تعيين كلمة المرور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: 295,
                        height: 75,
                        child: ElevatedButton(
                          onPressed: onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(19),
                            ),
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }
}
