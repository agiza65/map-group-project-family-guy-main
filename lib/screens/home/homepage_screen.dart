import 'package:flutter/material.dart';
import 'package:Care_Plus/screens/profile/profile_screen.dart' as profile_page;
import '../appointment/appointment_list_page.dart';
import 'package:Care_Plus/screens/document/document_screen.dart';
import 'package:Care_Plus/screens/relative/chat.dart';
import 'package:Care_Plus/screens/home/old_homepage_screen.dart';
import 'package:Care_Plus/widgets/action_button.dart';

/// 主页内容，仅作为 MainScaffold 的 body
class HomepageScreen extends StatelessWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> quickSendList = [
      {'name': 'son', 'image': 'assets/images/man.png'},
    ];

    final List<Map<String, dynamic>> appointmentList = [
      {
        'icon': Icons.medication_outlined,
        'label': 'Medicine Reminder',
        'amount': '',
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Doctor Appointment',
        'amount': '12 Oct, 10:00 AM',
      },
      {
        'icon': Icons.local_hospital,
        'label': 'Clinic Visit',
        'amount': '15 Oct, 3:00 PM',
      },
      {
        'icon': Icons.phone_in_talk,
        'label': 'Call Caregiver',
        'amount': 'Pending',
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const profile_page.ProfileScreen(),
                            ),
                          ),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/senior_profile.png',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Mr john doe", style: TextStyle(fontSize: 16)),
                        Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.notifications, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black87,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          'assets/images/senior_profile.png',
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Mr. John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Age: 67',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Phone: +60 12-345 6789',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Email: john.doe@email.com',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionButton(
                  icon: Icons.send,
                  label: 'Appointment',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentListPage(),
                        ),
                      ),
                ),
                ActionButton(
                  icon: Icons.receipt_long,
                  label: 'Documents',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HealthDataPage(),
                        ),
                      ),
                ),
                ActionButton(
                  icon: Icons.phone_android,
                  label: 'Relative',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const ChatPage(
                                name: 'son',
                                imagePath: 'assets/images/man.png',
                              ),
                        ),
                      ),
                ),
                ActionButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  highlight: true,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OldHomepageScreen()),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Send
            const Text(
              "Quick Send",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    quickSendList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(item['image']!),
                            ),
                            const SizedBox(height: 5),
                            Text(item['name']!),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Appointments
            const Text(
              "Recent Appointment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children:
                  appointmentList.map((activity) {
                    return ListTile(
                      leading: Icon(activity['icon'], color: Colors.black54),
                      title: Text(activity['label']),
                      trailing: Text(
                        activity['amount'],
                        style: TextStyle(
                          color:
                              activity['amount'].toString().startsWith(
                                    'Pending',
                                  )
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
