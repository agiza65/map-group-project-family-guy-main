import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuardian;
  const ProfileScreen({Key? key, this.isGuardian = false}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/profile/edit',
      arguments: {'isGuardian': widget.isGuardian},
    );
  }

  void _unlink(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Unlink"),
        content: Text("Are you sure you want to unlink from $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Unlink"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You have unlinked from $name. A notification was sent.",
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Widget _sectionCard({required Widget child, double? width}) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(
    String title,
    List<String> items,
    double titleSize,
    double itemSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
            color: Colors.teal.shade900,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "• $item",
              style: TextStyle(
                fontSize: itemSize,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double titleFontSize = isSmallScreen ? 18 : 22;
    final double subtitleFontSize = isSmallScreen ? 14 : 18;
    final double infoFontSize = isSmallScreen ? 16 : 20;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.teal.shade50,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize + 4,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editProfile(context),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundImage:
                    const AssetImage('assets/images/senior_profile.png'),
              ),
              const SizedBox(height: 20),
              Text(
                "John Doe",
                style: TextStyle(
                  fontSize: titleFontSize + 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Age: 65",
                      style: TextStyle(
                          color: Colors.teal.shade800,
                          fontSize: subtitleFontSize)),
                  const SizedBox(width: 20),
                  Text("Height: 170 cm",
                      style: TextStyle(
                          color: Colors.teal.shade800,
                          fontSize: subtitleFontSize)),
                  const SizedBox(width: 20),
                  Text("Weight: 65 kg",
                      style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: subtitleFontSize)),
                ],
              ),
              const SizedBox(height: 28),
              _sectionCard(
                width: screenWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Email", "john.doe@example.com", infoFontSize),
                    _infoRow("Phone", "+60123456789", infoFontSize),
                    _infoRow("IC/Passport", "A1234567", infoFontSize),
                  ],
                ),
              ),
              _sectionCard(
                width: screenWidth * 0.9,
                child: _infoBlock(
                  "Allergies",
                  ["Penicillin", "Peanuts"],
                  titleFontSize,
                  infoFontSize,
                ),
              ),
              _sectionCard(
                width: screenWidth * 0.9,
                child: _infoBlock(
                  "Medical History",
                  ["Diabetes", "Hypertension"],
                  titleFontSize,
                  infoFontSize,
                ),
              ),
              _sectionCard(
                width: screenWidth * 0.9,
                child: _infoBlock(
                  "Insurance & Family Doctor",
                  [
                    "Insurance: HealthPlus Basic",
                    "Family Doctor: Dr. Lee Cheng",
                  ],
                  titleFontSize,
                  infoFontSize,
                ),
              ),
              _sectionCard(
                width: screenWidth * 0.9,
                child: _infoBlock(
                  "Emergency Contact",
                  ["Jane Smith (+60198765432)"],
                  titleFontSize,
                  infoFontSize,
                ),
              ),
              const SizedBox(height: 18),
              if (widget.isGuardian)
                _sectionCard(
                  width: screenWidth * 0.9,
                  child: ListTile(
                    title: Text("Grandma Mary",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: infoFontSize)),
                    subtitle: Text("mary.senior@careplus.com",
                        style: TextStyle(fontSize: infoFontSize - 2)),
                    trailing: IconButton(
                      icon: Icon(Icons.link_off,
                          color: Colors.red.shade400,
                          size: infoFontSize + 4),
                      onPressed: () => _unlink(context, "Grandma Mary"),
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Guardian: Jane Smith",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize + 2,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ✅ Logout Button with Confirmation
              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content:
                          const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You have been logged out."),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
