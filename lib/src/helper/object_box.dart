import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:latest/objectbox.g.dart';
import 'package:latest/src/models/user_model.dart';
import 'package:latest/src/models/updated_location.dart';

class ObjectBox {
  // DEFINE STORE
  late final Store store;

  // DEFINE BOXES
  late final Box<User> userBox;
  late final Box<UpdatedLocation> updatedLocationBox;

  /// CREATE AN INSTANCE OF OBJECTBOX TO USE THROUGHOUT THE APP.
  ObjectBox._create(this.store) {
    userBox = Box<User>(store);
    updatedLocationBox = Box<UpdatedLocation>(store);

    // Add some demo data if the box is empty.
    if (userBox.isEmpty()) {
      _putDemoData();
    }
  }

  /// CREATE AN INSTANCE OF OBJECTBOX TO USE THROUGHOUT THE APP.
  static Future<ObjectBox> create() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseDirectory = p.join(documentsDirectory.path, "obx-report-db");

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: databaseDirectory);
    return ObjectBox._create(store);
  }

  /// !CREATE CRUD OPERATIONS
  /// TODO : OPERATIONS WE NEED ARE
  /// * ADD RECORD(user)
  /// * GET RECORD(user)
  /// * GET ALL RECORDS(users)
  /// * UPDATE RECORD(user)
  /// * ADD UPDATED LOCATION OF RECORD(user)
  /// * GET UPDATED LOCATION OF RECORD(user)
  ///
  ///
  ///
  /// ! TEST TEST TEST
  void _putDemoData() {
    User userOne = User("kidus", "taye", "male", "american");
    userBox.put(userOne);

    UpdatedLocation updatedLocationOne = UpdatedLocation(8.8965, 11.6785);
    updatedLocationOne.userId.target = userOne;
    updatedLocationBox.put(updatedLocationOne);
  }

  // ADD USER
  void addUser(
      String firstName, String lastName, String country, String gender) {
    User newUser = User(firstName, lastName, country, gender);
    userBox.put(newUser);
  }

  // UPDATE NAD INSERT IN ONE
  void putUser(User user) {
    userBox.put(user);
  }

  // GET ALL USERS
  Stream<List<User>> getUsers() {
    return userBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  //  GET USER
  User? getUser(int id) {
    return userBox.get(id);
  }

  // ADD UPDATED LOCATION
  void addUpdatedLocation(
      double lat, double long, DateTime updatedAt, User userId) {
    UpdatedLocation newUpdatedLocation =
        UpdatedLocation(lat, long, updatedAt: updatedAt);
    newUpdatedLocation.userId.target = userId;

    updatedLocationBox.put(newUpdatedLocation);
  }

  // GET LOCATION BY USER ID

  // ADD MANY USERS
  void addAll() {
    // PUT MANY ALSO MAYBE USEFUL
    // final users = getNewUsers();
    // userBox.putMany(users);
  }
}
