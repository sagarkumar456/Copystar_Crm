import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Copy feature ke liye
import 'package:firebase_database/firebase_database.dart';

class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key});

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header & Search Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Software Download Logs', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            // Search Bar
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Email...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: const Color(0xFF232323),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF63D392)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        
        // Real-time Data Table
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('software_emails').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF63D392)));
              }
              
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: Text(
                    'No download records found.', 
                    style: TextStyle(color: Colors.grey, fontSize: 18)
                  )
                );
              }

              // Firebase data ko Map me convert karna
              Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> records = [];
              
              dataMap.forEach((key, value) {
                var record = Map<String, dynamic>.from(value);
                record['id'] = key;
                records.add(record);
              });

              // Naye downloads sabse upar dikhane ke liye sort karna
              records.sort((a, b) {
                String timeA = a['timestamp'] ?? '';
                String timeB = b['timestamp'] ?? '';
                return timeB.compareTo(timeA); // Descending order
              });

              // 🟢 SEARCH FILTER LOGIC
              List<Map<String, dynamic>> filteredRecords = records.where((record) {
                String email = (record['email'] ?? '').toString().toLowerCase();
                return email.contains(_searchQuery);
              }).toList();

              if (filteredRecords.isEmpty) {
                return const Center(
                  child: Text(
                    'No results found for your search.', 
                    style: TextStyle(color: Colors.grey, fontSize: 16)
                  )
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 TOTAL COUNT DISPLAY
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Total Downloads: ${filteredRecords.length}',
                      style: const TextStyle(
                        color: Color(0xFF63D392), // Match theme color
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Data Table
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(
                              color: Color(0xFF4A90E2), 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            ),
                            dataTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
                            dividerThickness: 0.5,
                            horizontalMargin: 20,
                            columnSpacing: 60,
                            columns: const [
                              DataColumn(label: Text('S.No')),
                              DataColumn(label: Text('User Email')),
                              DataColumn(label: Text('Software Brand')),
                              DataColumn(label: Text('Date & Time')),
                            ],
                            rows: List.generate(filteredRecords.length, (index) {
                              final record = filteredRecords[index];
                              final String emailText = record['email'] ?? 'N/A';
                              
                              // Timestamp ko readable format me badalna
                              String rawTime = record['timestamp'] ?? '';
                              String formattedTime = rawTime;
                              if (rawTime.isNotEmpty) {
                                try {
                                  DateTime dt = DateTime.parse(rawTime).toLocal();
                                  String amPm = dt.hour >= 12 ? 'PM' : 'AM';
                                  int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
                                  formattedTime = "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} | ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm";
                                } catch (e) {
                                  // Agar parse na ho paye toh default
                                }
                              }

                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}', style: const TextStyle(color: Colors.grey))),
                                  // 🟢 EMAIL CELL WITH COPY BUTTON
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(emailText),
                                        const SizedBox(width: 10),
                                        if (emailText != 'N/A')
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: emailText));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('$emailText copied!'),
                                                  backgroundColor: const Color(0xFF63D392),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.copy, size: 16, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(record['brand'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(formattedTime, style: const TextStyle(color: Colors.grey))),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}