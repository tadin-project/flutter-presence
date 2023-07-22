import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "password") {
        try {
          await auth.currentUser!.updatePassword(newPassC.text);
          String email = auth.currentUser!.email!;
          await auth.signOut();
          await auth.signInWithEmailAndPassword(
            email: email,
            password: newPassC.text,
          );
          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          Get.snackbar(
            "Terjadi Kesalahan",
            e.message.toString(),
          );
        } catch (e) {
          Get.snackbar(
            "Terjadi Kesalahan",
            "New Password Error",
          );
        }
      } else {
        Get.snackbar(
          "Terjadi Kesalahan",
          "Password baru harus diubah, jangan 'password' kembali!",
        );
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "Password baru wajib diisi!");
    }
  }
}
