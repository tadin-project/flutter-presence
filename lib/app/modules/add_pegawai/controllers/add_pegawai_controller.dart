import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });
        }
      } on FirebaseAuthException catch (e) {
        String errMessage = "Error login!";
        if (e.code == 'weak-password') {
          errMessage = "Password yang digunakan terlalu singkat!";
        } else if (e.code == 'email-already-in-use') {
          errMessage = "Pegawai dengan email ini sudah digunakan!";
        }
        Get.snackbar("Terjadi Kesalahan", errMessage);
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambahkan pegawai!");
      }
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIP, nama, dan email harus diisi!");
    }
  }
}
