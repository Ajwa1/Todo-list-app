import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo,
    
    });
  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}
class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if(todo !=null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Todo' :'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData :submitData, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEdit ? 'update':'Submit'),
            ),
          )
        ],
      )
    );
  }

  Future<void> updateData() async{
    final todo = widget.todo;
    if(todo == null){
      print('you can not call uppdated without todo data');
      return;
    }
    final id = todo['_id'];
    // final isCompleted = todo['is_completed'];

    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
  "title": title,
  "description": description,
  // "is_completed": isCompleted,
  "is_completed": false,
  };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri, 
      body: jsonEncode(body),
      headers:{'content-Type': 'application/json'}
      );
      if (response.statusCode == 201){
      showSuccessMessage('updation Success');
    }else{
      showErroreMessage('Creation Failed');
    }
  }

  Future<void> submitData() async{
    //get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
  "title": title,
  "description": description,
  "is_completed": false,
    };
    //submit data to the server
    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri, 
      body: jsonEncode(body),
      headers:{
        'content-Type': 'application/json'
      }
      );
    //http.post(uri)
    //show success or fail message based on status
    //print(response.statusCode);
    if (response.statusCode == 201){
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('creation Success');
    }else{
      showErroreMessage('Creation Failed');
    }
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErroreMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
