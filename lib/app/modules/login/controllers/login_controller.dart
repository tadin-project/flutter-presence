import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:presence/app/routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            Get.offAllNamed(Routes.HOME);
          } else {
            Get.defaultDialog(
              title: "Belum Verifikasi",
              middleText:
                  "Kamu belum verifikasi akun ini. Lakukan verifikasi di email kamu!",
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errMessage = "Error Login!";
        if (e.code == "user-not-found") {
          errMessage = "Email tidak terdaftar!";
        } else if (e.code == "wrong-password") {
          errMessage = "Password salah!";
        }

        Get.snackbar("Terjadi kesalahan", errMessage);
      } catch (e) {
        Get.snackbar("Terjadi kesalahan", "Tidak dapat login!");
      }
    } else {
      Get.snackbar("Terjadi kesalahan", "Email dan password harus diisi!");
    }
  }
}
