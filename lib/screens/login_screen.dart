import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'forget_password/forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryColor = Color(0xFF0C3468);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

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

  void validateLogin() {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      showMessage('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    showMessage('البيانات صحيحة، وسيتم ربط تسجيل الدخول بالخادم لاحقًا');
  }

  void showUnavailableFeature() {
    showMessage('هذه الخاصية ستتوفر في المرحلة القادمة');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'ThmanyahSerifDisplay'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // Figma design: 440 x 956
            final double scale =
            (screenWidth / 440).clamp(0.72, 1.0);

            final double contentWidth = 440 * scale;

            return Center(
              child: SizedBox(
                width: contentWidth,
                height: screenHeight,
                child: _LoginContent(
                  scale: scale,
                  emailController: emailController,
                  passwordController: passwordController,
                  obscurePassword: obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  onForgotPassword: goToForgotPassword,
                  onLogin: validateLogin,
                  onUnavailableFeature: showUnavailableFeature,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  final double scale;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;

  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onUnavailableFeature;

  const _LoginContent({
    required this.scale,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onUnavailableFeature,
  });

  static const Color primaryColor = Color(0xFF0C3468);

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // =========================================================
          // BLUE HEADER
          // =========================================================

          SizedBox(
            width: double.infinity,
            height: s(190),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: s(190),
                  color: primaryColor,
                ),

                // Background pattern
                Positioned(
                  left: s(-20),
                  bottom: s(-15),
                  child: Opacity(
                    opacity: 0.16,
                    child: Image.asset(
                      'assets/images/login_pattern.png',
                      width: s(210),
                      height: s(210),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Welcome text
                Positioned(
                  top: s(40),
                  right: s(18),
                  left: s(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'مرحباً بك في حكيم',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'ThmanyahSerifDisplay',
                          fontSize: s(25),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),

                      SizedBox(height: s(8)),

                      Text(
                        'قم بتسجيل الدخول',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'ThmanyahSerifDisplay',
                          fontSize: s(17),
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
          ),

          // =========================================================
          // WHITE CONTENT
          // =========================================================

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(s(20)),
                  topRight: Radius.circular(s(20)),
                ),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  s(14),
                  s(24),
                  s(14),
                  s(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =================================================
                    // EMAIL LABEL
                    // =================================================

                    Text(
                      'حساب الإيميل',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'ThmanyahSerifDisplay',
                        fontSize: s(12),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: s(5)),

                    // =================================================
                    // EMAIL FIELD
                    // =================================================

                    SizedBox(
                      height: s(45),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'ThmanyahSerifDisplay',
                          fontSize: s(11),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'example@gmail.com',
                          hintStyle: TextStyle(
                            fontFamily: 'ThmanyahSerifDisplay',
                            fontSize: s(10),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFAAAAAA),
                          ),

                          // Email icon
                          suffixIcon: Icon(
                            Icons.mail_outline,
                            size: s(18),
                            color: const Color(0xFF999999),
                          ),

                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: s(10),
                            vertical: s(10),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: s(15)),

                    // =================================================
                    // PASSWORD LABEL
                    // =================================================

                    Text(
                      'كلمة المرور',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'ThmanyahSerifDisplay',
                        fontSize: s(12),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: s(5)),

                    // =================================================
                    // PASSWORD FIELD
                    // =================================================

                    SizedBox(
                      height: s(45),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'ThmanyahSerifDisplay',
                          fontSize: s(11),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل كلمة المرور',
                          hintStyle: TextStyle(
                            fontFamily: 'ThmanyahSerifDisplay',
                            fontSize: s(10),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFAAAAAA),
                          ),

                          // Eye icon
                          suffixIcon: IconButton(
                            onPressed: onTogglePassword,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: s(18),
                              color: const Color(0xFF999999),
                            ),
                          ),

                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: s(10),
                            vertical: s(10),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                              width: 1,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // FORGOT PASSWORD
                    // =================================================

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onForgotPassword,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: s(4),
                            bottom: s(3),
                          ),
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontFamily: 'ThmanyahSerifDisplay',
                              color: primaryColor,
                              fontSize: s(10),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: s(1)),

                    // =================================================
                    // LOGIN BUTTON
                    // =================================================

                    SizedBox(
                      height: s(41),
                      child: ElevatedButton(
                        onPressed: onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(8)),
                          ),
                        ),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontFamily: 'ThmanyahSerifDisplay',
                            fontSize: s(14),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // CREATE ACCOUNT
                    // =================================================

                    SizedBox(height: s(15)),

                    Center(
                      child: GestureDetector(
                        onTap: onUnavailableFeature,
                        child: RichText(
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ليس لديك حساب؟ ',
                                style: TextStyle(
                                  fontFamily: 'ThmanyahSerifDisplay',
                                  color: Colors.black,
                                  fontSize: s(10),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'إنشاء حساب',
                                style: TextStyle(
                                  fontFamily: 'ThmanyahSerifDisplay',
                                  color: primaryColor,
                                  fontSize: s(10),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // GOOGLE + APPLE
                    // =================================================

                    SizedBox(height: s(16)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google - RIGHT
                        _SocialButton(
                          imagePath: 'assets/images/google_icon.png',
                          size: s(39),
                          onTap: onUnavailableFeature,
                        ),

                        SizedBox(width: s(30)),

                        // Apple - LEFT
                        _SocialButton(
                          imagePath: 'assets/images/apple_icon.png',
                          size: s(39),
                          onTap: onUnavailableFeature,
                        ),
                      ],
                    ),

                    // No bottom black line.
                    SizedBox(height: s(10)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String imagePath;
  final double size;
  final VoidCallback onTap;

  const _SocialButton({
    required this.imagePath,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

