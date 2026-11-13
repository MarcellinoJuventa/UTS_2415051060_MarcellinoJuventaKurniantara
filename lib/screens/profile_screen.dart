import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';

/// Screen 7: Profile & About Barista Screen
/// Menampilkan identitas mahasiswa, informasi arsitektur aplikasi North,
/// serta sumber integrasi REST API dan Supabase Database.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person_outline, size: 22),
            SizedBox(width: 10),
            Text(
              'Head Barista & App Info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu Identitas Mahasiswa
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryEspresso,
                        Color(0xFF4A3228),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryEspresso.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppTheme.warmCaramel.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.warmCaramel,
                            width: 2.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'MJ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppConfig.studentName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NIM: ${AppConfig.studentNim}  •  Kelas: ${AppConfig.studentClass}',
                          style: TextStyle(
                            color: AppTheme.softLatte,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Project Ujian Tengah Semester — Pemrograman Mobile\nDosen Pengampu: Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tentang Aplikasi North
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.coffee_rounded,
                                color: AppTheme.accentRoast),
                            SizedBox(width: 10),
                            Text(
                              'Tentang Aplikasi North',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryEspresso,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          'North adalah aplikasi Specialty Coffee Bar Catalog & Tasting Log yang membantu penikmat kopi dan barista mengeksplorasi resep minuman kopi bar (Hot & Iced Coffee) melalui REST API publik, sekaligus mencatat jurnal racikan pribadi, tingkat kemanisan, rating, dan wishlist kopi ke dalam database cloud Supabase (PostgreSQL).',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            height: 1.55,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spesifikasi Arsitektur & Integrasi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.layers_outlined,
                                color: AppTheme.accentRoast),
                            SizedBox(width: 10),
                            Text(
                              'Arsitektur & Tech Stack',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryEspresso,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.account_tree_outlined,
                          'Layered Architecture',
                          'UI (Screens/Widgets) → Provider (ChangeNotifier) → Repository → Service → REST API & Supabase',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.cloud_download_outlined,
                          'REST API (GET Catalog)',
                          'SampleAPIs Coffee Endpoint (/coffee/hot & /coffee/iced)',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.storage_rounded,
                          'Backend Database (CRUD)',
                          'Supabase PostgreSQL — Tabel public.coffee_logs (Create, Read, Update, Delete)',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.devices_rounded,
                          'Responsive Layout',
                          'MediaQuery & LayoutBuilder (Compact < 600px & Wide/Expanded ≥ 600px)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.softLatte,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryEspresso),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
