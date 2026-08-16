import 'package:flutter/material.dart';
import 'forget_password/forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryColor = Color(0xFF0C3468);

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الدخول بنجاح'),
      ),
    );
  }

  void forgetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ForgetPasswordScreen(),
      ),
    );
  }

  void createAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح شاشة إنشاء الحساب'),
      ),
    );
  }

  void loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Login'),
      ),
    );
  }

  void loginWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Login'),
      ),
    );
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
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 330,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 330,
                        color: primaryColor,
                      ),

                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/login_pattern.png',
                          width: 155,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Positioned(
                        right: 13,
                        top: 61,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'مرحباً بك في حكيم',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'قم بتسجيل الدخول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'حساب الإيميل',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller: emailController,
                            keyboardType:
                            TextInputType.emailAddress,
                            textDirection:
                            TextDirection.ltr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 10,
                              ),
                              suffixIcon: const Icon(
                                Icons.mail_outline,
                                size: 18,
                                color: Color(0xFF999999),
                              ),
                              filled: true,
                              fillColor:
                              const Color(0xFFF8F8F8),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFCFCFCF),
                                ),
                              ),
                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFCFCFCF),
                                ),
                              ),
                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: primaryColor,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'يرجى إدخال البريد الإلكتروني';
                              }

                              if (!value.contains('@')) {
                                return 'يرجى إدخال بريد إلكتروني صحيح';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'كلمة المرور',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة المرور',
                              hintStyle: const TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 10,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                      .visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color:
                                  const Color(0xFF999999),
                                ),
                              ),
                              filled: true,
                              fillColor:
                              const Color(0xFFF8F8F8),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFCFCFCF),
                                ),
                              ),
                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFCFCFCF),
                                ),
                              ),
                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                                borderSide:
                                const BorderSide(
                                  color: primaryColor,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }

                              if (value.length < 6) {
                                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                              }

                              return null;
                            },
                          ),

                          Align(
                            alignment:
                            Alignment.centerRight,
                            child: TextButton(
                              onPressed: forgetPassword,
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.only(
                                  top: 2,
                                  bottom: 2,
                                ),
                              ),
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 10,
                                  decoration:
                                  TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 41,
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
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟ ',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              GestureDetector(
                                onTap: createAccount,
                                child: const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    color: Color(0xFF0C3468),
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight.bold,
                                    decoration:
                                    TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: loginWithApple,
                                child: Image.asset(
                                  'assets/images/apple_icon.png',
                                  width: 39,
                                  height: 39,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 30),
                              GestureDetector(
                                onTap: loginWithGoogle,
                                child: Image.asset(
                                  'assets/images/google_icon.png',
                                  width: 39,
                                  height: 39,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}