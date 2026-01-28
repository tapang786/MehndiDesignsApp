import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_drawer.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Pratiksha Singh',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'pratiksha@example.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+91 98765 43210',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '2000-01-01',
  );
  final TextEditingController _professionController = TextEditingController(
    text: 'Mehndi Artist',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'Mumbai, India',
  );
  final TextEditingController _bioController = TextEditingController(
    text: 'Passionate about mehndi designs and creating beautiful art.',
  );

  String _selectedGender = 'Female';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE28127),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Image Section
            Center(
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
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Color(0xFFE28127),
                      ),
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
            const SizedBox(height: 32),

            // Form Fields
            _buildTextField('Full Name', _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(
              'Email Address',
              _emailController,
              Icons.email_outlined,
              isReadOnly: true,
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
                onPressed: () {},
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
              value: _selectedGender,
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
                    _selectedGender = value;
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
