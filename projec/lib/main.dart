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
  List surgeons = [];
  List filteredSurgeons = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchSurgeons();
  }

  Future<void> fetchSurgeons() async {
    try {
      final response =
          await http.get(Uri.parse("http://127.0.0.1:8000/surgeons"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          surgeons = data;
          filteredSurgeons = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchDoctor(String query) {
    final results = surgeons.where((surgeon) {
      final name = surgeon["name"].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchQuery = query;
      filteredSurgeons = results;
    });
  }

  void showMoreDetails(Map surgeon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(surgeon["name"]),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Age: ${surgeon["age"]}"),
                Text("Experience: ${surgeon["years_of_experience"]} years"),
                Text("Specialization: ${surgeon["specialization"]}"),
                Text("Total Cases: ${surgeon["total_cases_handled"]}"),
                Text("Critical Cases: ${surgeon["critical_cases_handled"]}"),
                Text("Overall Success: ${surgeon["overall_success_rate"]}%"),
                Text("Critical Success: ${surgeon["critical_success_rate"]}%"),
                Text(
                    "Patient Rating: ⭐ ${surgeon["patient_satisfaction_score"]}"),
                const SizedBox(height: 10),
                const Text("Hospitals:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...surgeon["hospitals"].map<Widget>((hospital) {
                  return Text(
                      "${hospital["hospital_name"]} (${hospital["working_days"].join(", ")})");
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verified Surgeon Ledger"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by doctor name...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: searchDoctor,
                  ),
                ),
                Expanded(
                  child: filteredSurgeons.isEmpty
                      ? const Center(child: Text("No Doctors Found"))
                      : ListView.builder(
                          itemCount: filteredSurgeons.length,
                          itemBuilder: (context, index) {
                            final surgeon = filteredSurgeons[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                  surgeon["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    surgeon["specialization"]),
                                trailing: TextButton(
                                  onPressed: () =>
                                      showMoreDetails(surgeon),
                                  child: const Text("See More"),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}