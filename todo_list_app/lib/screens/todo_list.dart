import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_list_app/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index){
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')), 
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value){
                    if(value == 'edit'){
                      //open the edit button
                      navigateToEditPage(item);
                    }else if (value == 'delete'){
                      //delete and remove the item
                      Future<void> deleteById(String _id) async{
                        //delete the item
                        final url = 'https://api.nstack.in/v1/todos/$id';
                        final uri = Uri.parse(url);
                        final response = await http.delete(uri);
                        if(response.statusCode == 200){
                          //remove item from the list
                          final filtered = items.where((element) => element['_id'] != id).toList();
                          setState(() {
                            items = filtered;
                          });
                          // fetchTodo();
                        }else{
                          //show error
                          showErrorMessage('deletion failed');
                        }
                      }
                    }
                  } ,
                  itemBuilder: (context) {
                    return const[
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                        )
                    ];
                }),
              );
            },
            ),
        ),
        child:const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage, 
        label:const Text('Add Todo'),
        ),
    );
  }

  Future<void> navigateToEditPage(Map item)async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo:item),
      );
      await Navigator.push(context, route);
      setState(() {
        isLoading = true;
      });
      fetchTodo();
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage()
      );
      await Navigator.push(context, route);
      setState(() {
        isLoading = true;
      });
      fetchTodo();
  }

  Future<void> fetchTodo() async{
    
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json['item'] as List;
      setState(() {
        items = result ;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  
  // void showSuccessMessage(String message){
  //   final snackBar = SnackBar(content: Text(message));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  void showErrorMessage(String messsage){
    final snackBar = SnackBar(
      content: Text(
        messsage,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}