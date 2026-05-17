import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gift/Search/main_layout.dart';
import 'package:gift/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneTextController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _isResendEnabled = true;
  int _resendTimer = 60;
  Timer? _resendTimerInstance;

  // متغيرات لرقم الهاتف
  String _internationalPhoneNumber = '';
  String? _verificationId;

  // متغيرات لاختيار الدولة
  String _selectedCountryCode = '+966';
  String _selectedCountryFlag = '🇸🇦';
  String _selectedCountryIso = 'SA';

  // قائمة الدول العربية
  final List<String> _arabicCountries = [
    'SA',
    'AE',
    'QA',
    'KW',
    'BH',
    'OM',
    'YE',
    'JO',
    'LB',
    'SY',
    'IQ',
    'PS',
    'EG',
    'SD',
    'LY',
    'TN',
    'DZ',
    'MA',
    'MR',
    'SO',
    'DJ',
    'KM',
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    _phoneTextController.dispose();
    _resendTimerInstance?.cancel();
    super.dispose();
  }

  // دالة مساعدة للتحقق من mounted
  bool _isMounted() {
    return mounted;
  }

  // دالة مساعدة لتحديث الحالة بأمان
  void _safeSetState(VoidCallback fn) {
    if (_isMounted()) {
      setState(fn);
    }
  }

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
                child: Column(
                  children: [
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // رسالة توضيحية
                    if (!_showOtpField)
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
                            Icon(
                              Icons.info,
                              color: Color(0xFF8B0000),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'سجل دخولك برقم هاتفك المسجل',
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

                    // حقل رقم الهاتف
                    _buildPhoneNumberField(),
                    const SizedBox(height: 12),

                    // حقل كلمة المرور
                    if (!_showOtpField) ...[
                      _buildTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: Icons.lock,
                        obscure: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'كلمة المرور مطلوبة'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) =>
                                _safeSetState(() => _rememberMe = value!),
                            activeColor: Color(0xFF8B0000),
                          ),
                          const Text(
                            'تذكرني',
                            style: TextStyle(color: Colors.black87),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: _resetPassword,
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(color: Color(0xFF8B0000)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],

                    // حقل رمز التحقق
                    if (_showOtpField) ...[
                      _buildOtpField(),
                      const SizedBox(height: 8),

                      // زر إعادة الإرسال مع المؤقت
                      Visibility(
                        visible: _showOtpField,
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 7,
                              children: [
                                Text(
                                  'لم يصلك الرمز؟',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: _isResendEnabled
                                      ? _resendOtp
                                      : null,
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
                            const SizedBox(height: 12),

                            // ✅ زر إضافي للعودة في حالة عدم وصول الرمز
                            TextButton(
                              onPressed: () {
                                _safeSetState(() {
                                  _showOtpField = false;
                                  _otpController.clear();
                                  _isLoading = false;
                                });
                              },
                              child: Text(
                                'لم يصلك الرمز؟ العودة لتسجيل الدخول بكلمة المرور',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],

                    // زر تسجيل الدخول / تحقق من الرمز
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_showOtpField ? _verifyOtp : _loginWithPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _showOtpField ? 'تحقق من الرمز' : 'تسجيل الدخول',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    // زر لتسجيل الدخول بكلمة المرور (بديل)
                    if (_showOtpField) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          _safeSetState(() {
                            _showOtpField = false;
                            _otpController.clear();
                            _verificationId = null;
                            _resendTimerInstance?.cancel();
                            _isResendEnabled = true;
                            _resendTimer = 60;
                          });
                        },
                        child: Text(
                          'تسجيل الدخول بكلمة المرور',
                          style: TextStyle(color: Color(0xFF8B0000)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "ليس لديك حساب؟",
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(color: Color(0xFF8B0000)),
                          ),
                        ),
                      ],
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

  // دالة لبناء حقل رقم الهاتف
  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // زر اختيار الدولة
              InkWell(
                onTap: _showCountryPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCountryFlag,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _selectedCountryCode,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // حقل إدخال الرقم
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _phoneTextController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الهاتف',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      String number = value.replaceAll(RegExp(r'[^\d]'), '');
                      _internationalPhoneNumber =
                          '$_selectedCountryCode$number';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      String cleanNumber = value.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      if (cleanNumber.length < 9) {
                        return 'الرقم يجب أن يكون 9 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // دالة لعرض اختيار الدولة
  void _showCountryPicker() {
    if (!_isMounted()) return;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر الدولة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B0000),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _arabicCountries.length,
                  itemBuilder: (context, index) {
                    String countryCode = _arabicCountries[index];
                    String flag = _getFlag(countryCode);
                    String dialCode = _getDialCode(countryCode);
                    String countryName = _getCountryName(countryCode);

                    return ListTile(
                      leading: Container(
                        width: 40,
                        child: Text(flag, style: TextStyle(fontSize: 24)),
                      ),
                      title: Text(countryName),
                      trailing: Text(
                        dialCode,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        if (_isMounted()) {
                          _safeSetState(() {
                            _selectedCountryCode = dialCode;
                            _selectedCountryFlag = flag;
                            _selectedCountryIso = countryCode;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: Color(0xFF8B0000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة للحصول على علم الدولة
  String _getFlag(String isoCode) {
    Map<String, String> flags = {
      'SA': '🇸🇦',
      'AE': '🇦🇪',
      'QA': '🇶🇦',
      'KW': '🇰🇼',
      'BH': '🇧🇭',
      'OM': '🇴🇲',
      'YE': '🇾🇪',
      'JO': '🇯🇴',
      'LB': '🇱🇧',
      'SY': '🇸🇾',
      'IQ': '🇮🇶',
      'PS': '🇵🇸',
      'EG': '🇪🇬',
      'SD': '🇸🇩',
      'LY': '🇱🇾',
      'TN': '🇹🇳',
      'DZ': '🇩🇿',
      'MA': '🇲🇦',
      'MR': '🇲🇷',
      'SO': '🇸🇴',
      'DJ': '🇩🇯',
      'KM': '🇰🇲',
    };
    return flags[isoCode] ?? '🇺🇳';
  }

  // دالة للحصول على رمز الاتصال
  String _getDialCode(String isoCode) {
    Map<String, String> dialCodes = {
      'SA': '+966',
      'AE': '+971',
      'QA': '+974',
      'KW': '+965',
      'BH': '+973',
      'OM': '+968',
      'YE': '+967',
      'JO': '+962',
      'LB': '+961',
      'SY': '+963',
      'IQ': '+964',
      'PS': '+970',
      'EG': '+20',
      'SD': '+249',
      'LY': '+218',
      'TN': '+216',
      'DZ': '+213',
      'MA': '+212',
      'MR': '+222',
      'SO': '+252',
      'DJ': '+253',
      'KM': '+269',
    };
    return dialCodes[isoCode] ?? '+966';
  }

  // دالة للحصول على اسم الدولة
  String _getCountryName(String isoCode) {
    Map<String, String> names = {
      'SA': 'السعودية',
      'AE': 'الإمارات',
      'QA': 'قطر',
      'KW': 'الكويت',
      'BH': 'البحرين',
      'OM': 'عمان',
      'YE': 'اليمن',
      'JO': 'الأردن',
      'LB': 'لبنان',
      'SY': 'سوريا',
      'IQ': 'العراق',
      'PS': 'فلسطين',
      'EG': 'مصر',
      'SD': 'السودان',
      'LY': 'ليبيا',
      'TN': 'تونس',
      'DZ': 'الجزائر',
      'MA': 'المغرب',
      'MR': 'موريتانيا',
      'SO': 'الصومال',
      'DJ': 'جيبوتي',
      'KM': 'جزر القمر',
    };
    return names[isoCode] ?? 'دولة عربية';
  }

  // دالة لبناء حقل OTP
  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, letterSpacing: 8),
      decoration: InputDecoration(
        labelText: 'رمز التحقق (6 أرقام)',
        labelStyle: TextStyle(color: Colors.black54),
        hintText: '000000',
        counterText: '',
        prefixIcon: Icon(Icons.sms, color: Color(0xFF8B0000)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF8B0000)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رمز التحقق';
        }
        if (value.length != 6) {
          return 'يجب أن يكون رمز التحقق 6 أرقام';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'يجب أن يحتوي على أرقام فقط';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
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
      ),
      validator: validator,
    );
  }

  // تسجيل الدخول باستخدام رقم الهاتف
  Future<void> _loginWithPhone() async {
    if (!_isMounted()) return;

    if (_formKey.currentState!.validate()) {
      // بناء الرقم الدولي
      String phoneNumber = _internationalPhoneNumber;

      if (phoneNumber.isEmpty) {
        String number = _phoneTextController.text.replaceAll(
          RegExp(r'[^\d]'),
          '',
        );
        phoneNumber = '$_selectedCountryCode$number';
      }

      if (phoneNumber.isEmpty || phoneNumber.length < 12) {
        _showErrorDialog('الرجاء إدخال رقم هاتف صحيح');
        return;
      }

      _safeSetState(() => _isLoading = true);

      try {
        // محاولة تسجيل الدخول بكلمة المرور أولاً
        await _tryPasswordLogin(phoneNumber);
      } catch (e) {
        // إذا فشل تسجيل الدخول بكلمة المرور، استخدم OTP
        await _sendOtp(phoneNumber);
      }
    }
  }

  // محاولة تسجيل الدخول بكلمة المرور
  Future<void> _tryPasswordLogin(String phoneNumber) async {
    try {
      // البحث عن المستخدم برقم الهاتف في Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final email = userData['email'];

        if (email != null && email.isNotEmpty) {
          // تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: email,
                password: _passwordController.text.trim(),
              );

          _navigateToHome(userCredential.user);
          return;
        }
      }

      // إذا لم يكن هناك بريد إلكتروني، استخدم OTP
      throw Exception('سجل الدخول برمز التحقق');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // استخدام OTP بدلاً من ذلك
        await _sendOtp(phoneNumber);
      } else {
        throw Exception('فشل تسجيل الدخول: ${e.message}');
      }
    } catch (e) {
      // استخدام OTP بدلاً من ذلك
      await _sendOtp(phoneNumber);
    }
  }

  // إرسال رمز OTP
  Future<void> _sendOtp(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (_isMounted()) {
            _safeSetState(() => _isLoading = false);

            if (e.code == 'too-many-requests') {
              _showErrorDialog('محاولات كثيرة جداً. الرجاء الانتظار قليلاً');
            } else if (e.message?.contains('blocked') ?? false) {
              _showErrorDialog(
                'تم حظر المحاولات مؤقتاً. الرجاء الانتظار 10 دقائق ثم المحاولة مرة أخرى.',
              );
            } else {
              _showErrorDialog('فشل التحقق: ${e.message}');
            }

            // العودة لشاشة إدخال كلمة المرور
            _safeSetState(() {
              _showOtpField = false;
              _otpController.clear();
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (_isMounted()) {
            _safeSetState(() {
              _isLoading = false;
              _verificationId = verificationId;
              _showOtpField = true;
              _startResendTimer();
            });

            // ✅ إظهار رسالة تأكيد للمستخدم
            _showToast('تم إرسال رمز التحقق إلى رقم هاتفك');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // ✅ حدث Timeout - لم تصل الرسالة
          _verificationId = verificationId;

          if (_isMounted() && _showOtpField) {
            _safeSetState(() {
              _isLoading = false;
            });

            // ✅ عرض خيارات للمستخدم
            _showTimeoutDialog();
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showErrorDialog('حدث خطأ غير متوقع: $e');

        // العودة لشاشة إدخال كلمة المرور
        _safeSetState(() {
          _showOtpField = false;
          _otpController.clear();
        });
      }
    }
  }

  // ✅ دالة جديدة لمعالجة Timeout
  void _showTimeoutDialog() {
    if (!_isMounted()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'لم يصلك الرمز؟',
          style: TextStyle(color: Color(0xFF8B0000)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لم نتمكن من إرسال رمز التحقق إلى رقم هاتفك.'),
            const SizedBox(height: 16),
            Text(
              'قد يكون السبب:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• رقم الهاتف غير صحيح'),
            Text('• مشكلة في شبكة الاتصال'),
            Text('• محاولات كثيرة جداً'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // العودة لشاشة إدخال كلمة المرور
              if (_isMounted()) {
                _safeSetState(() {
                  _showOtpField = false;
                  _otpController.clear();
                });
              }
            },
            child: Text('العودة لتسجيل الدخول'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // إعادة المحاولة
              if (_isMounted()) {
                _resendOtp();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B0000)),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // ✅ دالة لعرض Toast بسيط
  void _showToast(String message) {
    if (!_isMounted()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // التحقق من رمز OTP
  Future<void> _verifyOtp() async {
    if (!_isMounted()) return;

    if (_verificationId == null || _otpController.text.isEmpty) {
      _showErrorDialog('الرجاء إدخال رمز التحقق');
      return;
    }

    if (_otpController.text.length != 6) {
      _showErrorDialog('رمز التحقق يجب أن يكون 6 أرقام');
      return;
    }

    _safeSetState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        if (e.code == 'invalid-verification-code') {
          _showErrorDialog('رمز التحقق غير صحيح');
        } else {
          _showErrorDialog('فشل التحقق: ${e.message}');
        }
      }
    } catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showErrorDialog('حدث خطأ أثناء التحقق');
      }
    }
  }

  // تسجيل الدخول باستخدام credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      _navigateToHome(userCredential.user);
    } catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showErrorDialog('فشل تسجيل الدخول: $e');
      }
    }
  }

  // إعادة تعيين كلمة المرور باستخدام OTP (للحسابات المسجلة برقم الهاتف)
  Future<void> _resetPassword() async {
    if (!_isMounted()) return;

    // التحقق من إدخال رقم الهاتف أولاً
    if (_phoneTextController.text.isEmpty) {
      _showErrorDialog('الرجاء إدخال رقم الهاتف أولاً');
      return;
    }

    // بناء الرقم الكامل
    String phoneNumber = _internationalPhoneNumber;
    if (phoneNumber.isEmpty) {
      String number = _phoneTextController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      phoneNumber = '$_selectedCountryCode$number';
    }

    if (phoneNumber.isEmpty || phoneNumber.length < 12) {
      _showErrorDialog('الرجاء إدخال رقم هاتف صحيح');
      return;
    }

    _safeSetState(() => _isLoading = true);

    try {
      // ✅ مباشرة إرسال OTP - بدون الحاجة لقراءة Firestore
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (_isMounted()) {
              _safeSetState(() => _isLoading = false);
              _showNewPasswordSheet();
            }
          } catch (e) {
            if (_isMounted()) {
              _safeSetState(() => _isLoading = false);
              _showErrorDialog('خطأ في تسجيل الدخول');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (_isMounted()) {
            _safeSetState(() => _isLoading = false);
            _showErrorDialog('فشل التحقق: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (_isMounted()) {
            _safeSetState(() {
              _isLoading = false;
              _verificationId = verificationId;
            });
            _showOtpResetSheet(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showErrorDialog('حدث خطأ: $e');
      }
    }
  }

  // ✅ دالة لعرض BottomSheet لإدخال OTP
  void _showOtpResetSheet(String verificationId) {
    if (!_isMounted()) return;

    final TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إعادة تعيين كلمة المرور',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 16),
            Text('تم إرسال رمز التحقق إلى رقم هاتفك'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'رمز التحقق (6 أرقام)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.sms, color: Color(0xFF8B0000)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (otpController.text.length == 6) {
                        Navigator.pop(sheetContext);
                        await _verifyOtpAndResetPasswordSheet(
                          verificationId,
                          otpController.text,
                        );
                      } else {
                        if (_isMounted()) {
                          _showErrorDialog('الرجاء إدخال رمز التحقق كاملاً');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000),
                    ),
                    child: const Text('تحقق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة للتحقق من OTP وإظهار BottomSheet لكلمة المرور الجديدة
  Future<void> _verifyOtpAndResetPasswordSheet(
    String verificationId,
    String smsCode,
  ) async {
    if (!_isMounted()) return;

    _safeSetState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null && _isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showNewPasswordSheet();
      }
    } catch (e) {
      if (_isMounted()) {
        _safeSetState(() => _isLoading = false);
        _showErrorDialog('رمز التحقق غير صحيح');
      }
    }
  }

  // ✅ دالة لعرض BottomSheet لإدخال كلمة مرور جديدة
  void _showNewPasswordSheet() {
    if (!_isMounted()) return;

    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كلمة مرور جديدة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF8B0000)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8B0000)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // التحقق من صحة المدخلات
                      if (newPasswordController.text.isEmpty) {
                        if (_isMounted()) {
                          _showErrorDialog('الرجاء إدخال كلمة المرور');
                        }
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        if (_isMounted()) {
                          _showErrorDialog('كلمتا المرور غير متطابقتين');
                        }
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        if (_isMounted()) {
                          _showErrorDialog(
                            'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                          );
                        }
                        return;
                      }

                      Navigator.pop(sheetContext);

                      if (!_isMounted()) return;
                      _safeSetState(() => _isLoading = true);

                      try {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await user.updatePassword(newPasswordController.text);

                          if (_isMounted()) {
                            _safeSetState(() => _isLoading = false);
                            _showSuccessDialog('تم تحديث كلمة المرور بنجاح');
                          }
                        }
                      } catch (e) {
                        if (_isMounted()) {
                          _safeSetState(() => _isLoading = false);
                          _showErrorDialog('فشل تحديث كلمة المرور: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000),
                    ),
                    child: const Text('تحديث'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startResendTimer() {
    _isResendEnabled = false;
    _resendTimer = 60;

    // إلغاء المؤقت السابق إذا كان موجوداً
    _resendTimerInstance?.cancel();

    _resendTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMounted()) {
        if (_resendTimer > 0) {
          _safeSetState(() => _resendTimer--);
        } else {
          timer.cancel();
          _safeSetState(() => _isResendEnabled = true);
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_isResendEnabled && _isMounted()) {
      // إعادة تعيين المؤقت
      _resendTimerInstance?.cancel();
      _safeSetState(() {
        _isResendEnabled = false;
        _resendTimer = 60;
      });

      // إعادة الإرسال
      await _loginWithPhone();
    }
  }

  void _navigateToHome(User? user) {
    if (user != null && _isMounted()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainLayout()),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (!_isMounted()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!_isMounted()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('✅ تم بنجاح', style: TextStyle(color: Color(0xFF8B0000))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // إغلاق الـ Dialog

              // ✅ الانتقال للصفحة الرئيسية
              if (_isMounted()) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainLayout()),
                );
              }
            },
            child: Text('موافق', style: TextStyle(color: Color(0xFF8B0000))),
          ),
        ],
      ),
    );
  }
}
