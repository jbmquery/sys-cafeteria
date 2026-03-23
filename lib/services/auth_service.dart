class AuthService {
  bool login(String usuario, String password) {
    if (usuario == "admin" && password == "1234") {
      return true;
    }
    return false;
  }
}
