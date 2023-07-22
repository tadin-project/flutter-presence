import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    if (passAdminC.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;
        // ignore: unused_local_variable
        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );

        UserCredential userCredentialPegawai =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (userCredentialPegawai.user != null) {
          String uid = userCredentialPegawai.user!.uid;
          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });

          await userCredentialPegawai.user!.sendEmailVerification();

          await auth.signOut();

          await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back(); // tutup dialog
          Get.back(); // back to home
          Get.snackbar(
            "Berhasil",
            "Berhasil menambahkan pegawai",
          ); // back to home
        }
      } on FirebaseAuthException catch (e) {
        String errMessage = "Error add pegawai!";
        if (e.code == 'weak-password') {
          errMessage = "Password yang digunakan terlalu singkat!";
        } else if (e.code == 'email-already-in-use') {
          errMessage = "Pegawai dengan email ini sudah digunakan!";
        } else if (e.code == 'wrong-password') {
          errMessage = "Password salah!";
        } else {
          errMessage = e.code.toString();
        }
        Get.snackbar("Terjadi Kesalahan", errMessage);
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambahkan pegawai!");
      }
    } else {
      Get.snackbar(
        "Terjadi Kesalahan",
        "Password wajib diisi untuk keperluan validasi admin!",
      );
    }
  }

  void addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            const Text("Masukkan password untuk validasi admin"),
            TextField(
              controller: passAdminC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              await prosesAddPegawai();
            },
            child: const Text("ADD PEGAWAI"),
          ),
        ],
      );
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIP, nama, dan email harus diisi!");
    }
  }
}
