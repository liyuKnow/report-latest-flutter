import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:latest/main.dart';
import 'package:latest/src/models/user_model.dart';
import 'package:latest/src/pages/qr_page.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder<List<User>>(
            stream: objectbox.getUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // TODO display a user-friendly error message
                debugPrintStack(stackTrace: snapshot.stackTrace);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ],
                );
              } else {
                final users = snapshot.data!;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      title: Text(user.firstName),
                      subtitle: Text(user.lastName),
                      trailing: IconButton(
                        icon: const Icon(Icons.qr_code),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => QRPage()),
                            // QRPage(title: "QR For ${user.id}")),
                          );
                        },
                      ),
                      // onTap: () {
                      //   user.name = Faker().person.firstName();
                      //   user.email = Faker().internet.email();

                      //   objectBox.insertUser(user);
                      // },
                    );
                  },
                );
              }
            }));
  }
}
