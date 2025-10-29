import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uts_naufal/pages/jadwal_page.dart';
import 'package:uts_naufal/pages/mahasiswa_page.dart';
import 'package:uts_naufal/pages/nilai_page.dart';
import 'package:uts_naufal/login.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _pengumuman = [];
  Map<String, dynamic>? _mahasiswa;
  List<dynamic> _nilaiMahasiswa = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final dashboardData = jsonDecode(
          await rootBundle.loadString('assets/json/dashboard_kuliah.json'))[0];
      setState(() {
        _pengumuman = dashboardData['pengumuman'];
      });

      if (!(widget.user['isAdmin'] ?? false)) {
        final mahasiswaData = jsonDecode(
            await rootBundle.loadString('assets/json/data_mahasiswa.json'));

        final userNim = widget.user['nim'];
        final mahasiswa = mahasiswaData.firstWhere(
          (m) => m['nim'] == userNim,
          orElse: () => {},
        );

        setState(() {
          _mahasiswa = Map<String, dynamic>.from(mahasiswa);
          _nilaiMahasiswa = _mahasiswa!.isNotEmpty
              ? List<Map<String, dynamic>>.from(_mahasiswa!['penilaian'])
              : [];
        });
      }
    } catch (e) {
      print('Gagal memuat data: $e');
      setState(() {
        _pengumuman = [
          {"judul": "Error", "isi": "Gagal memuat data: $e"}
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.user['isAdmin'] ?? false;
    final String nama = widget.user['nama'] ?? widget.user['username'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF6A11CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          const AssetImage('assets/appImages/logo.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Selamat Datang, $nama 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _menuCard(
                      context,
                      Icons.dashboard,
                      'Dashboard',
                      Colors.indigo,
                      () {},
                    ),
                    if (isAdmin)
                      _menuCard(
                        context,
                        Icons.people,
                        'Mahasiswa',
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MahasiswaPage(user: widget.user),
                          ),
                        ),
                      ),
                    if (!isAdmin)
                      _menuCard(
                        context,
                        Icons.bar_chart,
                        'Lihat Nilai',
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NilaiPage(user: widget.user),
                          ),
                        ),
                      ),
                    _menuCard(
                      context,
                      Icons.schedule,
                      'Jadwal',
                      Colors.green,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JadwalPage(user: widget.user),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: _pengumuman.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          children: [
                            const Text(
                              "📢 Pengumuman Terbaru",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            ..._pengumuman.map((item) => Card(
                                  elevation: 3,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.campaign,
                                        color: Colors.indigo),
                                    title: Text(item['judul']),
                                    subtitle: Text(item['isi']),
                                  ),
                                )),
                            if (!isAdmin && _nilaiMahasiswa.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                "📚 Nilai Akademik",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              ..._nilaiMahasiswa.map((semester) => Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        'Semester ${semester['semester']} (IPK: ${semester['ipk']})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        ...List.generate(
                                          (semester['mata_kuliah'] as List)
                                              .length,
                                          (i) {
                                            final mk =
                                                semester['mata_kuliah'][i];
                                            return ListTile(
                                              title: Text(mk['nama']),
                                              subtitle: Text(
                                                  'Kode: ${mk['kode']} | SKS: ${mk['sks']}'),
                                              trailing: Text(
                                                mk['nilai'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  )),
                            ]
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
