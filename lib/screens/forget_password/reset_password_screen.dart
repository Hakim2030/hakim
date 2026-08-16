import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // لمعرفة هل تظهر نافذة النجاح أم لا
  bool passwordResetSuccessfully = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void resetPassword() {
    if (passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال كلمة المرور',
          ),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          ),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمتا المرور غير متطابقتين',
          ),
        ),
      );
      return;
    }

    // إخفاء الكيبورد
    FocusScope.of(context).unfocus();

    // إظهار رسالة النجاح فوق نفس الشاشة
    setState(() {
      passwordResetSuccessfully = true;
    });
  }

  void goToLogin() {
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 10,
      ),
      suffixIcon: IconButton(
        onPressed: onPressed,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: const Color(0xFF999999),
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCFCFCF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCFCFCF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
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

          child: Stack(
            children: [

              // =====================================================
              // الشاشة الأصلية لإعادة تعيين كلمة المرور
              // =====================================================

              SingleChildScrollView(
                child: Column(
                  children: [

                    // ==============================
                    // Header
                    // ==============================

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

                          // Back button
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

                          // Header text
                          Positioned(
                            right: 13,
                            top: 67,

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,

                              children: const [

                                Text(
                                  'إعادة تعيين كلمة المرور',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'قم بإعادة تعيين كلمة المرور',

                                  textAlign: TextAlign.right,

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==============================
                    // White Content
                    // ==============================

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
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                          children: [

                            // ==========================
                            // New Password
                            // ==========================

                            const Text(
                              'كلمة المرور الجديدة',

                              textAlign: TextAlign.right,

                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            TextField(
                              controller: passwordController,

                              obscureText:
                              obscurePassword,

                              textAlign: TextAlign.right,

                              decoration:
                              inputDecoration(
                                hint:
                                'أدخل كلمة المرور الجديدة',

                                obscure:
                                obscurePassword,

                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ==========================
                            // Confirm Password
                            // ==========================

                            const Text(
                              'تأكيد كلمة المرور',

                              textAlign: TextAlign.right,

                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            TextField(
                              controller:
                              confirmPasswordController,

                              obscureText:
                              obscureConfirmPassword,

                              textAlign: TextAlign.right,

                              decoration:
                              inputDecoration(
                                hint:
                                'أعد إدخال كلمة المرور',

                                obscure:
                                obscureConfirmPassword,

                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ==========================
                            // Reset Button
                            // ==========================

                            SizedBox(
                              width: double.infinity,
                              height: 43,

                              child: ElevatedButton(
                                onPressed:
                                resetPassword,

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
                                  'إعادة تعيين',

                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 190),

                            // ==========================
                            // Bottom indicator
                            // ==========================

                            Center(
                              child: Container(
                                width: 80,
                                height: 4,

                                decoration:
                                BoxDecoration(
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

              // =====================================================
              // SUCCESS OVERLAY
              // =====================================================

              if (passwordResetSuccessfully)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.45),

                    child: Center(
                      child: Container(
                        width: 285,

                        padding:
                        const EdgeInsets.fromLTRB(
                          25,
                          22,
                          25,
                          25,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(18),

                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.20),

                              blurRadius: 20,

                              offset:
                              const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [

                            // ==========================
                            // Green Check
                            // ==========================

                            Container(
                              width: 64,
                              height: 64,

                              decoration:
                              const BoxDecoration(
                                color: Color(0xFF91E3AD),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ==========================
                            // Success Text
                            // ==========================

                            const Text(
                              'تم تعيين كلمة المرور',

                              textAlign:
                              TextAlign.center,

                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ==========================
                            // Login Button
                            // ==========================

                            SizedBox(
                              width: 170,
                              height: 43,

                              child: ElevatedButton(
                                onPressed:
                                goToLogin,

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
                                  'تسجيل الدخول',

                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}