import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'citizen_details_screen.dart';
import 'pharmacist_details_screen.dart';

enum AccountType { citizen, pharmacist }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool obscurePassword = true;
  bool agreedToTerms = false;
  bool isLoading = false;
  AccountType? selectedAccountType;

  String? emailError;
  String? passwordError;
  String? phoneError;
  String? accountTypeError;
  String? termsError;

  void onEmailChanged(String value) {
    setState(() {
      if (emailError != null) emailError = null;
    });
  }

  void onPasswordChanged(String value) {
    setState(() {
      if (passwordError != null) passwordError = null;
    });
  }

  void onPhoneChanged(String value) {
    setState(() {
      if (phoneError != null) phoneError = null;
    });
  }

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
    phoneController.dispose();
    super.dispose();
  }

  void goToLogin() {
    Navigator.pop(context);
  }

  void selectAccountType(AccountType type) {
    setState(() {
      selectedAccountType = type;
      accountTypeError = null;
    });
  }

  void toggleTerms([bool? value]) {
    setState(() {
      agreedToTerms = value ?? !agreedToTerms;
      if (agreedToTerms) termsError = null;
    });
  }

  Future<void> continueSignup() async {
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String phone = phoneController.text.trim();
    final RegExp gmailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    );

    String? nextEmailError;
    String? nextPasswordError;
    String? nextPhoneError;

    if (email.isEmpty) {
      nextEmailError = 'يرجى إدخال البريد الإلكتروني';
    } else if (!gmailPattern.hasMatch(email)) {
      nextEmailError = 'أدخل بريد Gmail صحيحًا مثل name@gmail.com';
    }

    if (password.isEmpty) {
      nextPasswordError = 'يرجى إدخال كلمة المرور';
    } else if (password.length < 8) {
      nextPasswordError = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (phone.isEmpty) {
      nextPhoneError = 'يرجى إدخال رقم الهاتف';
    } else if (phone.length < 7) {
      nextPhoneError = 'يرجى إدخال رقم هاتف صحيح';
    }

    setState(() {
      emailError = nextEmailError;
      passwordError = nextPasswordError;
      phoneError = nextPhoneError;
      accountTypeError = selectedAccountType == null
          ? 'يرجى اختيار نوع الحساب'
          : null;
      termsError = agreedToTerms
          ? null
          : 'يجب الموافقة على الشروط والأحكام للمتابعة';
    });

    if (nextEmailError != null ||
        nextPasswordError != null ||
        nextPhoneError != null ||
        selectedAccountType == null ||
        !agreedToTerms) {
      return;
    }

    setState(() => isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => isLoading = false);

    if (selectedAccountType == AccountType.citizen) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CitizenDetailsScreen(
            email: email,
            password: password,
            phone: '+970$phone',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PharmacistDetailsScreen(
          email: email,
          password: password,
          phone: '+970$phone',
        ),
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
                          const _SignupHeader(),
                          Transform.translate(
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
                                18,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  const _FieldLabel(text: 'حساب الإيميل'),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 53,
                                    child: TextField(
                                      controller: emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.right,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      onChanged: onEmailChanged,
                                      style: const TextStyle(
                                        fontFamily: fontFamily,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      decoration: _textFieldDecoration(
                                        hint: 'example@gmail.com',
                                        icon: Icons.mail_outline_rounded,
                                        hasError: emailError != null,
                                        hintDirection: TextDirection.ltr,
                                      ),
                                    ),
                                  ),
                                  _ErrorText(message: emailError),
                                  const SizedBox(height: 14),
                                  const _FieldLabel(text: 'كلمة المرور'),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 53,
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.next,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      onChanged: onPasswordChanged,
                                      style: const TextStyle(
                                        fontFamily: fontFamily,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      decoration: _passwordDecoration(),
                                    ),
                                  ),
                                  _ErrorText(message: passwordError),
                                  const SizedBox(height: 14),
                                  const _FieldLabel(text: 'رقم الهاتف'),
                                  const SizedBox(height: 6),
                                  _PhoneField(
                                    controller: phoneController,
                                    hasError: phoneError != null,
                                    onChanged: onPhoneChanged,
                                  ),
                                  _ErrorText(message: phoneError),
                                  const SizedBox(height: 22),
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Expanded(
                                        child: _AccountTypeButton(
                                          label: 'مواطن',
                                          icon: Icons.person_rounded,
                                          selected: selectedAccountType ==
                                              AccountType.citizen,
                                          onTap: () => selectAccountType(
                                            AccountType.citizen,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _AccountTypeButton(
                                          label: 'صيدلي',
                                          icon: Icons.local_pharmacy_rounded,
                                          selected: selectedAccountType ==
                                              AccountType.pharmacist,
                                          onTap: () => selectAccountType(
                                            AccountType.pharmacist,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  _ErrorText(message: accountTypeError),
                                  const SizedBox(height: 16),
                                  InkWell(
                                    onTap: toggleTerms,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Checkbox(
                                              value: agreedToTerms,
                                              onChanged: toggleTerms,
                                              activeColor:
                                                  const Color(0xFF98E2AE),
                                              checkColor: Colors.white,
                                              side: BorderSide(
                                                color: termsError == null
                                                    ? const Color(0xFFBDBDBD)
                                                    : errorColor,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              textDirection:
                                                  TextDirection.rtl,
                                              textAlign: TextAlign.right,
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  fontFamily: fontFamily,
                                                  color: Colors.black,
                                                  fontSize: 12.5,
                                                  height: 1.45,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        'أوافق على شروط الاستخدام بعد قراءة ',
                                                  ),
                                                  TextSpan(
                                                    text: 'الشروط والأحكام',
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  ),
                                                  TextSpan(text: ' و '),
                                                  TextSpan(
                                                    text: 'سياسة الخصوصية',
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
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
                                  _ErrorText(message: termsError),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 53,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : continueSignup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        disabledBackgroundColor: primaryColor,
                                        disabledForegroundColor: Colors.white,
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
                                              style: TextStyle(
                                                fontFamily: fontFamily,
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Center(
                                    child: GestureDetector(
                                      onTap: goToLogin,
                                      child: RichText(
                                        textDirection: TextDirection.rtl,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'لديك حساب؟ ',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'تسجيل دخول',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
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

  InputDecoration _textFieldDecoration({
    required String hint,
    required IconData icon,
    required bool hasError,
    TextDirection? hintDirection,
  }) {
    final Color borderColor =
        hasError ? errorColor : const Color(0xFFC4C4C4);

    return InputDecoration(
      hintText: hint,
      hintTextDirection: hintDirection,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        size: 22,
        color: const Color(0xFF999999),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: _outlineBorder(borderColor),
      enabledBorder: _outlineBorder(borderColor),
      focusedBorder: _outlineBorder(
        hasError ? errorColor : primaryColor,
        width: 1.3,
      ),
    );
  }

  InputDecoration _passwordDecoration() {
    final Color borderColor =
        passwordError == null ? const Color(0xFFC4C4C4) : errorColor;

    return InputDecoration(
      hintText: 'أدخل كلمة المرور',
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
          setState(() => obscurePassword = !obscurePassword);
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
        vertical: 14,
      ),
      border: _outlineBorder(borderColor),
      enabledBorder: _outlineBorder(borderColor),
      focusedBorder: _outlineBorder(
        passwordError == null ? primaryColor : errorColor,
        width: 1.3,
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

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
              left: -2,
              bottom: -4,
              child: Image.asset(
                'assets/images/signup_plus_pattern.png',
                width: 210,
                height: 210,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
              top: 84,
              right: 20,
              left: 20,
              child: Text(
                'إنشاء حساب جديد',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'ThmanyahSerifDisplay',
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String? message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        message!,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'ThmanyahSerifDisplay',
          color: Color(0xFFD93025),
          fontSize: 11.5,
          height: 1.25,
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C3468);
    const Color errorColor = Color(0xFFD93025);
    final Color borderColor =
        hasError ? errorColor : const Color(0xFFC4C4C4);

    return Container(
      height: 53,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              width: 108,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFFC4C4C4)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🇵🇸', style: TextStyle(fontSize: 19)),
                  SizedBox(width: 7),
                  Text(
                    '+970',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: 'ThmanyahSerifDisplay',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Focus(
                  onFocusChange: (_) {},
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontFamily: 'ThmanyahSerifDisplay',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب رقمك',
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: const TextStyle(
                        fontFamily: 'ThmanyahSerifDisplay',
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        size: 22,
                        color: Color(0xFF999999),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 50,
                        minHeight: 50,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      focusColor: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C3468);

    return Material(
      color: selected ? primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? primaryColor : const Color(0xFFC4C4C4),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : Colors.black,
                size: 25,
              ),
              const SizedBox(width: 9),
              Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ThmanyahSerifDisplay',
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
