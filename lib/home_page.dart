import 'package:flutter/material.dart';
import 'package:notes_app/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
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
                return ListTile(
                  leading: Text('${index+1}'),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            titleController.text =
                                allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                            descController.text =
                                allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return bottomSheetView(
                                  context: context,
                                  onNoteAdded: getNotes,
                                  isUpdate: true,
                                  sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                                  titleController: titleController,
                                  descController: descController,
                                );
                              },
                            );
                          },
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () async {
                            bool deleted = await dbRef!.deleteNote(
                              sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                            );
                            if (deleted) {
                              getNotes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Note deleted")),
                              );
                            }
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: allNotes.length,
            )
          : Center(child: Text("No Notes yet!!")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return bottomSheetView(
                context: context,
                onNoteAdded: getNotes,
                isUpdate: false,
                sno: 0,
                titleController: titleController,
                descController: descController,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget bottomSheetView({
  required BuildContext context,
  required VoidCallback onNoteAdded,
  required bool isUpdate,
  required int sno,
  required TextEditingController titleController,
  required TextEditingController descController,
}) {
  DBHelper dbRef = DBHelper.getInstance;

  return Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
    ),
    child: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(11),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Makes the bottom sheet compact
          children: [
            Text(
              isUpdate ? 'Update' : "Add Note",
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
                        bool check = isUpdate
                            ? await dbRef.updateNote(
                                mTitle: title,
                                mDesc: desc,
                                sno: sno,
                              )
                            : await dbRef.addNote(mTitle: title, mDesc: desc);
                        if (check) {
                          onNoteAdded();
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
                      isUpdate ? 'Update Note' : "Add Note",
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
            SizedBox(height: 20), // Extra space to ensure scrolling works
          ],
        ),
      ),
    ),
  );
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
      hintText: hint,
      labelText: label,
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