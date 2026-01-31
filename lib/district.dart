import 'package:admin_app/main.dart';
import 'package:flutter/material.dart';

class AdminDistrictPage extends StatefulWidget {
  const AdminDistrictPage({super.key});

  @override
  State<AdminDistrictPage> createState() => _AdminDistrictPageState();
}

class _AdminDistrictPageState extends State<AdminDistrictPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _districtController = TextEditingController();

  List<dynamic> districtList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // 🔹 INSERT
  Future<void> insert() async {
    final district = _districtController.text.trim();
    if (district.isEmpty) return;

    try {
      await supabase
          .from('tbl_district')
          .insert({'district_name': district});

      if (!mounted) return;

      _districtController.clear();
      fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('District "$district" added successfully!'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      debugPrint('Error inserting district: $e');
    }
  }

  // 🔹 UPDATE
  Future<void> editDistrict(int eid) async {
    final district = _districtController.text.trim();
    if (district.isEmpty) return;

    try {
      await supabase
          .from('tbl_district')
          .update({'district_name': district})
          .eq('id', eid);

      if (!mounted) return;

      _districtController.clear();
      this.eid = 0;
      fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('District updated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      debugPrint('Error updating district: $e');
    }
  }

  // 🔹 FETCH
  Future<void> fetchData() async {
    final response = await supabase.from('tbl_district').select();
    setState(() {
      districtList = response;
    });
  }

  // 🔹 DELETE
  Future<void> delDistrict(int eid) async {
    try {
      await supabase.from('tbl_district').delete().eq('id', eid);

      if (!mounted) return;

      _districtController.clear();
      this.eid = 0;
      fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('District deleted successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting district: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add District"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              const Icon(
                Icons.location_city,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create a New District",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Input Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _districtController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "District Name",
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a district name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (eid == 0) {
                                insert();
                              } else {
                                editDistrict(eid);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            eid == 0 ? "Add District" : "Update District",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 District List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: districtList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        districtList[index]['district_name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              eid = districtList[index]['id'];
                              delDistrict(eid);
                            },
                            icon: Icon(Icons.delete, color: Colors.red[400]),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                eid = districtList[index]['id'];
                                _districtController.text =
                                    districtList[index]['district_name'];
                              });
                            },
                            icon: Icon(Icons.edit, color: Colors.red[400]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
