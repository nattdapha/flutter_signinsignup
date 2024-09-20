import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> reqistration({
    required String email,
    required String password,
    required String confirm,
  }) async {
    try {
      // ตรวจสอบว่ารหัสผ่านและการยืนยันรหัสผ่านตรงกัน
      if (password != confirm) {
        return 'Passwords do not match';
      }

      // สร้างผู้ใช้ใหม่
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // เพิ่มข้อมูลผู้ใช้ลง Firestore
      await addUserToFirestore(userCredential.user);

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> addUserToFirestore(User? user) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        // สามารถเพิ่มข้อมูลเพิ่มเติมได้ที่นี่ เช่น ชื่อผู้ใช้, วันเกิด ฯลฯ
      });
    }
  }

  Future<String?> signin({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}