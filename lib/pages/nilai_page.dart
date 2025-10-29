import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class NilaiPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const NilaiPage({super.key, required this.user});

  @override
  State<NilaiPage> createState() => _NilaiPageState();
}

class _NilaiPageState extends State<NilaiPage> {
  Map<String, dynamic>? _mahasiswa;
  List<dynamic> _nilaiMahasiswa = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNilaiData();
  }

  Future<void> _loadNilaiData() async {
    try {
      final String rawData =
          await rootBundle.loadString('assets/json/dashboard_kuliah.json');

      final List<dynamic> rootList = jsonDecode(rawData);

      if (rootList.isEmpty) {
        print('JSON root kosong');
        setState(() {
          _nilaiMahasiswa = [];
          _loading = false;
        });
        return;
      }

      final List<dynamic> mahasiswaList = rootList[0]['nilai_mahasiswa'] ?? [];

      final userNim = widget.user['username'].toString();

      final mahasiswa = mahasiswaList.firstWhere(
        (m) => m['nim'].toString() == userNim,
        orElse: () => null,
      );

      if (mahasiswa != null) {
        setState(() {
          _mahasiswa = Map<String, dynamic>.from(mahasiswa);
          _nilaiMahasiswa =
              List<Map<String, dynamic>>.from(_mahasiswa!['penilaian']);
          _loading = false;
        });
      } else {
        print('Mahasiswa dengan NIM $userNim tidak ditemukan.');
        setState(() {
          _nilaiMahasiswa = [];
          _loading = false;
        });
      }
    } catch (e) {
      print('Gagal memuat data nilai: $e');
      setState(() {
        _nilaiMahasiswa = [];
        _loading = false;
      });
    }
  }

  Widget _nilaiChart() {
    if (_nilaiMahasiswa.isEmpty) return const SizedBox();

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < _nilaiMahasiswa.length; i++) {
      final semester = _nilaiMahasiswa[i];
      double ipk = double.tryParse(semester['ipk'].toString()) ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: ipk,
              color: Colors.indigo,
              width: 20,
              borderRadius: BorderRadius.circular(6),
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 4.0,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= _nilaiMahasiswa.length)
                    return const SizedBox();
                  return Text('${_nilaiMahasiswa[idx]['semester']}');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.user['nama'] ?? widget.user['username'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nilai Mahasiswa - $nama'),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _nilaiMahasiswa.isEmpty
                  ? const Center(child: Text('Belum ada data nilai'))
                  : ListView(
                      children: [
                        const Text(
                          "📊 Grafik IPK Per Semester",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        _nilaiChart(),
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
                                    (semester['mata_kuliah'] as List).length,
                                    (i) {
                                      final mk = semester['mata_kuliah'][i];
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
                      ],
                    ),
            ),
    );
  }
}
