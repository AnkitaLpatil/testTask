import 'package:flutter/material.dart';
import 'package:my_flutter_app/networking/userApiCall.dart';
import 'package:my_flutter_app/responseModels/userResponse.dart';
import 'package:my_flutter_app/src/UserDetailScreen.dart';
import 'package:toggle_switch/toggle_switch.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  UserService userService = UserService();
  ScrollController _scrollController = ScrollController();
  List<User> users = []; // Displayed users
  List<User> allUsers = []; // All users fetched from API
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  bool isListView = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMoreData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadMoreData() async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> response =
          await userService.fetchUsers(pageno: page);

      List<dynamic> fetchedUsersJson = response['data'];
      List<User> fetchedUsers =
          fetchedUsersJson.map((json) => User.fromJson(json)).toList();

      setState(() {
        allUsers.addAll(fetchedUsers);
        users = List.from(allUsers);

        page++;
        hasMore = fetchedUsers.length > 0;
      });
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchUsers(String query) async {
    setState(() {
      searchQuery = query;

      users = allUsers.where((user) {
        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
        return fullName.contains(query.toLowerCase()) ||
            user.id.contains(query);
      }).toList();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Users',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      searchUsers(value);
                    },
                  ),
                ),
                ToggleSwitch(
                  minWidth: 90.0,
                  cornerRadius: 20.0,
                  activeBgColors: [
                    [Colors.green[800]!],
                    [Colors.red[800]!]
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  initialLabelIndex: isListView ? 0 : 1,
                  totalSwitches: 2,
                  labels: ['List', 'Grid'],
                  radiusStyle: true,
                  onToggle: (index) {
                    setState(() {
                      isListView = index == 0;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isListView
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: users.length + 1,
                    itemBuilder: (context, index) {
                      if (index < users.length) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(users[index].picture),
                          ),
                          title: Text('${users[index].id}'),
                          subtitle: Text(
                              '${users[index].firstName} ${users[index].lastName}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: users[index]),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Text('No more users'),
                          ),
                        );
                      }
                    },
                  )
                : GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: users.length + 1,
                    itemBuilder: (context, index) {
                      if (index < users.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: users[index]),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(users[index].picture),
                                  onBackgroundImageError:
                                      (exception, stackTrace) {
                                    print('Image load error: $exception');
                                  },
                                ),
                                ListTile(
                                  title: FittedBox(
                                    child: Text('${users[index].id} '),
                                  ),
                                  subtitle: Text(
                                      '${users[index].title} ${users[index].firstName} ${users[index].lastName}'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Text('No more users'),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
