import 'package:admin_app/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();

  List<dynamic> districtList = [];
  int? selectedDistrictId;
  List<dynamic> placeList = [];
  int editId = 0; // for editing

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    fetchPlaces();
  }

  /// Fetch all districts
  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      if (!mounted) return;
      setState(() {
        districtList = response ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  /// Fetch all places with district names
  Future<void> fetchPlaces() async {
    try {
      final response = await supabase
          .from('tbl_place')
          .select('place_id, place_name, district_id, tbl_district(district_name)');
      if (!mounted) return;
      setState(() {
        placeList = response ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching places: $e');
    }
  }

  /// Insert new place
  Future<void> insertPlace() async {
    if (!_formKey.currentState!.validate()) return;

    final place = _placeController.text.trim();
    try {
      await supabase.from('tbl_place').insert({
        'district_id': selectedDistrictId,
        'place_name': place,
      });

      _placeController.clear();
      selectedDistrictId = null;

      await fetchPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Place "$place" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error inserting place: $e');
    }
  }

  /// Update existing place
  Future<void> updatePlace() async {
    if (!_formKey.currentState!.validate()) return;

    final place = _placeController.text.trim();
    try {
      await supabase
          .from('tbl_place')
          .update({
            'district_id': selectedDistrictId,
            'place_name': place,
          })
          .eq('place_id', editId);

      _placeController.clear();
      selectedDistrictId = null;
      editId = 0;

      await fetchPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Place "$place" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating place: $e');
    }
  }

  /// Delete place
  Future<void> deletePlace(int id) async {
    try {
      await supabase.from('tbl_place').delete().eq('place_id', id);
      await fetchPlaces();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place deleted successfully!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting place: $e');
    }
  }

  /// Start editing a place
  void startEdit(Map<String, dynamic> place) {
    final int? placeId = place['place_id'] is int
        ? place['place_id']
        : int.tryParse(place['place_id'].toString());
    final int? districtId = place['district_id'] is int
        ? place['district_id']
        : int.tryParse(place['district_id'].toString());

    final exists = districtList.any((d) => d['id'] == districtId);

    setState(() {
      editId = placeId ?? 0;
      _placeController.text = place['place_name'] ?? '';
      selectedDistrictId = exists ? districtId : null;
    });
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Add District & Place",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.place, size: 90, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              const Text(
                "Add New Location",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Assign places under districts for better management",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              /// FORM CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// District Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedDistrictId,
                        dropdownColor: const Color(0xFF1E1E1E),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          labelText: "Select District",
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: districtList.map((district) {
                          final int? id = district['id'] is int
                              ? district['id']
                              : int.tryParse(district['id'].toString());
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              district['district_name'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrictId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a district';
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      /// Place Name Input
                      TextFormField(
                        controller: _placeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Place Name",
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.place,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a place name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// Save / Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: editId == 0 ? insertPlace : updatePlace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            editId == 0 ? "Add Place" : "Update Place",
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

              /// Place List
              placeList.isEmpty
                  ? const Text(
                      "No places added yet",
                      style: TextStyle(color: Colors.grey),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: placeList.length,
                      itemBuilder: (context, index) {
                        final place = placeList[index];
                        final districtName =
                            (place['tbl_district']?['district_name'] ?? 'Unknown')
                                .toString();

                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.place,
                              color: Color(0xFF4CAF50),
                            ),
                            title: Text(
                              place['place_name'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              districtName,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange[300]),
                                  onPressed: () => startEdit(place),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[400]),
                                  onPressed: () {
                                    final int? id = place['place_id'] is int
                                        ? place['place_id']
                                        : int.tryParse(place['place_id'].toString());
                                    if (id != null) deletePlace(id);
                                  },
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
