import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class PharmacistDetailsScreen extends StatefulWidget {
  final String email;
  final String password;
  final String phone;

  const PharmacistDetailsScreen({
    super.key,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  State<PharmacistDetailsScreen> createState() =>
      _PharmacistDetailsScreenState();
}

class _PharmacistDetailsScreenState extends State<PharmacistDetailsScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController pharmacyAddressController =
      TextEditingController();

  DateTime? selectedBirthDate;
  bool isLoading = false;
  bool accountCreatedSuccessfully = false;

  String? nameError;
  String? idError;
  String? birthDateError;
  String? pharmacyNameError;
  String? pharmacyAddressError;

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
    idController.dispose();
    birthDateController.dispose();
    pharmacyNameController.dispose();
    pharmacyAddressController.dispose();
    super.dispose();
  }

  void onNameChanged(String value) {
    if (nameError == null) return;
    setState(() => nameError = null);
  }

  void onIdChanged(String value) {
    if (idError == null) return;
    setState(() => idError = null);
  }

  void onPharmacyNameChanged(String value) {
    if (pharmacyNameError == null) return;
    setState(() => pharmacyNameError = null);
  }

  void onPharmacyAddressChanged(String value) {
    if (pharmacyAddressError == null) return;
    setState(() => pharmacyAddressError = null);
  }

  Future<void> selectBirthDate() async {
    FocusScope.of(context).unfocus();

    final DateTime today = DateTime.now();
    final DateTime initialDate = selectedBirthDate ??
        DateTime(today.year - 18, today.month, today.day);

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
    final String identityNumber = idController.text.trim();
    final String pharmacyName = pharmacyNameController.text.trim();
    final String pharmacyAddress = pharmacyAddressController.text.trim();
    final List<String> nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    String? nextNameError;
    String? nextIdError;
    String? nextBirthDateError;
    String? nextPharmacyNameError;
    String? nextPharmacyAddressError;

    if (fullName.isEmpty) {
      nextNameError = 'يرجى إدخال الاسم الرباعي';
    } else if (nameParts.length < 4) {
      nextNameError = 'يرجى إدخال الاسم الرباعي كاملًا';
    }

    if (identityNumber.isEmpty) {
      nextIdError = 'يرجى إدخال رقم الهوية';
    } else if (identityNumber.length != 9) {
      nextIdError = 'رقم الهوية يجب أن يتكون من 9 أرقام';
    }

    if (selectedBirthDate == null) {
      nextBirthDateError = 'يرجى اختيار تاريخ الميلاد';
    }

    if (pharmacyName.isEmpty) {
      nextPharmacyNameError = 'يرجى إدخال اسم الصيدلية';
    }

    if (pharmacyAddress.isEmpty) {
      nextPharmacyAddressError = 'يرجى إدخال عنوان الصيدلية';
    }

    setState(() {
      nameError = nextNameError;
      idError = nextIdError;
      birthDateError = nextBirthDateError;
      pharmacyNameError = nextPharmacyNameError;
      pharmacyAddressError = nextPharmacyAddressError;
    });

    if (nextNameError != null ||
        nextIdError != null ||
        nextBirthDateError != null ||
        nextPharmacyNameError != null ||
        nextPharmacyAddressError != null) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.instance.registerPharmacist(
        email: widget.email,
        phoneNumber: widget.phone,
        password: widget.password,
        fullName: fullName,
        idNumber: identityNumber,
        dateOfBirth: selectedBirthDate!,
        pharmacyName: pharmacyName,
        pharmacyAddress: pharmacyAddress,
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
        idError = error.fieldErrors['id_number'];
        birthDateError = error.fieldErrors['date_of_birth'];
        pharmacyNameError = error.fieldErrors['pharmacy_name'];
        pharmacyAddressError = error.fieldErrors['pharmacy_address'];
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
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: fontFamily),
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
                  _SuccessOverlay(onLogin: goToLogin),
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
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const _PharmacistHeader(),
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
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: nameController,
                            hint: 'أدخل اسمك الرباعي',
                            icon: Icons.badge_outlined,
                            error: nameError,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            onChanged: onNameChanged,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: idController,
                            hint: 'أدخل رقم الهوية',
                            icon: Icons.credit_card_rounded,
                            error: idError,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.ltr,
                            maxLength: 9,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: onIdChanged,
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: pharmacyNameController,
                            hint: 'أدخل اسم الصيدلية',
                            icon: Icons.local_pharmacy_outlined,
                            error: pharmacyNameError,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: onPharmacyNameChanged,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: pharmacyAddressController,
                            hint: 'أدخل عنوان الصيدلية',
                            icon: Icons.location_on_outlined,
                            error: pharmacyAddressError,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            onChanged: onPharmacyAddressChanged,
                            onSubmitted: (_) => createAccount(),
                          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? error,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required ValueChanged<String> onChanged,
    TextDirection textDirection = TextDirection.rtl,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 53,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textDirection: textDirection,
            textAlign: TextAlign.right,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: _inputStyle,
            decoration: _fieldDecoration(
              hint: hint,
              icon: icon,
              hasError: error != null,
            ).copyWith(counterText: ''),
          ),
        ),
        _ErrorText(message: error),
      ],
    );
  }

  TextStyle get _inputStyle => const TextStyle(
        fontFamily: fontFamily,
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

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

  OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _PharmacistHeader extends StatelessWidget {
  const _PharmacistHeader();

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
              top: 90,
              right: 20,
              left: 20,
              child: Text(
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
            ),
          ],
        ),
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

class _SuccessOverlay extends StatelessWidget {
  final VoidCallback onLogin;

  const _SuccessOverlay({required this.onLogin});

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
