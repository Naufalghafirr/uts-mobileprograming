import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uts_naufal/widget/navigation_drawer.dart';

class MahasiswaPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const MahasiswaPage({super.key, required this.user});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  List<dynamic> _mahasiswa = [];
  bool get isAdmin => widget.user['isAdmin'];
  @override
  void initState() {
    super.initState();
    _loadMahasiswa();
  }

  Future<void> _loadMahasiswa() async {
    final data = await rootBundle.loadString('assets/json/data_mahasiswa.json');
    setState(() {
      _mahasiswa = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(user: widget.user),
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      body: _mahasiswa.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _mahasiswa.length,
              itemBuilder: (context, index) {
                final mhs = _mahasiswa[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(mhs['nama'][0]),
                  ),
                  title: Text(mhs['nama']),
                  subtitle: Text('NIM: ${mhs['nim']}'),
                );
              },
            ),
    );
  }
}
