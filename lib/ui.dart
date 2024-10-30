import 'package:flutter/material.dart';
import 'package:sql/funtion.dart';
import 'package:sql/model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries(); // Load entries from database on startup
  }

  // Function to load entries from the database
  Future<void> _loadEntries() async {
    final notes = await DatabaseHelper.instance.getAll();
    setState(() {
      entries = notes;
    });
  }

  // Function to show the bottom sheet for adding or updating entries
  void _showBottomSheet(BuildContext context, {NoteModel? note}) {
    TextEditingController nameController = TextEditingController(text: note?.name);
    TextEditingController addressController = TextEditingController(text: note?.address);
    TextEditingController phoneController = TextEditingController(text: note?.phone?.toString());

    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  int? phone = int.tryParse(phoneController.text);

                  if (phone != null) {
                    final newNote = NoteModel(
                      name: nameController.text,
                      address: addressController.text,
                      phone: phone,
                    );

                    // Insert new note or update existing note if it has the same name
                    await DatabaseHelper.instance.insert(newNote);

                    // Load the updated list of entries
                    await _loadEntries();
                    Navigator.pop(context); // Close the bottom sheet
                  } else {
                    // Display an error if the phone is not a valid integer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid phone number')),
                    );
                  }
                },
                child: Text(note == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete a note
  void _deleteNote(String name) async {
    await DatabaseHelper.instance.delete(name);
    // Reload the entries after deletion
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 191, 187, 207),
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: const Color.fromARGB(255, 191, 187, 207),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              color: const Color.fromARGB(255, 191, 214, 215),
              shadowColor: Colors.blueGrey,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(entry.name ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${entry.address ?? ''}'),
                    Text('Phone: ${entry.phone?.toString() ?? ''}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () {
                        _showBottomSheet(context, note: entry); // Pass the note to edit
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: const Color.fromARGB(255, 158, 38, 38)),
                      onPressed: () {
                        // Show a confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Note'),
                              content: Text('Are you sure you want to delete this note?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteNote(entry.name!); // Delete the note
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context); 
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 126, 133, 137),
      ),
    );
  }  
}
