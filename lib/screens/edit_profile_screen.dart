import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  String? gender; // ✅ null = shows "Gender"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// TITLE
            const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF142752),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage how your profile appears\nin Budgee",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// PROFILE IMAGE
            Stack(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFF9ADCF4),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.black54,
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF142752),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// PERSONAL DETAILS
            _sectionTitle("Personal Details"),

            const SizedBox(height: 12),

            _inputField(
              controller: nameCtrl,
              hint: "Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                /// GENDER
                Expanded(child: _genderDropdown()),

                const SizedBox(width: 12),

                /// DOB
                Expanded(child: _dateField()),
              ],
            ),

            const SizedBox(height: 25),

            /// ACCOUNT DETAILS
            _sectionTitle("Account Details"),

            const SizedBox(height: 12),

            _inputField(
              controller: emailCtrl,
              hint: "Email ID",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF142752),
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

  // ---------------- HELPERS ----------------

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF142752),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: const Color(0xFFE8EEFF),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ GENDER FIELD (DEFAULT = "Gender" + GENERAL ICON)
  Widget _genderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          const Icon(Icons.wc, color: Colors.grey), // general gender icon

          const SizedBox(width: 10),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: gender,

                hint: const Text(
                  "Gender",
                  style: TextStyle(color: Colors.grey),
                ),

                isExpanded: true,

                items: const [
                  DropdownMenuItem(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem(
                    value: "Female",
                    child: Text("Female"),
                  ),
                  DropdownMenuItem(
                    value: "Other",
                    child: Text("Other"),
                  ),
                ],

                onChanged: (val) {
                  setState(() => gender = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    return TextField(
      controller: dobCtrl,
      readOnly: true,

      decoration: InputDecoration(
        hintText: "DOB",

        suffixIcon: const Icon(Icons.calendar_today),

        filled: true,
        fillColor: const Color(0xFFE8EEFF),

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

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );

    Navigator.pop(context);
  }
}
