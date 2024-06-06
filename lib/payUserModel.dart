class payUserModel{
  String? name;
  String? email;
  int? phn;
  payUserModel(this.name, this.email, this.phn);
  Map<String,dynamic> toMap(){
    return{
      'name': name,
      'email': email,
      'phn' : phn
    };
  }
}