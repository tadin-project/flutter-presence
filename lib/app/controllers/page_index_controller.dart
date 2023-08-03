import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore store = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (!dataResponse["error"]) {
          Position position = dataResponse["position"];
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";
          await updatePosition(position, address);
          await presensi(position, address);

          Get.snackbar(
            "Berhasil",
            "Kamu telah mengisi daftar hadir",
          );
        } else {
          Get.snackbar("Terjadi kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(Position position, String address) async {
    String uid = auth.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> colPresence =
        store.collection("pegawai").doc(uid).collection("presence");
    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    if (snapPresence.docs.isEmpty) {
      // belum pernah absen
      await colPresence.doc(todayDocID).set({
        "date": now.toIso8601String(),
        "masuk": {
          "date": now.toIso8601String(),
          "lat": position.latitude,
          "long": position.longitude,
          "address": address,
          "status": "Di dalam area",
        }
      });
    } else {}
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = auth.currentUser!.uid;
    await store.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        "message": "Device tidak dapat mengambil GPS.",
        "error": true,
      };
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message": "Izin menggunakan GPS ditolak.",
          "error": true,
        };
        // return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        "message":
            "Settingan hp kamu tidak memperbolehkan untuk mengakses GPS. Ubah pada settingan hp kamu",
        "error": true,
      };
      // return Future.error(
      //   "Location permissions are permanently denied, we can not request permissions.",
      // );
    }

    Position position = await Geolocator.getCurrentPosition();
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device.",
      "error": false,
    };
  }
}
