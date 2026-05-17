<<<<<<< HEAD
import 'dart:async';
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gift/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
<<<<<<< HEAD
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  // أضف TextEditingController لحقل الهاتف
  final _phoneTextController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _verificationId;
  bool _showOtpField = false;
  bool _isResendEnabled = true;
  int _resendTimer = 60;

  // متغيرات لرقم الهاتف الدولي
  PhoneNumber _phoneNumber = PhoneNumber(
    isoCode: 'SA',
    dialCode: '+966',
    phoneNumber: '',
  );

  String _internationalPhoneNumber = '';

  // قائمة الدول العربية (ISO codes)
  final List<String> _arabicCountries = [
    'SA', // السعودية
    'AE', // الإمارات
    'QA', // قطر
    'KW', // الكويت
    'BH', // البحرين
    'OM', // عمان
    'YE', // اليمن
    'JO', // الأردن
    'LB', // لبنان
    'SY', // سوريا
    'IQ', // العراق
    'PS', // فلسطين
    'EG', // مصر
    'SD', // السودان
    'LY', // ليبيا
    'TN', // تونس
    'DZ', // الجزائر
    'MA', // المغرب
    'MR', // موريتانيا
    'SO', // الصومال
    'DJ', // جيبوتي
    'KM', // جزر القمر
  ];
=======
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _isLoading = false;
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

  @override
  void dispose() {
    _nameController.dispose();
<<<<<<< HEAD
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _phoneTextController.dispose(); // أضف هذا
=======
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
<<<<<<< HEAD
      // التحقق من إدخال رقم الهاتف باستخدام عدة طرق
      bool hasValidPhone = false;

      // الطريقة 1: التحقق من _phoneNumber
      if (_phoneNumber.phoneNumber != null &&
          _phoneNumber.phoneNumber!.isNotEmpty) {
        _internationalPhoneNumber = _phoneNumber.phoneNumber!;
        hasValidPhone = true;
      }
      // الطريقة 2: التحقق من _phoneTextController
      else if (_phoneTextController.text.isNotEmpty) {
        // بناء الرقم الدولي يدوياً
        String dialCode = _phoneNumber.dialCode ?? '+966';
        String phoneNumber = _phoneTextController.text.replaceAll(
          RegExp(r'[^\d]'),
          '',
        );
        _internationalPhoneNumber = '$dialCode$phoneNumber';
        hasValidPhone = true;
      }

      if (!hasValidPhone) {
        _showErrorDialog('الرجاء إدخال رقم الهاتف');
        return;
      }

      // التحقق من أن الدولة عربية
      if (_phoneNumber.isoCode == null ||
          !_arabicCountries.contains(_phoneNumber.isoCode)) {
        _showErrorDialog('الرجاء اختيار دولة عربية');
        return;
      }

      setState(() => _isLoading = true);

      try {
        // إرسال رمز التحقق
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _internationalPhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showErrorDialog('فشل التحقق: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
              _verificationId = verificationId;
              _showOtpField = true;
              _startResendTimer();
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        _handleSignUpError(context, e);
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('حدث خطأ غير متوقع: $e');
=======
      setState(() => _isLoading = true);
      try {
        // 1. إنشاء الحساب
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 2. تحديث اسم المستخدم
        await userCredential.user!.updateDisplayName(
          _nameController.text.trim(),
        );

        // 3. إعادة تحميل بيانات المستخدم للحصول على أحدث التحديثات
        await userCredential.user!.reload();

        // 4. الحصول على بيانات المستخدم المحدثة
        final updatedUser = FirebaseAuth.instance.currentUser;

        // 5. إرسال بريد التحقق
        await updatedUser!.sendEmailVerification();

        // 6. حفظ بيانات المستخدم في Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(updatedUser.uid)
            .set({
              'uid': updatedUser.uid,
              'email': updatedUser.email,
              'name': _nameController.text.trim(),
              'role': 'client', // ← حدد نوع المستخدم هنا
              'createdAt': FieldValue.serverTimestamp(),
            });

        // 7. عرض رسالة النجاح
        _showSuccessDialog(
          context,
          updatedUser.displayName ?? _nameController.text.trim(),
          updatedUser.email ?? _emailController.text.trim(),
        );

        // 6. عرض رسالة النجاح مع بيانات المستخدم المحدثة
        _showSuccessDialog(
          context,
          updatedUser.displayName ?? _nameController.text.trim(),
          updatedUser.email ?? _emailController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        _handleSignUpError(context, e);
      } finally {
        if (mounted) setState(() => _isLoading = false);
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      }
    }
  }

<<<<<<< HEAD
  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      _showErrorDialog('الرجاء إدخال رمز التحقق');
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'invalid-verification-code') {
        _showErrorDialog('رمز التحقق غير صحيح');
      } else {
        _showErrorDialog('فشل التحقق: ${e.message}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('حدث خطأ أثناء التحقق');
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // إذا كان المستخدم جديداً (أول تسجيل)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createNewUserWithPhone(userCredential.user!);
      } else {
        _navigateToHome();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('فشل إنشاء الحساب: $e');
    }
  }

  Future<void> _createNewUserWithPhone(User user) async {
    try {
      String phoneNumber = user.phoneNumber ?? _internationalPhoneNumber;

      if (phoneNumber.isEmpty) {
        throw Exception('رقم الهاتف غير موجود');
      }

      // استخدام القيم مع التحقق من null
      final countryCode = _phoneNumber.isoCode ?? 'SA';
      final dialCode = _phoneNumber.dialCode ?? '+966';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phone': phoneNumber,
        'name': _nameController.text.trim(),
        'countryCode': countryCode,
        'dialCode': dialCode,
        'countryName': _getArabicCountryName(countryCode),
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.updateDisplayName(_nameController.text.trim());

      _showSuccessDialog(context, _nameController.text.trim(), phoneNumber);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('فشل حفظ بيانات المستخدم: ${e.toString()}');
    }
  }

  // دالة للحصول على اسم الدولة بالعربية
  String _getArabicCountryName(String? isoCode) {
    if (isoCode == null) return 'غير محدد';

    Map<String, String> arabicCountryNames = {
      'SA': 'المملكة العربية السعودية',
      'AE': 'الإمارات العربية المتحدة',
      'QA': 'دولة قطر',
      'KW': 'دولة الكويت',
      'BH': 'مملكة البحرين',
      'OM': 'سلطنة عمان',
      'YE': 'الجمهورية اليمنية',
      'JO': 'المملكة الأردنية الهاشمية',
      'LB': 'الجمهورية اللبنانية',
      'SY': 'الجمهورية العربية السورية',
      'IQ': 'جمهورية العراق',
      'PS': 'دولة فلسطين',
      'EG': 'جمهورية مصر العربية',
      'SD': 'جمهورية السودان',
      'LY': 'دولة ليبيا',
      'TN': 'الجمهورية التونسية',
      'DZ': 'الجمهورية الجزائرية الديمقراطية الشعبية',
      'MA': 'المملكة المغربية',
      'MR': 'الجمهورية الإسلامية الموريتانية',
      'SO': 'جمهورية الصومال الفيدرالية',
      'DJ': 'جمهورية جيبوتي',
      'KM': 'اتحاد جزر القمر',
    };

    return arabicCountryNames[isoCode] ?? 'دولة عربية';
  }

  void _startResendTimer() {
    _isResendEnabled = false;
    _resendTimer = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
        setState(() => _isResendEnabled = true);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_isResendEnabled) {
      await _signUp();
    }
  }

  void _handleSignUpError(BuildContext context, FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-phone-number':
        errorMessage = 'رقم الهاتف غير صالح';
        break;
      case 'quota-exceeded':
        errorMessage = 'تم تجاوز عدد المحاولات المسموح بها';
        break;
      case 'too-many-requests':
        errorMessage = 'طلبات كثيرة جداً، حاول لاحقاً';
=======
  void _handleSignUpError(BuildContext context, FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
        break;
      case 'weak-password':
        errorMessage = 'كلمة المرور ضعيفة جداً';
        break;
      case 'invalid-email':
        errorMessage = 'بريد إلكتروني غير صالح';
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
        break;
      default:
        errorMessage = 'حدث خطأ أثناء إنشاء الحساب: ${e.message}';
    }
<<<<<<< HEAD
    _showErrorDialog(errorMessage);
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(BuildContext context, String name, String phone) {
=======
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(BuildContext context, String name, String email) {
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم إنشاء الحساب بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
<<<<<<< HEAD
            _buildUserInfoRow('الاسم:', name),
            _buildUserInfoRow('رقم الهاتف:', phone),
            _buildUserInfoRow(
              'الدولة:',
              _getArabicCountryName(_phoneNumber.isoCode),
            ),
            const SizedBox(height: 8),
            const Text(
              'تم التحقق من رقم هاتفك بنجاح',
              style: TextStyle(color: Colors.green),
            ),
=======
            const Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني'),
            const SizedBox(height: 16),
            _buildUserInfoRow('الاسم:', name),
            _buildUserInfoRow('البريد:', email),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
<<<<<<< HEAD
              _navigateToHome();
            },
            child: const Text(
              'متابعة',
=======
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: const Text(
              'انتقل إلى تسجيل الدخول',
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
              style: TextStyle(color: Color(0xFF8B0000)),
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // دالة لبناء حقل رقم الهاتف الدولي (الدول العربية فقط)
  Widget _buildPhoneNumberField() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        setState(() {
          _phoneNumber = number;
          // تحديث الرقم الدولي مباشرة
          if (number.phoneNumber != null && number.phoneNumber!.isNotEmpty) {
            _internationalPhoneNumber = number.phoneNumber!;
          }
        });
      },
      onInputValidated: (bool value) {
        // يمكنك استخدام هذه الدالة للتحقق من صحة الرقم
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DROPDOWN,
        showFlags: true,
        useEmoji: true,
        setSelectorButtonAsPrefixIcon: true,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      selectorTextStyle: const TextStyle(color: Colors.black),
      initialValue: _phoneNumber,
      textFieldController: _phoneTextController, // استخدم الـ Controller هنا
      formatInput: true,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),

      // فلترة الدول العربية فقط
      countries: _arabicCountries,

      inputDecoration: InputDecoration(
        labelText: 'رقم الهاتف',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: 'أدخل رقم الهاتف',
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),

      locale: 'ar', // اللغة العربية للبحث والترجمة

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
        }
        // التحقق من أن الدولة عربية
        if (_phoneNumber.isoCode == null ||
            !_arabicCountries.contains(_phoneNumber.isoCode)) {
          return 'الرجاء اختيار دولة عربية';
        }
        return null;
      },

      // تخصيص رسائل الخطأ
      errorMessage: 'رقم هاتف غير صالح',
      isEnabled: true,
    );
  }

=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFF8B0000).withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
<<<<<<< HEAD
                autovalidateMode: AutovalidateMode.onUserInteraction,
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                child: Column(
                  children: [
                    const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

<<<<<<< HEAD
                    // رسالة توضيحية
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B0000).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF8B0000).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Color(0xFF8B0000), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'الرجاء اختيار دولة عربية ورقم هاتف صحيح',
                              style: TextStyle(
                                color: Color(0xFF8B0000),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                    _buildTextField(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

<<<<<<< HEAD
                    // حقل رقم الهاتف الدولي (الدول العربية فقط)
                    _buildPhoneNumberField(),
                    const SizedBox(height: 12),

                    // حقل رمز التحقق (يظهر بعد إرسال الرمز)
                    if (_showOtpField) ...[
                      _buildTextField(
                        controller: _otpController,
                        label: 'رمز التحقق',
                        icon: Icons.sms,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رمز التحقق';
                          }
                          if (value.length != 6) {
                            return 'رمز التحقق يجب أن يكون 6 أرقام';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    // زر إعادة الإرسال مع المؤقت
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'لم يصلك الرمز؟',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: _isResendEnabled ? _resendOtp : null,
                          child: Text(
                            _isResendEnabled
                                ? 'إعادة الإرسال'
                                : 'إعادة الإرسال بعد $_resendTimer ثانية',
                            style: TextStyle(
                              color: _isResendEnabled
                                  ? const Color(0xFF8B0000)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
=======
                    _buildTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يجب إدخال البريد الإلكتروني';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'بريد إلكتروني غير صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

                    _buildTextField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      icon: Icons.lock,
                      obscure: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline,
                      obscure: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'كلمات المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) =>
                              setState(() => _acceptTerms = value!),
                          activeColor: Color(0xFF8B0000),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _acceptTerms = !_acceptTerms),
                            child: Text(
                              'أوافق على الشروط والأحكام وسياسة الخصوصية',
                              style: TextStyle(
                                color: _acceptTerms
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton(
<<<<<<< HEAD
                      onPressed: _isLoading || !_acceptTerms
                          ? null
                          : (_showOtpField ? _verifyOtp : _signUp),
=======
                      onPressed: _isLoading || !_acceptTerms ? null : _signUp,
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
<<<<<<< HEAD
                          : Text(
                              _showOtpField ? 'تحقق من الرمز' : 'إنشاء حساب',
                              style: const TextStyle(
=======
                          : const Text(
                              'إنشاء حساب',
                              style: TextStyle(
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'لديك حساب بالفعل؟ تسجيل الدخول',
                        style: TextStyle(color: Color(0xFF8B0000)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
<<<<<<< HEAD
    TextInputType keyboardType = TextInputType.text,
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
<<<<<<< HEAD
      keyboardType: keyboardType,
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Color(0xFF8B0000)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF8B0000)),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }
}
