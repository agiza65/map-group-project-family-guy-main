import 'package:flutter/material.dart';
import 'package:Care_Plus/screens/document/document_screen.dart';
import 'package:Care_Plus/screens/profile/profile_screen.dart' as profile_page;
import '../appointment/appointment_list_page.dart';
import 'package:Care_Plus/screens/relative/chat.dart';


class HomepageScreen extends StatelessWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => profile_page.ProfileScreen(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/senior_profile.png'),
            ),
          ),
        ),
        title: const Text(
          'Good Morning, John',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.black54,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black54,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Search health tips, doctors...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                    context, Icons.calendar_today, 'Appointments', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentListPage(),
                    ),
                  );
                }),
                _buildActionCard(
                    context, Icons.medication_outlined, 'Medication', () {
                  // TODO: navigate to medication log
                }),
                _buildActionCard(
                    context, Icons.receipt_long, 'Documents', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HealthDataPage(),
                    ),
                  );
                }),
                _buildActionCard(context, Icons.phone_in_talk, 'Chat', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        name: 'son',
                        imagePath: 'assets/images/man.png',
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 25),
            // Health Stats Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Health Stats',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 6,
                  ),
                  SizedBox(height: 10),
                  Text('Daily Step Goal: 7,000 / 10,000'),
                  SizedBox(height: 10),
                  Text('Water Intake: 1.5L / 2L'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Upcoming Events
            const Text(
              'Upcoming',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildListTile(Icons.local_hospital, 'Clinic Visit', '15 Oct, 3:00 PM'),
                _buildListTile(Icons.calendar_today, 'Doctor Appointment', '12 Oct, 10:00 AM'),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }
}
