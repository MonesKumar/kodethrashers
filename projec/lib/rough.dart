import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DoctorPage(),
    );
  }
}

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response =
          await http.get(Uri.parse("http://127.0.0.1:8000/doctors"));

      if (response.statusCode == 200) {
        setState(() {
          doctors = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load doctors");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verified Doctor Ledger"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? const Center(child: Text("No Doctors Found"))
              : ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor["doctor_name"],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("Degrees: ${doctor["degrees"].join(", ")}"),
                            Text(
                                "Total Cases: ${doctor["total_cases_handled"]}"),
                            Text(
                                "Critical Cases: ${doctor["critical_cases_handled"]}"),
                            Text(
                                "Overall Success: ${doctor["overall_success_rate"]}"),
                            Text(
                                "Critical Success: ${doctor["critical_success_rate"]}"),
                            Text("IMA Rank: ${doctor["IMA_rank"]}"),
                            const SizedBox(height: 8),
                            const Text(
                              "Hospital Schedule:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...doctor["current_hospitals"]
                                .entries
                                .map<Widget>((entry) => Text(
                                    "${entry.key}: ${entry.value}"))
                                .toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}