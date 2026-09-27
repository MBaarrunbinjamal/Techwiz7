class Users {
  int? id;
  String FirstName;
  String phonenumber ;
  String email;
  String  password;
  String  userId;
    Users({
    this.id,
    required this.FirstName,
    required this.phonenumber,
    required this.email,
    required this.password,
    required this.userId
});
    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'FirstName': FirstName,
        'phonenumber': phonenumber,
        'email': email,
        'password': password,
        'userId'   : userId
    };}
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'],
      FirstName: map['FirstName'] ?? '',
      phonenumber: map['phonenumber'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}