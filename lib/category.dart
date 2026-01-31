import 'package:admin_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  State<AdminCategoryPage> createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();

  List<dynamic> categories = [];
  int eid=0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

 
  // 🔹 Insert category
  Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _categoryController.text.trim();

    try {
      await supabase.from('tbl_category').insert({
        'category_name': category,
      });

      _categoryController.clear();
      fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$category" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error inserting category: $e');
    }
  }

  // 🔹 Fetch categories
  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = response;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
    }
  }
Future<void> delCategory(int eid) async {
  try{
      await supabase.from('tbl_category').delete().eq('id', eid);
      fetchData();
       if (!mounted) return;

    _categoryController.clear();
    this.eid = 0;
    fetchData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category edited successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }
  Future<void> editCategory(int eid) async {
    try{
      final category=_categoryController.text;
      await supabase.from('tbl_category').update({'category_name':category}).eq('id', eid);
      fetchData();
      if (!mounted) return;

    fetchData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category edited successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    }
    catch(e){
      
    }
    }
  




@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add Category"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.category, size: 80, color: Color(0xFF4CAF50)),
              const SizedBox(height: 20),
              const Text(
                "Create a New Category",
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
                        controller: _categoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Category Name",
                          labelStyle:
                              const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.edit,
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
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                            if(eid==0){
                              insert();

                            }
                            else{
                              editCategory( eid);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Add Category",
                            style: TextStyle(
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

              // 🔹 Category List
              ListView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    child: ListTile(
                      leading: const Icon(
                        Icons.label,
                        color: Color(0xFF4CAF50),
                      ),
                      title: Text(
                        categories[index]['category_name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: (){
                            eid=categories[index]['id'];
                            delCategory(eid);
                            
                          }, icon: Icon(Icons.delete, color: Colors.red[400])),
                          
                          IconButton(onPressed: 
                          (){
                            eid=categories[index]['id'];
                            _categoryController.text=categories[index]['category_name'];

                          }, icon: Icon(Icons.edit,color: Colors.red[400]))
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

