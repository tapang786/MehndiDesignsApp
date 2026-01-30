import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/common_app_bar.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  File? _imageFile;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _loadUserData() async {
    final User? user = await _authService.getUser();
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _bioController.text = user.bio ?? "";
        _professionController.text = user.profession ?? "";
        _dobController.text = user.dob ?? "";
        if (user.gender != null) {
          String normalizedGender =
              user.gender!.substring(0, 1).toUpperCase() +
              user.gender!.substring(1).toLowerCase();
          if (['Male', 'Female', 'Other'].contains(normalizedGender)) {
            gender = normalizedGender;
          }
        }
        _profileImageUrl = user.profileImage;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      gender: gender.toLowerCase(),
      bio: _bioController.text,
      profession: _professionController.text,
      address: _addressController.text,
      dob: _dobController.text,
      image: _imageFile,
    );

    setState(() => _isLoading = false);

    if (result['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  String gender = 'Female';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'My Profile', showNotification: false),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile Image Section
                  Center(
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(60),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE28127),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_profileImageUrl != null
                                        ? NetworkImage(_profileImageUrl!)
                                              as ImageProvider
                                        : null),
                              child:
                                  _imageFile == null && _profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Color(0xFFE28127),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE28127),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildTextField(
                    'Full Name',
                    _nameController,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Email Address',
                    _emailController,
                    Icons.email_outlined,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Password (Leave blank to keep current)',
                    _passwordController,
                    Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),
                  _buildTextField(
                    'Phone Number',
                    _phoneController,
                    Icons.phone_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderDropdown(),
                  const SizedBox(height: 20),
                  _buildDatePicker('Date of Birth', _dobController),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Profession',
                    _professionController,
                    Icons.work_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Address',
                    _addressController,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Bio',
                    _bioController,
                    Icons.info_outline,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 40),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE28127),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Update Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool isReadOnly = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.grey[100] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly,
            obscureText: isPassword,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: isReadOnly ? Colors.black54 : Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: maxLines == 1
                  ? Icon(
                      icon,
                      color: isReadOnly ? Colors.grey : const Color(0xFFE28127),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        bottom: 60,
                        left: 12,
                        right: 12,
                      ),
                      child: Icon(
                        icon,
                        color: isReadOnly
                            ? Colors.grey
                            : const Color(0xFFE28127),
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFE28127),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              setState(() {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFE28127)),
                const SizedBox(width: 12),
                Text(
                  controller.text.isEmpty ? 'Select Date' : controller.text,
                  style: GoogleFonts.outfit(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gender,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE28127)),
              items: ['Female', 'Male', 'Other']
                  .map(
                    (gender) => DropdownMenuItem(
                      value: gender,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: Color(0xFFE28127),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(gender, style: GoogleFonts.outfit(fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    gender = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
