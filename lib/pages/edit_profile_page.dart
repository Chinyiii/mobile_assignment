import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_assignment/auth/auth_service.dart';
import 'package:mobile_assignment/main.dart';
import '../services/supabase_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final authService = AuthService();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController(); // controller for email
  final addressController = TextEditingController(); // new controller for address

  String? base64Image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final email = authService.getCurrentUserEmail();
    if (email == null) return;

    final response = await supabase
        .from('users')
        .select('name, phone_number, address, profile_pic') // include address
        .eq('email', email as Object)
        .maybeSingle();

    if (mounted) {
      setState(() {
        emailController.text = email; // set email into controller
        nameController.text = response?['name'] ?? '';
        phoneController.text = response?['phone_number'] ?? '';
        addressController.text = response?['address'] ?? ''; // set address
        base64Image = response?['profile_pic'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveProfile() async {
    final email = emailController.text;
    if (email.isEmpty) return;

    await supabase.from('users').update({
      'name': nameController.text,
      'phone_number': phoneController.text,
      'address': addressController.text, // save address
      'profile_pic': base64Image,
    }).eq('email', email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        bytes = base64Decode(base64Image!);
      } catch (_) {
        bytes = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: bytes != null
                      ? MemoryImage(bytes)
                      : const AssetImage("assets/images/default_avatar.png")
                  as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),

              // Email (uneditable)
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),

              // Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),

              // Phone
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              // Address
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
