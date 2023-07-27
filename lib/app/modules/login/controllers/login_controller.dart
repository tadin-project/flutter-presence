import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:presence/app/routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            isLoading.value = false;
            if (passC.text == "password") {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
              title: "Belum Verifikasi",
              middleText:
                  "Kamu belum verifikasi akun ini. Lakukan verifikasi di email kamu!",
              actions: [
                OutlinedButton(
                  onPressed: () {
                    isLoading.value = false;
                    Get.back();
                  },
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      Get.back();
                      Get.snackbar(
                        "Berhasil",
                        "Kami telah berhasil mengirim email verifikasi ke akun kamu.",
                      );
                      isLoading.value = false;
                    } catch (e) {
                      isLoading.value = false;
                      Get.snackbar(
                        "Terjadi kesalahan",
                        "Tidak dapat mengirim email verifikasi. Hubungi admin atau customer service.",
                      );
                    }
                  },
                  child: const Text("KIRIM ULANG"),
                )
              ],
            );
          }
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        String errMessage = "Error Login!";
        if (e.code == "user-not-found") {
          errMessage = "Email tidak terdaftar!";
        } else if (e.code == "wrong-password") {
          errMessage = "Password salah!";
        }

        Get.snackbar("Terjadi kesalahan", errMessage);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Terjadi kesalahan", "Tidak dapat login!");
      }
    } else {
      Get.snackbar("Terjadi kesalahan", "Email dan password harus diisi!");
    }
  }
}
