import 'package:flutter/material.dart';
import 'verification_code_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFCFCFCF);
  static const Color hintColor = Color(0xFFAAAAAA);

  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  String selectedCountryCode = '+970';

  final List<Map<String, String>> countryCodes = const [
    {
      'name': 'فلسطين',
      'code': '+970',
      'flag': '🇵🇸',
    },
    {
      'name': 'الأردن',
      'code': '+962',
      'flag': '🇯🇴',
    },
    {
      'name': 'مصر',
      'code': '+20',
      'flag': '🇪🇬',
    },
    {
      'name': 'السعودية',
      'code': '+966',
      'flag': '🇸🇦',
    },
    {
      'name': 'الإمارات',
      'code': '+971',
      'flag': '🇦🇪',
    },
    {
      'name': 'قطر',
      'code': '+974',
      'flag': '🇶🇦',
    },
    {
      'name': 'الكويت',
      'code': '+965',
      'flag': '🇰🇼',
    },
    {
      'name': 'البحرين',
      'code': '+973',
      'flag': '🇧🇭',
    },
    {
      'name': 'عُمان',
      'code': '+968',
      'flag': '🇴🇲',
    },
    {
      'name': 'تركيا',
      'code': '+90',
      'flag': '🇹🇷',
    },
    {
      'name': 'الولايات المتحدة',
      'code': '+1',
      'flag': '🇺🇸',
    },
    {
      'name': 'بريطانيا',
      'code': '+44',
      'flag': '🇬🇧',
    },
  ];

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void continueToVerification() {
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();
    final String phone = phoneController.text.trim();

    // يكفي إدخال البريد الإلكتروني أو رقم الهاتف.
    if (email.isEmpty && phone.isEmpty) {
      showMessage('يرجى إدخال البريد الإلكتروني أو رقم الهاتف');
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      showMessage('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty && phoneDigits.length < 7) {
      showMessage('يرجى إدخال رقم هاتف صحيح');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VerificationCodeScreen(),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: fontFamily),
          ),
        ),
      ),
    );
  }

  InputDecoration emailDecoration() {
    return InputDecoration(
      hintText: 'example@gmail.com',
      hintTextDirection: TextDirection.ltr,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: hintColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: const Icon(
        Icons.mail_outline_rounded,
        size: 18,
        color: Color(0xFF999999),
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 42,
        minHeight: 42,
      ),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      border: outlineBorder(borderColor),
      enabledBorder: outlineBorder(borderColor),
      focusedBorder: outlineBorder(
        primaryColor,
        width: 1.2,
      ),
    );
  }

  OutlineInputBorder outlineBorder(
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
                          const _HeaderSection(),

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
                                  25,
                                  20,
                                  30,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const _FieldLabel(
                                      text: 'حساب الإيميل',
                                    ),

                                    const SizedBox(height: 6),

                                    SizedBox(
                                      height: 53,
                                      child: TextField(
                                        controller: emailController,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                        textInputAction:
                                        TextInputAction.next,
                                        textDirection:
                                        TextDirection.ltr,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        decoration: emailDecoration(),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    const _OrDivider(),

                                    const SizedBox(height: 22),

                                    const _FieldLabel(
                                      text: 'رقم الهاتف',
                                    ),

                                    const SizedBox(height: 6),

                                    _PhoneField(
                                      controller: phoneController,
                                      selectedCountryCode:
                                      selectedCountryCode,
                                      countryCodes: countryCodes,
                                      onCountryChanged: (value) {
                                        if (value == null) return;

                                        setState(() {
                                          selectedCountryCode = value;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 34),

                                    SizedBox(
                                      height: 53,
                                      child: ElevatedButton(
                                        onPressed:
                                        continueToVerification,
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          primaryColor,
                                          foregroundColor:
                                          Colors.white,
                                          elevation: 0,
                                          shadowColor:
                                          Colors.transparent,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'استمرار',
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 17,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /*
                                      لا يوجد Home Indicator هنا.
                                      الخط الأسود السفلي تم حذفه.
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
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

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
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/forget_password_pattern.png',
                  width: 175,
                  height: 175,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox.shrink();
                  },
                ),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'نسيت كلمة المرور',
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFD5D5D5),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو',
            style: TextStyle(
              fontFamily: 'ThmanyahSerifDisplay',
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFD5D5D5),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String?> onCountryChanged;

  const _PhoneField({
    required this.controller,
    required this.selectedCountryCode,
    required this.countryCodes,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCFCFCF),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              width: 104,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Color(0xFFCFCFCF),
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  style: const TextStyle(
                    fontFamily: 'ThmanyahSerifDisplay',
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  items: countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            country['flag']!,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            country['code']!,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontFamily:
                              'ThmanyahSerifDisplay',
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onCountryChanged,
                ),
              ),
            ),

            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'ThmanyahSerifDisplay',
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'اكتب رقمك',
                    hintStyle: TextStyle(
                      fontFamily: 'ThmanyahSerifDisplay',
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIcon: Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: Color(0xFF999999),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 14,
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
