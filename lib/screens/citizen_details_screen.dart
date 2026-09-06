import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class CitizenDetailsScreen extends StatefulWidget {
  final String email;
  final String password;
  final String phone;

  const CitizenDetailsScreen({
    super.key,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  State<CitizenDetailsScreen> createState() =>
      _CitizenDetailsScreenState();
}

class _CitizenDetailsScreenState extends State<CitizenDetailsScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController chronicDiseaseController =
  TextEditingController();

  DateTime? selectedBirthDate;
  bool? hasChronicDisease;
  bool isLoading = false;
  bool accountCreatedSuccessfully = false;

  String? nameError;
  String? birthDateError;
  String? chronicChoiceError;
  String? chronicDiseaseError;

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
    nameController.dispose();
    birthDateController.dispose();
    chronicDiseaseController.dispose();
    super.dispose();
  }

  void onNameChanged(String value) {
    if (nameError == null) return;

    setState(() {
      nameError = null;
    });
  }

  void onDiseaseChanged(String value) {
    if (chronicDiseaseError == null) return;

    setState(() {
      chronicDiseaseError = null;
    });
  }

  void selectChronicDisease(bool value) {
    setState(() {
      hasChronicDisease = value;
      chronicChoiceError = null;

      if (!value) {
        chronicDiseaseController.clear();
        chronicDiseaseError = null;
      }
    });
  }

  Future<void> selectBirthDate() async {
    FocusScope.of(context).unfocus();

    final DateTime today = DateTime.now();

    final DateTime initialDate =
        selectedBirthDate ?? DateTime(today.year - 18, today.month, today.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: today,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'اختر تاريخ الميلاد من التقويم',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      selectedBirthDate = pickedDate;
      birthDateController.text = _formatDate(pickedDate);
      birthDateError = null;
    });
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    final String fullName = nameController.text.trim();
    final String disease = chronicDiseaseController.text.trim();

    final List<String> nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    String? nextNameError;
    String? nextBirthDateError;
    String? nextChronicChoiceError;
    String? nextDiseaseError;

    if (fullName.isEmpty) {
      nextNameError = 'يرجى إدخال الاسم الرباعي';
    } else if (nameParts.length < 4) {
      nextNameError = 'يرجى إدخال الاسم الرباعي كاملًا';
    }

    if (selectedBirthDate == null) {
      nextBirthDateError = 'يرجى اختيار تاريخ الميلاد';
    }

    if (hasChronicDisease == null) {
      nextChronicChoiceError = 'يرجى اختيار نعم أو لا';
    } else if (hasChronicDisease! && disease.isEmpty) {
      nextDiseaseError = 'يرجى كتابة المرض المزمن';
    }

    setState(() {
      nameError = nextNameError;
      birthDateError = nextBirthDateError;
      chronicChoiceError = nextChronicChoiceError;
      chronicDiseaseError = nextDiseaseError;
    });

    if (nextNameError != null ||
        nextBirthDateError != null ||
        nextChronicChoiceError != null ||
        nextDiseaseError != null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.instance.registerCitizen(
        email: widget.email,
        phoneNumber: widget.phone,
        password: widget.password,
        fullName: fullName,
        dateOfBirth: selectedBirthDate!,
        hasChronicDisease: hasChronicDisease!,
        chronicDiseaseDescription: disease,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        accountCreatedSuccessfully = true;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        nameError = error.fieldErrors['full_name'];
        birthDateError = error.fieldErrors['date_of_birth'];
        chronicDiseaseError =
        error.fieldErrors['chronic_disease_description'];
      });

      showMessage(error.message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            message,
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
    Navigator.popUntil(context, (route) => route.isFirst);
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
                _buildMainContent(),
                if (accountCreatedSuccessfully)
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

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const _CitizenHeader(),
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
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 53,
                            child: TextField(
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              onChanged: onNameChanged,
                              style: _inputStyle,
                              decoration: _fieldDecoration(
                                hint: 'أدخل اسمك الرباعي',
                                icon: Icons.badge_outlined,
                                hasError: nameError != null,
                              ),
                            ),
                          ),
                          _ErrorText(message: nameError),
                          const SizedBox(height: 16),

                          // حقل تاريخ الميلاد
                          SizedBox(
                            height: 53,
                            child: TextField(
                              controller: birthDateController,
                              readOnly: true,
                              onTap: selectBirthDate,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              style: _inputStyle,
                              decoration: _fieldDecoration(
                                hint: 'اليوم / الشهر / السنة',
                                icon: Icons.calendar_month_outlined,
                                hasError: birthDateError != null,
                              ),
                            ),
                          ),
                          _ErrorText(message: birthDateError),
                          const SizedBox(height: 22),

                          const Text(
                            'هل تعاني من مرض مزمن؟',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _RadioChoice(
                                label: 'نعم',
                                selected: hasChronicDisease == true,
                                onTap: () {
                                  selectChronicDisease(true);
                                },
                              ),
                              const SizedBox(width: 55),
                              _RadioChoice(
                                label: 'لا',
                                selected: hasChronicDisease == false,
                                onTap: () {
                                  selectChronicDisease(false);
                                },
                              ),
                            ],
                          ),
                          _ErrorText(message: chronicChoiceError),

                          if (hasChronicDisease == true) ...[
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 53,
                              child: TextField(
                                controller: chronicDiseaseController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                onChanged: onDiseaseChanged,
                                onSubmitted: (_) {
                                  createAccount();
                                },
                                style: _inputStyle,
                                decoration: _fieldDecoration(
                                  hint: 'صف مرضك المزمن',
                                  icon: Icons.favorite_border_rounded,
                                  hasError: chronicDiseaseError != null,
                                ),
                              ),
                            ),
                            _ErrorText(
                              message: chronicDiseaseError,
                            ),
                          ],

                          const SizedBox(height: 36),

                          SizedBox(
                            height: 53,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                disabledBackgroundColor: primaryColor,
                                disabledForegroundColor: Colors.white,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'إنشاء حساب',
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
    );
  }

  TextStyle get _inputStyle {
    return const TextStyle(
      fontFamily: fontFamily,
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required bool hasError,
  }) {
    final Color activeBorder = hasError ? errorColor : borderColor;

    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFFAAAAAA),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        size: 22,
        color: const Color(0xFF888888),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
      ),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: _outlineBorder(activeBorder),
      enabledBorder: _outlineBorder(activeBorder),
      focusedBorder: _outlineBorder(
        hasError ? errorColor : primaryColor,
        width: 1.3,
      ),
    );
  }

  OutlineInputBorder _outlineBorder(
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
}

class _CitizenHeader extends StatelessWidget {
  const _CitizenHeader();

  static const Color primaryColor = Color(0xFF0C3468);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 265,
      color: primaryColor,
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -4,
              bottom: -6,
              child: Image.asset(
                'assets/images/signup_plus_pattern.png',
                width: 230,
                height: 230,
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
                  onTap: () {
                    Navigator.pop(context);
                  },
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
              top: 78,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إنشاء حساب جديد',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'قم بتعبئة البيانات',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
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

class _RadioChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C3468);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'ThmanyahSerifDisplay',
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 23,
              height: 23,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor,
                  width: 1.5,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? primaryColor : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String? message;

  const _ErrorText({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }

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
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 36),
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
                    width: 95,
                    height: 95,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 95,
                        height: 95,
                        decoration: const BoxDecoration(
                          color: Color(0xFF98E2AE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 62,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'تم إنشاء حساب جديد',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 295,
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
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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