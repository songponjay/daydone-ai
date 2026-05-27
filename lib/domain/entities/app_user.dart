

class AppUser {
  final String id;       // user ID (จาก Firebase หรือ Mock)
  final String name;     // ชื่อแสดงผล
  final String email;    // email ที่ใช้ login

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });
}