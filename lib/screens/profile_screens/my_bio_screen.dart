import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:real_beez/screens/api/profile_service.dart';
import 'package:real_beez/screens/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBioScreen(),
    );
  }
}

class MyBioScreen extends StatefulWidget {
  const MyBioScreen({super.key});

  @override
  State<MyBioScreen> createState() => _MyBioScreenState();
}

class _MyBioScreenState extends State<MyBioScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isNameEditable = false;
  bool _isPhoneEditable = false;
  bool _isGenderEditable = false;
  bool _isAddressEditable = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _nameError;
  String? _phoneError;

  ProfileModel? _currentProfile;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
    _loadDataFromSharedPreferences();
  }

  Future<void> _loadDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('fullName');
    final savedGender = prefs.getString('gender');
    final savedDob = prefs.getString('dob');

    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }

    if (savedGender != null && savedGender.isNotEmpty) {
      _genderController.text =
          savedGender[0].toUpperCase() + savedGender.substring(1);
    }

    if (savedDob != null && savedDob.isNotEmpty) {
      try {
        final parts = savedDob.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? 1999;
          final date = DateTime(year, month, day);
          _dobController.text = DateFormat('dd MMM yyyy').format(date);
        } else {
          _dobController.text = savedDob;
        }
      } catch (e) {
        _dobController.text = savedDob;
      }
    }
  }

  Future<void> _fetchProfiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await ProfileService.getProfiles();
      final List<ProfileModel> profiles = response.map<ProfileModel>((profile) {
        return ProfileModel.fromJson(profile);
      }).toList();

      setState(() {
        if (profiles.isNotEmpty) {
          _currentProfile = profiles.first;
          _populateFormData(_currentProfile!);
        } else {
          _setDefaultData();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile data: $e'),
          backgroundColor: Colors.orange,
        ),
      );

      _setDefaultData();
    }
  }

  void _populateFormData(ProfileModel profile) {
    if (_nameController.text.isEmpty && profile.name.isNotEmpty) {
      _nameController.text = profile.name;
    }

    if (_phoneController.text.isEmpty && profile.phone.isNotEmpty) {
      _phoneController.text = profile.phone;
    }

    if (_genderController.text.isEmpty && profile.gender.isNotEmpty) {
      _genderController.text = profile.gender;
    }

    if (_addressController.text.isEmpty && profile.address.isNotEmpty) {
      _addressController.text = profile.address;
    }

    if (_dobController.text.isEmpty) {
      final formattedDob = _formatDateForDisplay(profile.dateOfBirth);
      _dobController.text = formattedDob.isNotEmpty
          ? formattedDob
          : '15 Mar 1999';
    }
  }

  void _setDefaultData() {
    if (_nameController.text.isEmpty) {
      _nameController.text = 'Bhargavi';
    }

    if (_phoneController.text.isEmpty) {
      _phoneController.text = '+91 9234657898';
    }

    if (_genderController.text.isEmpty) {
      _genderController.text = 'Female';
    }

    if (_addressController.text.isEmpty) {
      _addressController.text = 'Hyderabad, Telangana';
    }

    if (_dobController.text.isEmpty) {
      _dobController.text = '15 Mar 1999';
    }
  }

  String _formatDateForDisplay(String dateString) {
    try {
      if (dateString.isEmpty) return '';

      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]) ?? 1999;
          final month = int.tryParse(parts[1]) ?? 3;
          final day = int.tryParse(parts[2]) ?? 15;
          final date = DateTime(year, month, day);
          return DateFormat('dd MMM yyyy').format(date);
        }
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateForAPI(String displayDate) {
    try {
      if (displayDate.isEmpty) return '';

      final date = DateFormat('dd MMM yyyy').parse(displayDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return displayDate;
    }
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.tryParse(url);
      return uri != null &&
          uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      if (_dobController.text.isNotEmpty) {
        initialDate = DateFormat('dd MMM yyyy').parse(_dobController.text);
      } else {
        initialDate = DateTime(1999, 3, 15);
      }
    } catch (e) {
      initialDate = DateTime(1999, 3, 15);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD5A021),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFD5A021)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _validateName(String value) {
    if (value.isEmpty) {
      setState(() => _nameError = 'Name is required');
    } else if (value.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters long');
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      setState(() => _nameError = 'Name can only contain letters and spaces');
    } else {
      setState(() => _nameError = null);
    }
  }

  void _validatePhone(String value) {
    String cleanedPhone = value.replaceAll(RegExp(r'\s+'), '');
    if (cleanedPhone.isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
    } else if (!RegExp(r'^[\+]?[0-9\s\-\(\)]{10,15}$').hasMatch(value)) {
      setState(() => _phoneError = 'Please enter a valid phone number');
    } else if (cleanedPhone.length < 10) {
      setState(() => _phoneError = 'Phone number must be at least 10 digits');
    } else {
      setState(() => _phoneError = null);
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    _validateName(_nameController.text);
    _validatePhone(_phoneController.text);

    if (_nameError != null || _phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before saving'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'gender': _genderController.text,
        'address': _addressController.text,
        'date_of_birth': _formatDateForAPI(_dobController.text),
        'image_url': _currentProfile?.imageUrl ?? '',
      };

      Map<String, dynamic> result;

      if (_currentProfile != null && _currentProfile!.id.isNotEmpty) {
        result = await ProfileService.updateProfile(
          _currentProfile!.id,
          profileData,
        );

        if (!result["success"]) {
          result = await ProfileService.createProfile(profileData);
        }
      } else {
        result = await ProfileService.createProfile(profileData);
      }

      if (result["success"] == true) {
        // ✅ SAVE UPDATED DATA TO SHAREDPREFERENCES
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', _nameController.text);

        // Save gender to SharedPreferences (convert to lowercase for consistency)
        final genderLower = _genderController.text.toLowerCase();
        await prefs.setString('gender', genderLower);

        // Save date of birth to SharedPreferences
        if (_dobController.text.isNotEmpty) {
          try {
            final date = DateFormat('dd MMM yyyy').parse(_dobController.text);
            final formattedDob = '${date.day}/${date.month}/${date.year}';
            await prefs.setString('dob', formattedDob);
          } catch (e) {
            // If parsing fails, save as-is
            await prefs.setString('dob', _dobController.text);
          }
        }

        // Refresh profile data
        await _fetchProfiles();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? 'Profile saved successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // Reset edit modes
        setState(() {
          _isNameEditable = false;
          _isPhoneEditable = false;
          _isGenderEditable = false;
          _isAddressEditable = false;
        });

        // ✅ NOTIFY PARENT/PREVIOUS SCREENS THAT DATA HAS BEEN UPDATED
        // This will update the ProfileSettingsScreen automatically
        Navigator.pop(context, {
          'nameUpdated': true,
          'newName': _nameController.text,
          'newGender': genderLower,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? 'Failed to save profile'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF2DD),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD5A021)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF2DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF2DD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Bio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.grey[200],
                    ),
                    child: ClipOval(
                      child:
                          _currentProfile != null &&
                              _currentProfile!.imageUrl.isNotEmpty &&
                              _isValidImageUrl(_currentProfile!.imageUrl)
                          ? Image.network(
                              _currentProfile!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFD5A021),
                                            ),
                                      ),
                                    );
                                  },
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('Name:'),
            _buildEditableField(
              controller: _nameController,
              isEditable: _isNameEditable,
              errorText: _nameError,
              onEditPressed: () {
                setState(() {
                  _isNameEditable = !_isNameEditable;
                  if (!_isNameEditable) _validateName(_nameController.text);
                });
              },
              onChanged: _validateName,
            ),

            const SizedBox(height: 18),

            _buildLabel('Phone Number:'),
            _buildEditableField(
              controller: _phoneController,
              isEditable: _isPhoneEditable,
              errorText: _phoneError,
              keyboardType: TextInputType.phone,
              onEditPressed: () {
                setState(() {
                  _isPhoneEditable = !_isPhoneEditable;
                  if (!_isPhoneEditable) _validatePhone(_phoneController.text);
                });
              },
              onChanged: _validatePhone,
            ),

            const SizedBox(height: 18),

            _buildLabel('Gender:'),
            _buildEditableField(
              controller: _genderController,
              isEditable: _isGenderEditable,
              onEditPressed: () {
                setState(() => _isGenderEditable = !_isGenderEditable);
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Address:'),
            _buildEditableField(
              controller: _addressController,
              isEditable: _isAddressEditable,
              onEditPressed: () {
                setState(() => _isAddressEditable = !_isAddressEditable);
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Date of Birth:'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildEditableField(
                  controller: _dobController,
                  isEditable: true,
                  onEditPressed: () => _selectDate(context),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5A021),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEditPressed,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: isEditable,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
              IconButton(
                icon: Icon(
                  isEditable ? Icons.check : Icons.edit,
                  size: 18,
                  color: const Color(0xFFD5A021),
                ),
                onPressed: onEditPressed,
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
