import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ for date formatting

class MyBioScreen extends StatefulWidget {
  const MyBioScreen({super.key});

  @override
  State<MyBioScreen> createState() => _MyBioScreenState();
}

class _MyBioScreenState extends State<MyBioScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Bhargavi',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+91 9234657898',
  );
  final TextEditingController _genderController = TextEditingController(
    text: 'Female',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'Hyderabad, Telangana',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '15 Mar 1999',
  );

  bool _isNameEditable = false;
  bool _isPhoneEditable = false;
  bool _isGenderEditable = false;
  bool _isAddressEditable = false;

  String? _nameError;
  String? _phoneError;

  // ✅ Date of Birth Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999, 3, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD5A021), // golden highlight
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFD5A021), // button color
              ),
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

  // Validation
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

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellowAccent, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Profile Avatar
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
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://via.placeholder.com/150x150.png?text=User',
                        ),
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
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _validateName(_nameController.text);
                    _validatePhone(_phoneController.text);

                    if (_nameError == null && _phoneError == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile saved successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fix the errors before saving'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5A021),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                  child: const Text(
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
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFFD5A021),
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
