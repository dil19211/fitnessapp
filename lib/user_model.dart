class UserModel{
  String? name;
  String? email;
  int? age;
  int? height;
  String? gender;
  String? activity_level;
  int? cweight;
  int? gweight;

  UserModel(this.name, this.email, this.age, this.height,this.gender,this.activity_level, this.cweight, this.gweight);
  Map<String,dynamic> toMap(){
    return{
      'name': name,
      'email': email,
      'age' : age,
      'height': height,
      'gender': gender,
      'activity_level':activity_level,
      'cweight' : cweight,
      'gweight':gweight
    };
  }
}