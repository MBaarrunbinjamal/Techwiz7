class Users {
  int? id;
  String FirstName;
  String LastName ;
  String email;
  String  password;
  String  userid;
    Users({
    this.id,
    required this.FirstName,
    required this.LastName,
    required this.email,
    required this.password,
    required this.userid
});
    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'FirstName': FirstName,
        'LastName': LastName,
        'email': email,
        'password': password,
        'userid'   : userid
    };}
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'],
      FirstName: map['FirstName'] ?? '',
      LastName: map['LastName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      userid: map['userid'] ?? '',
    );
  }
}