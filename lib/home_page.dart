import 'package:flutter/material.dart';
import 'package:notes_app/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 89, 167, 231),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemBuilder: (_, index) {
                ///All note should be visible here
                return ListTile(
                  leading: Text('${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}'),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                );
              },
              itemCount: allNotes.length,
            )
          : Center(child: Text("No Notes yet!!")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetView(onNoteAdded: getNotes);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetView extends StatefulWidget {
  final VoidCallback onNoteAdded; // Callback to notify HomePage

  const BottomSheetView({super.key, required this.onNoteAdded});

  @override
  State<StatefulWidget> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Add Note",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          inputText(
            controller: titleController,
            hint: "Enter Title",
            label: "Title*",
            maxlines: 1,
          ),
          SizedBox(height: 15),
          inputText(
            controller: descController,
            hint: "Enter Description here",
            label: "Desc*",
            maxlines: 4,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue.shade200,
                    side: BorderSide(width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    var title = titleController.text;
                    var desc = descController.text;
                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check = await dbRef!.addNote(
                        mTitle: title,
                        mDesc: desc,
                      );
                      if (check && mounted) {
                        widget
                            .onNoteAdded(); // Call the callback to refresh HomePage
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all the required blanks"),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Add Text",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue.shade200,
                    side: BorderSide(width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget inputText({
  required TextEditingController controller,
  required String hint,
  required String label,
  required int maxlines,
}) {
  return TextField(
    controller: controller,
    maxLines: maxlines,
    decoration: InputDecoration(
      hintText: hint, // Use hintText instead of hint
      labelText: label, // Use labelText instead of label
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color.fromARGB(255, 71, 140, 205)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
  );
}
