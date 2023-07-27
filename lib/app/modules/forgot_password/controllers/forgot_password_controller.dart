import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendEmail() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.back();
        Get.snackbar(
          "Berhasil",
          "Silahkan cek email anda!",
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Tidak dapat mengirim email reset password";
        if (e.code == "invalid-email") {
          errorMessage = "Format email salah!";
        } else if (e.code == "user-not-found") {
          errorMessage = "Email tidak ditemukan!";
        }
        Get.snackbar(
          "Terjadi Kesalahan",
          errorMessage,
        );
      } catch (_) {
        Get.snackbar(
          "Terjadi Kesalahan",
          "Tidak dapat mengirim email reset password",
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar(
        "Terjadi Kesalahan",
        "Email harus diisi!",
      );
    }
  }
}
