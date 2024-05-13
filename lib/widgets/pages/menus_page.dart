import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_project_flutter/widgets/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({Key? key});

  @override
  _MenusPageState createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  List<dynamic> menus = [];

  @override
  void initState() {
    super.initState();
    _initializeMenus();
  }

  void _initializeMenus() {
    String? token = Provider.of<AuthProvider>(context, listen: false).token;

    http.get(
      Uri.parse('http://10.0.2.2:8000/api/menus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          menus = json.decode(response.body)['data'];
        });
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to fetch menus');
      }
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<void> _showMenuActionsDialog(Map menu) async {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Sunday',
      'Saturday'
    ];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Menu Actions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Menu: ' + menu['title']),
                const SizedBox(height: 20),
                for (String day in daysOfWeek) ...[
                  Text(day,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildMenuButton(day, menu),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteMenu(menu);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                _editMenu(menu);
                Navigator.of(context).pop();
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(String day, menu) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _handleMenuAction(menu, day, 1);
          },
          icon: const Icon(Icons.free_breakfast),
          label: const Text('Breakfast'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _handleMenuAction(menu, day, 2);
          },
          icon: const Icon(Icons.restaurant),
          label: const Text('Lunch'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _handleMenuAction(menu, day, 3);
          },
          icon: const Icon(Icons.dinner_dining),
          label: const Text('Dinner'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _handleMenuAction(menu, day, 4);
          },
          icon: const Icon(Icons.fastfood),
          label: const Text('Snack'),
        ),
      ],
    );
  }

  void _deleteMenu(Map menu) {
    String? token = Provider.of<AuthProvider>(context, listen: false).token;

    http.delete(
      Uri.parse('http://10.0.2.2:8000/api/menus/${menu['id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          menus.remove(menu);
        });
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to delete menu');
      }
    }).catchError((error) {
      print(error.toString());
    });
  }

  void _editMenu(Map menu) {}

  Future<void> _handleMenuAction(menu, String day, int meal) async {
    List<dynamic> dishes = menu['menus_dishes'].where((dish) {
      return dish['day'] == _getDayNumber(day) && dish['meal'] == meal;
    }).toList();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$day - ${_getMealName(meal)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dishes.map<Widget>((dish) {
                return ListTile(
                  title: Text(dish['dish']['title']),
                  subtitle: TextButton(
                    onPressed: () {
                      _launchURL(dish['dish']['recipe_link']);
                    },
                    child: Text(dish['dish']['recipe_link']),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  int _getDayNumber(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 1;
    }
  }

  String _getMealName(int meal) {
    switch (meal) {
      case 1:
        return 'Breakfast';
      case 2:
        return 'Lunch';
      case 3:
        return 'Dinner';
      case 4:
        return 'Snack';
      default:
        return 'Unknown';
    }
  }

  int _getMealId(String meal) {
    switch (meal) {
      case 'Breakfast':
        return 1;
      case 'Lunch':
        return 2;
      case 'Dinner':
        return 3;
      case 'Snack':
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus'),
      ),
      body: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(menus[index]['title']),
            onTap: () {
              _showMenuActionsDialog(menus[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMenu,
        tooltip: 'Add New Menu',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewMenu() {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _startDateController = TextEditingController();
    Map<String, Map<String, int>> plan = {};

    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Sunday',
      'Saturday'
    ];

    String? token = Provider.of<AuthProvider>(context, listen: false).token;
    List<dynamic> dishes = [];

    http.get(
      Uri.parse('http://10.0.2.2:8000/api/dishes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          dishes = json.decode(response.body)['data'];
        });

        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add New Menu'),
              content: SingleChildScrollView(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Start Date'),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _startDateController.text = pickedDate.toString();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      for (String day in daysOfWeek) ...[
                        Text(day,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        _buildMealSelections(day, dishes, plan),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _submitNewMenu(
                        _titleController.text, _startDateController.text, plan);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to fetch dishes');
      }
    }).catchError((error) {
      print('Error fetching dishes: $error');
    });
  }

  Widget _buildMealSelections(
      String day, List<dynamic> dishes, Map<String, Map<String, int>> plan) {
    return Column(
      children: [
        _buildMealDropdown('Breakfast', day, dishes, plan),
        _buildMealDropdown('Lunch', day, dishes, plan),
        _buildMealDropdown('Dinner', day, dishes, plan),
        _buildMealDropdown('Snack', day, dishes, plan),
      ],
    );
  }

  Widget _buildMealDropdown(String meal, String day, List<dynamic> dishes,
      Map<String, Map<String, int>> plan) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: meal),
      items: _buildDropdownItems(dishes),
      onChanged: (String? value) {
        if (value != null) {
          int dishId = int.parse(value);
          int dayKey = _getDayNumber(day);
          int mealKey = _getMealId(meal);
          plan.putIfAbsent(dayKey.toString(), () => {});
          plan[dayKey.toString()]![mealKey.toString()] = dishId;
        }
      },
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(List<dynamic> dishes) {
    List<DropdownMenuItem<String>> items = [];
    for (var dish in dishes) {
      items.add(DropdownMenuItem<String>(
        value: dish['id'].toString(),
        child: Tooltip(
          message: dish['title'],
          child: Text(
            _truncateTitle(dish['title']),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
    }
    return items;
  }

  String _truncateTitle(String title) {
    if (title.length > 20) {
      return title.substring(0, 20) + '...';
    } else {
      return title;
    }
  }

  void _submitNewMenu(
      String title, String startDate, Map<String, Map<String, int>> plan) {
    String? token = Provider.of<AuthProvider>(context, listen: false).token;

    Map<String, dynamic> requestData = {
      'title': title,
      'start_at': startDate,
      'plan': plan,
    };

    http
        .post(
      Uri.parse('http://10.0.2.2:8000/api/menus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    )
        .then((response) {
      if (response.statusCode == 201) {
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to add menu');
      }
    }).catchError((error) {
      print(error.toString());
    });
  }
}
