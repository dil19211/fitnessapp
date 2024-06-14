class payUserModel{

  String? email;

  payUserModel(this.email);
  Map<String,dynamic> toMap(){
    return{

      'email': email

    };
  }
}