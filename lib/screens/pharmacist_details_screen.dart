import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class _PharmacistDetailsScreenState
    extends State<PharmacistDetailsScreen> {
  static const Color primaryColor = Color(0xFF0C3468);
  static const Color errorColor = Color(0xFFD93025);
  static const Color fieldColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFC4C4C4);
  static const String fontFamily = 'ThmanyahSerifDisplay';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController pharmacyNameController =
  TextEditingController();
  final TextEditingController pharmacyAddressController =
  TextEditingController();

  final Geocoding geocoding = Geocoding();

  DateTime? selectedBirthDate;
  LatLng? selectedPharmacyLocation;
  GoogleMapController? mapController;

  bool isLoading = false;
  bool isFindingAddress = false;
  bool isResolvingMapAddress = false;
  bool isMapMoving = false;
  bool accountCreatedSuccessfully = false;

  int mapAddressRequestId = 0;

  // يحتفظ بالعنوان الذي كتبته الصيدلانية.
  String lastTypedPharmacyAddress = '';

  String? nameError;
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
    birthDateController.dispose();
    pharmacyNameController.dispose();
    pharmacyAddressController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void onNameChanged(String value) {
    if (nameError == null) return;
    setState(() => nameError = null);
  }

  void onPharmacyNameChanged(String value) {
    if (pharmacyNameError == null) return;
    setState(() => pharmacyNameError = null);
  }

  void onPharmacyAddressChanged(String value) {
    lastTypedPharmacyAddress = value.trim();

    setState(() {
      pharmacyAddressError = null;

      // عند كتابة عنوان جديد يجب تحديده مرة أخرى.
      selectedPharmacyLocation = null;
      mapController = null;
      isMapMoving = false;
      isResolvingMapAddress = false;
    });
  }

  Future<void> selectBirthDate() async {
    FocusScope.of(context).unfocus();

    final DateTime today = DateTime.now();

    final DateTime initialDate = selectedBirthDate ??
        DateTime(
          today.year - 18,
          today.month,
          today.day,
        );

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

  Future<void> locatePharmacyAddress() async {
    FocusScope.of(context).unfocus();

    final String address = pharmacyAddressController.text.trim();

    if (address.isEmpty) {
      setState(() {
        pharmacyAddressError = 'يرجى كتابة عنوان الصيدلية أولًا';
      });
      return;
    }

    if (isFindingAddress) return;

    lastTypedPharmacyAddress = address;

    setState(() {
      isFindingAddress = true;
      pharmacyAddressError = null;
    });

    try {
      List<Location> locations = await geocoding.locationFromAddress(
        '$address, Gaza, Palestine',
      );

      if (locations.isEmpty) {
        locations = await geocoding.locationFromAddress(
          '$address, Gaza Strip, Palestine',
        );
      }

      if (!mounted) return;

      if (locations.isEmpty) {
        setState(() {
          isFindingAddress = false;
          pharmacyAddressError =
          'لم نتمكن من العثور على العنوان، اكتبيه بشكل أوضح';
        });

        showMessage(
          'لم نتمكن من العثور على العنوان، اكتبي اسم الحي والشارع بشكل أوضح',
        );
        return;
      }

      final Location result = locations.first;

      final LatLng location = LatLng(
        result.latitude,
        result.longitude,
      );

      setState(() {
        selectedPharmacyLocation = location;
        isFindingAddress = false;
        pharmacyAddressError = null;
      });

      // ننتظر حتى يتم إنشاء الخريطة.
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 17,
          ),
        ),
      );

      await _updateAddressFromCoordinates(location);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isFindingAddress = false;
        pharmacyAddressError =
        'تعذر العثور على العنوان، تأكدي من الإنترنت وحاولي مجددًا';
      });

      showMessage(
        'تعذر العثور على العنوان، تأكدي من اتصال الإنترنت',
      );
    }
  }

  void onMapCameraMoveStarted() {
    if (!mounted) return;

    setState(() {
      isMapMoving = true;
      pharmacyAddressError = null;
    });
  }

  void onMapCameraMove(CameraPosition cameraPosition) {
    // موقع الدبوس الثابت هو مركز الخريطة.
    selectedPharmacyLocation = cameraPosition.target;
  }

  Future<void> onMapCameraIdle() async {
    final LatLng? location = selectedPharmacyLocation;

    if (location == null) return;

    if (mounted) {
      setState(() {
        isMapMoving = false;
      });
    }

    await _updateAddressFromCoordinates(location);
  }

  Future<void> _updateAddressFromCoordinates(
      LatLng location,
      ) async {
    final int currentRequestId = ++mapAddressRequestId;

    if (mounted) {
      setState(() {
        isResolvingMapAddress = true;
        pharmacyAddressError = null;
      });
    }

    try {
      final List<Placemark> placemarks =
      await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted || currentRequestId != mapAddressRequestId) {
        return;
      }

      final String address = placemarks.isEmpty
          ? _fallbackAddress()
          : _formatPlacemark(placemarks.first);

      // تغيير قيمة Controller بهذه الطريقة لا يشغّل onChanged.
      pharmacyAddressController.value = TextEditingValue(
        text: address,
        selection: TextSelection.collapsed(
          offset: address.length,
        ),
      );

      setState(() {
        selectedPharmacyLocation = location;
        isResolvingMapAddress = false;
        pharmacyAddressError = null;
      });
    } catch (_) {
      if (!mounted || currentRequestId != mapAddressRequestId) {
        return;
      }

      final String fallbackAddress = _fallbackAddress();

      pharmacyAddressController.value = TextEditingValue(
        text: fallbackAddress,
        selection: TextSelection.collapsed(
          offset: fallbackAddress.length,
        ),
      );

      setState(() {
        selectedPharmacyLocation = location;
        isResolvingMapAddress = false;
        pharmacyAddressError =
        'تعذر تحديث اسم الشارع؛ تم الاحتفاظ بالعنوان المكتوب';
      });
    }
  }

  String _formatPlacemark(Placemark place) {
    final String typedArea = _typedAreaName();

    // عادة يحتوي subLocality على اسم الحي.
    String area = _cleanAddressPart(place.subLocality);

    // بعض الأجهزة تضع اسم الحي في حقل آخر.
    if (!_isUsefulAddressPart(area)) {
      area = _cleanAddressPart(place.subAdministrativeArea);
    }

    // إذا لم تُرجع الخريطة اسم الحي، نستخدم الاسم المكتوب.
    if (!_isUsefulAddressPart(area) || _isGazaName(area)) {
      area = typedArea;
    }

    String street = _cleanStreet(place.street);

    // أحيانًا يكون اسم الشارع داخل name.
    if (!_isUsefulStreet(street)) {
      street = _cleanStreet(place.name);
    }

    if (_isUsefulStreet(street) && !_startsWithRoadWord(street)) {
      street = 'شارع $street';
    }

    if (_sameAddressPart(street, area)) {
      street = '';
    }

    String city = _cleanAddressPart(place.locality);

    if (!_isUsefulAddressPart(city) || _isGazaName(city)) {
      city = 'غزة';
    }

    final List<String> parts = <String>[];

    _addUniquePart(parts, area);
    _addUniquePart(parts, street);
    _addUniquePart(parts, city);

    if (parts.length == 1 && parts.first == 'غزة') {
      return _fallbackAddress();
    }

    return parts.isEmpty ? _fallbackAddress() : parts.join('، ');
  }

  String _typedAreaName() {
    String value = lastTypedPharmacyAddress.trim();

    if (value.isEmpty) return '';

    value = value
        .replaceAll(RegExp(r'[،,]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final List<String> ignoredWords = <String>[
      'قطاع غزة',
      'غزة',
      'فلسطين',
      'gaza strip',
      'gaza',
      'palestine',
    ];

    for (final String word in ignoredWords) {
      value = value.replaceAll(
        RegExp(
          RegExp.escape(word),
          caseSensitive: false,
        ),
        ' ',
      );
    }

    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    // مثال: "النصر شارع العيون"
    // نستخدم "النصر" كاسم الحي.
    final RegExp streetSeparator = RegExp(
      r'\s+(?:شارع|طريق|ميدان|street|road)\s+',
      caseSensitive: false,
    );

    final Match? streetMatch = streetSeparator.firstMatch(value);

    if (streetMatch != null) {
      value = value.substring(0, streetMatch.start).trim();
    }

    return value;
  }

  String _cleanAddressPart(String? value) {
    if (value == null) return '';

    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[،,\-\s]+|[،,\-\s]+$'), '')
        .trim();
  }

  String _cleanStreet(String? value) {
    String street = _cleanAddressPart(value);

    // حذف رقم المبنى الموجود في بداية اسم الشارع.
    street = street
        .replaceFirst(
      RegExp(r'^\d+[A-Za-zأ-ي]?\s*[,،\-]?\s*'),
      '',
    )
        .trim();

    if (!_isUsefulStreet(street)) return '';

    return street;
  }

  bool _isUsefulAddressPart(String value) {
    final String part = value.trim();

    if (part.isEmpty || RegExp(r'^\d+$').hasMatch(part)) {
      return false;
    }

    final String lower = part.toLowerCase();

    return lower != 'unnamed road' &&
        lower != 'unknown' &&
        lower != 'null' &&
        !lower.contains('طريق بدون اسم');
  }

  bool _isUsefulStreet(String value) {
    if (!_isUsefulAddressPart(value)) return false;

    // تجاهل Plus Codes.
    if (RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}').hasMatch(value)) {
      return false;
    }

    // تجاهل الإحداثيات.
    if (RegExp(r'^-?\d+\.\d+\s*,\s*-?\d+\.\d+$').hasMatch(value)) {
      return false;
    }

    return true;
  }

  bool _startsWithRoadWord(String value) {
    final String lower = value.toLowerCase();

    return lower.startsWith('شارع ') ||
        lower.startsWith('طريق ') ||
        lower.startsWith('ميدان ') ||
        lower.startsWith('street ') ||
        lower.startsWith('road ') ||
        lower.endsWith(' street') ||
        lower.endsWith(' road');
  }

  bool _isGazaName(String value) {
    final String normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return normalized == 'غزة' ||
        normalized == 'قطاع غزة' ||
        normalized == 'gaza' ||
        normalized == 'gaza strip' ||
        normalized == 'gaza governorate';
  }

  bool _sameAddressPart(String first, String second) {
    String normalize(String value) {
      return value
          .toLowerCase()
          .replaceFirst(
        RegExp(r'^(شارع|طريق|street|road)\s+'),
        '',
      )
          .replaceAll(RegExp(r'[^a-z0-9أ-ي]+'), '')
          .trim();
    }

    final String firstValue = normalize(first);
    final String secondValue = normalize(second);

    return firstValue.isNotEmpty && firstValue == secondValue;
  }

  void _addUniquePart(
      List<String> parts,
      String value,
      ) {
    final String part = value.trim();

    if (!_isUsefulAddressPart(part)) return;

    final bool alreadyExists = parts.any(
          (existing) => _sameAddressPart(existing, part),
    );

    if (!alreadyExists) {
      parts.add(part);
    }
  }

  String _fallbackAddress() {
    final String typedAddress = lastTypedPharmacyAddress.trim();

    if (typedAddress.isEmpty) return 'غزة';

    if (typedAddress.toLowerCase().contains('غزة') ||
        typedAddress.toLowerCase().contains('gaza')) {
      return typedAddress;
    }

    return '$typedAddress، غزة';
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    final String fullName = nameController.text.trim();
    final String pharmacyName = pharmacyNameController.text.trim();
    final String pharmacyAddress =
    pharmacyAddressController.text.trim();

    final List<String> nameParts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    String? nextNameError;
    String? nextBirthDateError;
    String? nextPharmacyNameError;
    String? nextPharmacyAddressError;

    if (fullName.isEmpty) {
      nextNameError = 'يرجى إدخال الاسم الرباعي';
    } else if (nameParts.length < 4) {
      nextNameError = 'يرجى إدخال الاسم الرباعي كاملًا';
    }

    if (selectedBirthDate == null) {
      nextBirthDateError = 'يرجى اختيار تاريخ الميلاد';
    }

    if (pharmacyName.isEmpty) {
      nextPharmacyNameError = 'يرجى إدخال اسم الصيدلية';
    }

    if (pharmacyAddress.isEmpty) {
      nextPharmacyAddressError = 'يرجى إدخال عنوان الصيدلية';
    } else if (selectedPharmacyLocation == null) {
      nextPharmacyAddressError =
      'اضغطي على أيقونة الموقع لتحديد الصيدلية على الخريطة';
    }

    setState(() {
      nameError = nextNameError;
      birthDateError = nextBirthDateError;
      pharmacyNameError = nextPharmacyNameError;
      pharmacyAddressError = nextPharmacyAddressError;
    });

    if (nextNameError != null ||
        nextBirthDateError != null ||
        nextPharmacyNameError != null ||
        nextPharmacyAddressError != null) {
      return;
    }

    final LatLng pharmacyLocation = selectedPharmacyLocation!;

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.instance.registerPharmacist(
        email: widget.email,
        phoneNumber: widget.phone,
        password: widget.password,
        fullName: fullName,
        dateOfBirth: selectedBirthDate!,
        pharmacyName: pharmacyName,
        pharmacyAddress: pharmacyAddress,
        pharmacyLatitude: pharmacyLocation.latitude,
        pharmacyLongitude: pharmacyLocation.longitude,
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
        pharmacyNameError = error.fieldErrors['pharmacy_name'];

        pharmacyAddressError =
            error.fieldErrors['pharmacy_address'] ??
                error.fieldErrors['pharmacy_latitude'] ??
                error.fieldErrors['pharmacy_longitude'];
      });

      showMessage(error.message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
      );
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
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
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
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
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
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      28,
                      20,
                      24,
                    ),
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
                        _buildPharmacyAddressField(),
                        if (selectedPharmacyLocation != null) ...[
                          const SizedBox(height: 14),
                          _buildPharmacyMap(),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              if (isResolvingMapAddress)
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 8,
                                    top: 1,
                                  ),
                                  child: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  isMapMoving
                                      ? 'حرّكي الخريطة حتى تصبح العلامة فوق موقع الصيدلية.'
                                      : isResolvingMapAddress
                                      ? 'جارٍ تحديد العنوان...'
                                      : 'حرّكي الخريطة وسيتم تحديث اسم الحي والشارع تلقائيًا.',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontFamily: fontFamily,
                                    color: Color(0xFF666666),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 53,
                          child: ElevatedButton(
                            onPressed: isLoading ||
                                isMapMoving ||
                                isResolvingMapAddress
                                ? null
                                : createAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              disabledBackgroundColor:
                              primaryColor.withOpacity(0.60),
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
        );
      },
    );
  }

  Widget _buildPharmacyAddressField() {
    final Color activeBorder =
    pharmacyAddressError != null ? errorColor : borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 53,
          child: TextField(
            controller: pharmacyAddressController,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.search,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: onPharmacyAddressChanged,
            onSubmitted: (_) {
              locatePharmacyAddress();
            },
            style: _inputStyle,
            decoration: InputDecoration(
              hintText: 'مثال: النصر، شارع العيون',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(
                fontFamily: fontFamily,
                color: Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: IconButton(
                onPressed:
                isFindingAddress ? null : locatePharmacyAddress,
                tooltip: 'تحديد الموقع على الخريطة',
                icon: isFindingAddress
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.location_on_rounded,
                  color: primaryColor,
                  size: 25,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 52,
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
                pharmacyAddressError != null
                    ? errorColor
                    : primaryColor,
                width: 1.3,
              ),
            ),
          ),
        ),
        _ErrorText(message: pharmacyAddressError),
      ],
    );
  }

  Widget _buildPharmacyMap() {
    final LatLng location = selectedPharmacyLocation!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 17,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              onCameraMoveStarted: onMapCameraMoveStarted,
              onCameraMove: onMapCameraMove,
              onCameraIdle: onMapCameraIdle,
              gestureRecognizers:
              <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              markers: const <Marker>{},
            ),
            IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFD93025),
                      size: 48,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    SizedBox(height: 1),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 12,
                        height: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isResolvingMapAddress)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'جارٍ تحديد العنوان',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: primaryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: _inputStyle,
            decoration: _fieldDecoration(
              hint: hint,
              icon: icon,
              hasError: error != null,
            ),
          ),
        ),
        _ErrorText(message: error),
      ],
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
    final Color activeBorder =
    hasError ? errorColor : borderColor;

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
                errorBuilder: (_, __, ___) =>
                const SizedBox.shrink(),
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
              margin: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                8,
              ),
              padding: const EdgeInsets.fromLTRB(
                26,
                28,
                26,
                36,
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