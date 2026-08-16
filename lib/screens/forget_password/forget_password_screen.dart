import 'package:flutter/material.dart';
import 'verification_code_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState
    extends State<ForgetPasswordScreen> {
  static const Color primaryColor = Color(0xFF0C3468);

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  String selectedCountryCode = '+970';

  final List<Map<String, String>> countryCodes = [
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
    if (emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال البريد الإلكتروني ورقم الهاتف',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const VerificationCodeScreen(),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 10,
      ),
      suffixIcon: Icon(
        icon,
        size: 18,
        color: const Color(0xFF999999),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
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

                      Positioned(
                        right: 13,
                        top: 67,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'نسيت كلمة المرور',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'أدخل حساب الإيميل لإرسال\nكود التحقق',
                              textAlign:
                              TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.35,
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
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'حساب الإيميل',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        TextField(
                          controller: emailController,
                          keyboardType:
                          TextInputType.emailAddress,
                          textDirection:
                          TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: inputDecoration(
                            hint: 'example@gmail.com',
                            icon: Icons.mail_outline,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Expanded(
                              child: Divider(
                                color:
                                Color(0xFFD5D5D5),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'أو',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color:
                                Color(0xFFD5D5D5),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'رقم الهاتف',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFFF8F8F8),
                            borderRadius:
                            BorderRadius.circular(8),
                            border: Border.all(
                              color:
                              const Color(0xFFCFCFCF),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 105,
                                decoration:
                                const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color:
                                      Color(0xFFCFCFCF),
                                    ),
                                  ),
                                ),
                                child:
                                DropdownButtonHideUnderline(
                                  child:
                                  DropdownButton<
                                      String>(
                                    value:
                                    selectedCountryCode,
                                    isExpanded:
                                    true,
                                    icon:
                                    const Icon(
                                      Icons
                                          .keyboard_arrow_down,
                                      size: 18,
                                    ),
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 8,
                                    ),
                                    items:
                                    countryCodes.map(
                                          (country) {
                                        return DropdownMenuItem<
                                            String>(
                                          value:
                                          country['code'],
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                country[
                                                'flag']!,
                                                style:
                                                const TextStyle(
                                                  fontSize:
                                                  17,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                country[
                                                'code']!,
                                                style:
                                                const TextStyle(
                                                  fontSize:
                                                  11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged:
                                        (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedCountryCode =
                                              value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),

                              Expanded(
                                child: TextField(
                                  controller:
                                  phoneController,
                                  keyboardType:
                                  TextInputType.phone,
                                  textAlign:
                                  TextAlign.right,
                                  decoration:
                                  const InputDecoration(
                                    hintText:
                                    'اكتب رقمك',
                                    hintStyle:
                                    TextStyle(
                                      color:
                                      Color(0xFFAAAAAA),
                                      fontSize: 10,
                                    ),
                                    border:
                                    InputBorder.none,
                                    contentPadding:
                                    EdgeInsets
                                        .symmetric(
                                      horizontal: 11,
                                    ),
                                  ),
                                ),
                              ),

                              const Padding(
                                padding:
                                EdgeInsets.only(
                                  right: 10,
                                ),
                                child: Icon(
                                  Icons.phone_outlined,
                                  size: 18,
                                  color:
                                  Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          height: 43,
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
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'إستمرار',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 125),

                        Center(
                          child: Container(
                            width: 80,
                            height: 4,
                            decoration:
                            BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.circular(
                                10,
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
      ),
    );
  }
}