import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_app_bar.dart';
import '../services/auth_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _contactEmail = "support@mehndidesigns.com";
  String? _contactPhone = "+91 1234567890";
  String? _contactAddress = "123 Mehndi Street, Design City, India";

  @override
  void initState() {
    super.initState();
    _fetchContactDetails();
  }

  Future<void> _fetchContactDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authService.getContactUs();
      if (data != null && data['status'] == true) {
        // Assuming the API might return these fields, otherwise using fallbacks
        // If the description contains the info, we could parse it, but usually
        // there are specific fields or we just show the fallback.
      }
    } catch (e) {
      print("Error fetching contact detail: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _authService.submitContactForm(
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        subject: _subjectController.text,
        message: _messageController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Message sent successfully!'),
            backgroundColor: result['status'] == true
                ? Colors.green
                : Colors.red,
          ),
        );
        if (result['status'] == true) {
          _nameController.clear();
          _emailController.clear();
          _mobileController.clear();
          _subjectController.clear();
          _messageController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Contact Us',
        showNotification: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInfo(),
                  const SizedBox(height: 30),
                  Text(
                    'Send us a message',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE28127).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE28127).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.email_outlined, 'Email', _contactEmail!),
          const Divider(height: 30),
          _buildInfoItem(Icons.phone_outlined, 'Phone', _contactPhone!),
          const Divider(height: 30),
          _buildInfoItem(
            Icons.location_on_outlined,
            'Address',
            _contactAddress!,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE28127).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFE28127), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Your Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Your Email',
            hint: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your email';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _mobileController,
            label: 'Mobile',
            hint: 'Enter your mobile number',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter mobile number'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _subjectController,
            label: 'Subject',
            hint: 'What is this regarding?',
            icon: Icons.subject,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a subject'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _messageController,
            label: 'Message',
            hint: 'Type your message here...',
            icon: Icons.message_outlined,
            maxLines: 4,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your message'
                : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE28127),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Send Message',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey),
            prefixIcon: Icon(icon, color: const Color(0xFFE28127), size: 22),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE28127),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
