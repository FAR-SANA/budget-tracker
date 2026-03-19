import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  String? gender;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    if (!mounted) return;

    setState(() {
      nameCtrl.text = data['name'] ?? '';
      gender = data['gender'];
      emailCtrl.text = user.email ?? '';

      if (data['dob'] != null) {
        final d = DateTime.parse(data['dob']);
        dobCtrl.text = "${d.day}/${d.month}/${d.year}";
      }
    });
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 🔐 Update email (Auth)
      if (emailCtrl.text.trim() != user.email) {
        await _supabase.auth.updateUser(
          UserAttributes(email: emailCtrl.text.trim()),
        );
      }

      // 🧠 Build update map safely
      final updates = {
        'name': nameCtrl.text.trim(),
        'gender': gender, // can be null
      };

      if (dobCtrl.text.isNotEmpty) {
        updates['dob'] = _parseDate(
          dobCtrl.text,
        ).toIso8601String(); // 🔥 important
      } else {
        updates['dob'] = null;
      }

      // 👤 Update database
      await _supabase.from('users').update(updates).eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    }
  }

  DateTime _parseDate(String value) {
    final parts = value.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage how your profile appears\nin Budgee",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _inputField(
              controller: nameCtrl,
              hint: "Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _genderDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _dateField()),
              ],
            ),

            const SizedBox(height: 25),

            _inputField(
              controller: emailCtrl,
              hint: "Email",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.text(context)), // ✅ ADD
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.subText(context)),
        prefixIcon: Icon(icon, color: AppColors.text(context)),
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.incomeCard(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: gender,
          hint: Text(
            "Gender",
            style: TextStyle(color: AppColors.subText(context)),
          ),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (val) => setState(() => gender = val),
        ),
      ),
    );
  }

  Widget _dateField() {
    return TextField(
      controller: dobCtrl,
      readOnly: true,
      style: TextStyle(color: AppColors.text(context)), // ✅ ADD
      decoration: InputDecoration(
        hintText: "DOB",
        hintStyle: TextStyle(color: AppColors.subText(context)),
        suffixIcon: Icon(Icons.calendar_today, color: AppColors.text(context)),
        filled: true,
        fillColor: AppColors.incomeCard(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: _pickDate,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
}
