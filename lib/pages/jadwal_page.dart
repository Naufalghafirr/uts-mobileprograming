import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uts_naufal/widget/navigation_drawer.dart';

class JadwalPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const JadwalPage({super.key, required this.user});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> _jadwal = [];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final data = await rootBundle.loadString('assets/json/jadwal_kuliah.json');
    setState(() {
      _jadwal = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(user: widget.user),
      appBar: AppBar(title: const Text('Jadwal Kuliah')),
      body: _jadwal.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jadwal.length,
              itemBuilder: (context, index) {
                final hari = _jadwal[index];
                final mataKuliah = hari['mata_kuliah'] as List<dynamic>;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      hari['hari'],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16,
                          headingRowColor: MaterialStateProperty.all(
                              Colors.indigo.withOpacity(0.1)),
                          columns: const [
                            DataColumn(label: Text('Kode')),
                            DataColumn(label: Text('Mata Kuliah')),
                            DataColumn(label: Text('Waktu')),
                            DataColumn(label: Text('Ruang')),
                            DataColumn(label: Text('Dosen')),
                          ],
                          rows: mataKuliah
                              .map(
                                (mk) => DataRow(
                                  cells: [
                                    DataCell(Text(mk['kode'])),
                                    DataCell(Text(mk['nama'])),
                                    DataCell(Text(mk['waktu'])),
                                    DataCell(Text(mk['ruang'])),
                                    DataCell(Text(mk['dosen'])),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
