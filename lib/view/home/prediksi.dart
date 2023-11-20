import 'dart:convert';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:janin/provider/auth.dart';
import 'package:janin/provider/prediksi.dart';
import 'package:janin/view/home/navbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme.dart';

// OpsiRadio
enum selectedRadiohamil { yes, no, others, n }

enum selectedRadioAlchohol { yes, no, others, n }

enum selectedRadioSmoker { yes, no, others, n }

enum selectedRadioDrugs { yes, no, others, n }

enum selectedRadioPoluted { yes, no, others, n }

enum selectedRadioBleedingAfter { yes, no, others, n }

enum selectedRadioBleedingWhile { yes, no, others, n }

enum selectedRadioGadget { yes, no, others, n }

enum selectedRadioAbnormalities { yes, no, others, n }

enum selectedRadioAllergy { yes, no, others, n }

enum selectedRadioCaesar { yes, no, others, n }

class PrediksiForm extends StatefulWidget {
  const PrediksiForm({super.key});

  @override
  State<PrediksiForm> createState() => _PrediksiFormState();
}

class _PrediksiFormState extends State<PrediksiForm> {
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController gestationalAgeController =
      TextEditingController();
  final TextEditingController caesarHistoryController = TextEditingController();
  String result = "";

  // Inisialisasi variabel untuk menyimpan nilai pembobotan
  int score = 0;

  // List DropDown Golongan Darah
  String? selectedBloodtype;
  List<String> bloodType = [
    "A",
    "B",
    "AB",
    "O",
    "Tidak Tahu",
  ];

  // List Dropdown Jenis Rhesus
  String? selectedRhesus;
  List<String> Rhesus = [
    "Positif (+)",
    "Negatif (-)",
    "Tidak Tahu",
  ];

  // List Dropdown Hamil ke Berapa
  String? selectedHamil;
  List<String> Hamil = [
    "Ke-1",
    "Ke-2",
    "Ke-3",
    "Ke-4",
    "Lebih dari 4",
  ];

  // List Dropdown Jumlah Persalinan
  String? selectedLahir;
  List<String> Lahir = [
    "1",
    "2",
    "3",
    "4",
    "Lebih dari 4",
  ];

  // List dropdown jumlah keguguran
  String? selectedGugur;
  List<String> Gugur = [
    "0",
    "1",
    "2",
    "3",
    "Lebih dari 3",
  ];

  // RadioButtonForm
  selectedRadiohamil _radioBtnform1 = selectedRadiohamil.n;
  selectedRadioAlchohol _radioBtnform2 = selectedRadioAlchohol.n;
  selectedRadioSmoker _radioBtnform3 = selectedRadioSmoker.n;
  selectedRadioDrugs _radioBtnform4 = selectedRadioDrugs.n;
  selectedRadioPoluted _radioBtnform5 = selectedRadioPoluted.n;
  selectedRadioBleedingAfter _radioBtnform6 = selectedRadioBleedingAfter.n;
  selectedRadioBleedingWhile _radioBtnform7 = selectedRadioBleedingWhile.n;
  selectedRadioGadget _radioBtnform8 = selectedRadioGadget.n;
  selectedRadioAbnormalities _radioBtnform9 = selectedRadioAbnormalities.n;
  selectedRadioAllergy _radioBtnform10 = selectedRadioAllergy.n;
  selectedRadioCaesar _radioBtnform11 = selectedRadioCaesar.n;

  // checkboxformValues
  List<Map> sicknessCategories = [
    {'name': 'Anemia', 'isChecked': false},
    {'name': 'Preeklampsi', 'isChecked': false},
    {'name': 'Hipertensi', 'isChecked': false},
    {'name': 'Diabetes', 'isChecked': false},
    {'name': 'Paru-paru', 'isChecked': false},
    {'name': 'Ginjal', 'isChecked': false},
    {'name': 'Jantung', 'isChecked': false},
    {'name': 'Lainnya', 'isChecked': false},
    {'name': 'Tidak ada', 'isChecked': false},
  ];

  List<Map> inheritedSickness = [
    {'name': 'Anemia', 'isChecked': false},
    {'name': 'Preeklampsi', 'isChecked': false},
    {'name': 'Hipertensi', 'isChecked': false},
    {'name': 'Diabetes', 'isChecked': false},
    {'name': 'Paru-paru', 'isChecked': false},
    {'name': 'Ginjal', 'isChecked': false},
    {'name': 'Jantung', 'isChecked': false},
    {'name': 'Lainnya', 'isChecked': false},
    {'name': 'Tidak ada', 'isChecked': false},
  ];

  Future<void> predictJanin() async {
    final url =
        'http://153.92.4.162:5001/predict'; // Ganti dengan alamat Flask server
    final headers = {'Content-Type': 'application/json'};
    final data = {
      'bloodType': bloodTypeController.text,
      'gestationalAge': gestationalAgeController.text,
      'caesarHistory': caesarHistoryController.text,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      PrediksiProvider prediksiProvider =
          Provider.of<PrediksiProvider>(context, listen: false);
      Auth auth = Provider.of<Auth>(context, listen: false);

      final responseData = jsonDecode(response.body);
      setState(() {
        prediksiProvider.setResult(
          responseData['result'] == 1 ? 'normal' : 'kurang baik',
        );

        // firestore
        FirebaseFirestore.instance.collection("hasil_prediksi").add({
          'id': auth.id,
          'result': prediksiProvider.result,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } else {
      setState(() {
        result = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: pinkColor,
          ),
        ),
        title: Text(
          'Prediksi Janin',
          style: appBarStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: whiteColor,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Usia Ibu Hamil (Tahun)',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  // Tooltip_fitur1
                  Tooltip(
                    message: 'Isikan usia atau umur ibu hamil.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),

              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: bloodTypeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Contoh: 23',
                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                ),
                // Logika untuk menentukan nilai pembobotan usiaIbu
                onChanged: (value) {
                  // Konversi nilai usia ibu ke tipe data integer
                  int usiaIbu = int.tryParse(value) ?? 0;

                  if (usiaIbu < 20 || usiaIbu > 35) {
                    // Jika usia ibu kurang dari 20 atau lebih dari 35, tambahkan skor
                    score += 1;
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Usia Kandungan (Minggu)',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur2
                  Tooltip(
                    message: 'Isikan minggu kehamilan.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: gestationalAgeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Contoh: 23',
                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                ),
                // Logika untuk menentukan nilai pembobotan usiaKandungan
                onChanged: (value) {
                  // Konversi nilai usia ibu ke tipe data integer
                  int usiaKandungan = int.tryParse(value) ?? 0;

                  if (usiaKandungan < 4 || usiaKandungan > 42) {
                    // Jika usia ibu kurang dari 20 atau lebih dari 42, tambahkan skor
                    score += 1;
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Golongan Darah',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur3
                  Tooltip(
                    message: 'Pilih golongan darah ibu hamil.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16), // padding text in box
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String?>(
                  hint: Text("Pilih golongan darah"),
                  underline: SizedBox(),
                  isExpanded: true,
                  value: selectedBloodtype,
                  onChanged: (value) {
                    setState(() {
                      selectedBloodtype = value;

                      // Logika untuk menentukan nilai pembobotan untuk golonganDarah
                      if (selectedBloodtype == "Tidak Tahu") {
                        // Jika golongan darah adalah "Tidak Tahu", tambahkan skor
                        score += 1;
                      }
                    });
                  },
                  items: bloodType
                      .map((e) => DropdownMenuItem(
                            child: Text(e.toString()),
                            value: e,
                          ))
                      .toList(),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Rhesus',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur4
                  Tooltip(
                    message: 'Pilih rhesus ibu hamil.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16), // padding text in box
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String?>(
                  hint: Text("Pilih opsi"),
                  underline: SizedBox(),
                  isExpanded: true,
                  value: selectedRhesus,
                  onChanged: (value) {
                    setState(() {
                      selectedRhesus = value;

                      // Logika untuk menentukan nilai pembobotan untuk rhesusDarah
                      if (selectedRhesus == "Tidak Tahu") {
                        // Jika rhesus adalah "Tidak Tahu", tambahkan skor
                        score += 1;
                      }
                    });
                  },
                  items: Rhesus.map((e) => DropdownMenuItem(
                        child: Text(e.toString()),
                        value: e,
                      )).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Hamil ke Berapa',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur5
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16), // padding text in box
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String?>(
                  hint: Text("Pilih opsi"),
                  underline: SizedBox(),
                  isExpanded: true,
                  value: selectedHamil,
                  onChanged: (value) {
                    setState(() {
                      selectedHamil = value;

                      // Logika untuk menentukan nilai pembobotan hamilKeberapa
                      if (selectedHamil != null &&
                          int.tryParse(selectedHamil!)! >= 4) {
                        // Jika "hamil keberapa" lebih besar atau sama dengan 4, tambahkan skor
                        score += 1;
                      }
                    });
                  },
                  items: Hamil.map((e) => DropdownMenuItem(
                        child: Text(e.toString()),
                        value: e,
                      )).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Jumlah Persalinan',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur6
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16), // padding text in box
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String?>(
                  hint: Text("Pilih opsi"),
                  underline: SizedBox(),
                  isExpanded: true,
                  value: selectedLahir,
                  onChanged: (value) {
                    setState(() {
                      selectedLahir = value;

                      // Logika untuk menentukan nilai pembobotan jumlahPersalinan
                      if (selectedLahir != null &&
                          int.tryParse(selectedLahir!)! >= 4) {
                        // Jika "jumlah persalinan" lebih besar atau sama dengan 4, tambahkan skor
                        score += 1;
                      }
                    });
                  },
                  items: Lahir.map((e) => DropdownMenuItem(
                        child: Text(e.toString()),
                        value: e,
                      )).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Jumlah Keguguran',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur7
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15)),
                child: DropdownButton<String?>(
                  hint: Text("Pilih opsi"),
                  underline: SizedBox(),
                  isExpanded: true,
                  value: selectedGugur,
                  onChanged: (value) {
                    setState(() {
                      selectedGugur = value;

                      // Logika untuk menentukan nilai pembobotan jumlahKegugugran
                      if (selectedGugur != null &&
                          int.tryParse(selectedGugur!)! >= 3) {
                        // Jika "hamil keberapa" lebih besar atau sama dengan 4, tambahkan skor
                        score += 1;
                      }
                    });
                  },
                  items: Gugur.map((e) => DropdownMenuItem(
                        child: Text(e.toString()),
                        value: e,
                      )).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Kehamilan Ini Diinginkan?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur8
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-1
              Row(
                children: [
                  Radio(
                      value: selectedRadiohamil.yes,
                      groupValue: _radioBtnform1,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadiohamil) {
                        setState(() {
                          _radioBtnform1 = selectedRadiohamil!;
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadiohamil.no,
                      groupValue: _radioBtnform1,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadiohamil) {
                        setState(() {
                          _radioBtnform1 = selectedRadiohamil!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Pengguna Alkohol?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur9
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-2
              Row(
                children: [
                  Radio(
                      value: selectedRadioAlchohol.yes,
                      groupValue: _radioBtnform2,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform2 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan penggunaAlkohol
                          if (_radioBtnform2 == selectedRadioAlchohol.yes) {
                            // Jika "pengguna alkohol" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioAlchohol.no,
                      groupValue: _radioBtnform2,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform2 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Perokok?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur10
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-3
              Row(
                children: [
                  Radio(
                      value: selectedRadioSmoker.yes,
                      groupValue: _radioBtnform3,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform3 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan perokok
                          if (_radioBtnform3 == selectedRadioSmoker.yes) {
                            // Jika "perokok" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioSmoker.no,
                      groupValue: _radioBtnform3,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform3 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Pengguna Narkoba?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur11
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-4
              Row(
                children: [
                  Radio(
                      value: selectedRadioDrugs.yes,
                      groupValue: _radioBtnform4,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform4 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan penggunaNarkoba
                          if (_radioBtnform4 == selectedRadioDrugs.yes) {
                            // Jika "pengguna narkoba" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioDrugs.no,
                      groupValue: _radioBtnform4,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform4 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Sering Terpapar Polusi?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur12
                  Tooltip(
                    message:
                        'Seperti: \nasap rokok, asap kendaraan (mengendarai motor), lingkungan (air, udara).',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 3),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-5
              Row(
                children: [
                  Radio(
                      value: selectedRadioPoluted.yes,
                      groupValue: _radioBtnform5,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform5 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan terpaparPolusi
                          if (_radioBtnform5 == selectedRadioPoluted.yes) {
                            // Jika "sering terpapar polusi" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioPoluted.no,
                      groupValue: _radioBtnform5,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform5 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Apakah Anda Memiliki Riwayat Pendarahan Pasca Persalinan?',
                      style: labelText,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur13
                  Tooltip(
                    message: 'Pilih "Ya" jika ada tindakan pasca persalinan.\n'
                        'Misalkan: pasang infus.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-6
              Row(
                children: [
                  Radio(
                      value: selectedRadioBleedingAfter.yes,
                      groupValue: _radioBtnform6,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform6 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan pendarahanPascaPersalinan
                          if (_radioBtnform6 ==
                              selectedRadioBleedingAfter.yes) {
                            // Jika "pernah memiliki riwayat pendarahan pasca persalinan" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioBleedingAfter.no,
                      groupValue: _radioBtnform6,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform6 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Apakah Anda Pernah Mengalami Pendarahan Ketika Hamil?',
                      style: labelText,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur14
                  Tooltip(
                    message:
                        'Pilih "Ya" jika flek atau ada perlakuan tindakan.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-7
              Row(
                children: [
                  Radio(
                      value: selectedRadioBleedingWhile.yes,
                      groupValue: _radioBtnform7,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform7 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan pendarahanKetikaHamil
                          if (_radioBtnform7 ==
                              selectedRadioBleedingWhile.yes) {
                            // Jika "pernah mengalami pendarahan ketika hamil" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioBleedingWhile.no,
                      groupValue: _radioBtnform7,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform7 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Sering Menggunakan Gadget?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur15
                  Tooltip(
                    message: 'Alat elektronik, terutama Handphone.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-8
              Row(
                children: [
                  Radio(
                      value: selectedRadioGadget.yes,
                      groupValue: _radioBtnform8,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform8 = selectedRadio!;
                        });

                        // Logika untuk menentukan nilai pembobotan penggunaGagdet
                        if (_radioBtnform8 == selectedRadioGadget.yes) {
                          // Jika "sering menggunakan gadget" adalah Ya, tambahkan skor
                          score += 1;
                        }
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioGadget.no,
                      groupValue: _radioBtnform8,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform8 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Apakah Anda Memiliki Riwayat Kelainan Bawaan?',
                      style: labelText,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur16
                  Tooltip(
                    message:
                        'Jika mengalami gejala alergi, seperti:\ngatal-gatal, bintik merah di kulit, muntah-muntah.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 5),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-9
              Row(
                children: [
                  Radio(
                      value: selectedRadioAbnormalities.yes,
                      groupValue: _radioBtnform9,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform9 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan kelainanBawaan
                          if (_radioBtnform9 ==
                              selectedRadioAbnormalities.yes) {
                            // Jika "memiliki kelainan bawaan" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioAbnormalities.no,
                      groupValue: _radioBtnform9,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform9 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Memiliki Riwayat Alergi?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur17
                  Tooltip(
                    message:
                        'Pilih "Ya" jika pernah mengalami gatal yang berlebih.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-10
              Row(
                children: [
                  Radio(
                      value: selectedRadioAllergy.yes,
                      groupValue: _radioBtnform10,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform10 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan riwayatAlergi
                          if (_radioBtnform10 == selectedRadioAllergy.yes) {
                            // Jika "memiliki riwayat alergi" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioAllergy.no,
                      groupValue: _radioBtnform10,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform10 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Apakah Anda Pernah Operasi Caesar?',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur18
                  Tooltip(
                    message: 'Tindakan operasi persalinan.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),

              // radioForm-11
              Row(
                children: [
                  Radio(
                      value: selectedRadioCaesar.yes,
                      groupValue: _radioBtnform11,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform11 = selectedRadio!;

                          // Logika untuk menentukan nilai pembobotan operasiCaesar
                          if (_radioBtnform11 == selectedRadioCaesar.yes) {
                            // Jika "pernah operasi caesar" adalah Ya, tambahkan skor
                            score += 1;
                          }
                        });
                      }),
                  Text("Ya"),
                  Padding(
                    padding: EdgeInsets.only(left: 75),
                  ),
                  Radio(
                      value: selectedRadioCaesar.no,
                      groupValue: _radioBtnform11,
                      activeColor: Colors.redAccent,
                      onChanged: (selectedRadio) {
                        setState(() {
                          _radioBtnform11 = selectedRadio!;
                        });
                      }),
                  Text("Tidak"),
                ],
              ),
              SizedBox(
                height: 20,
              ),

              Row(
                children: [
                  Text(
                    'Jumlah Riwayat Caesar (Isi 0 Bila Tidak Pernah)',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur19
                  Tooltip(
                    message: 'Jelas.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: caesarHistoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Contoh: 0',
                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              // checkboxTitle-1
              Row(
                children: [
                  Text(
                    'Riwayat Penyakit:',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur20
                  Tooltip(
                    message: 'Pilih "Lainnya" jika tidak ada di dalam list.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              // checkbox-1
              Column(
                  children: sicknessCategories.map((sick) {
                return CheckboxListTile(
                    activeColor: Colors.redAccent,
                    title: Text(sick['name']),
                    value: sick['isChecked'],
                    onChanged: (val) {
                      setState(() {
                        sick['isChecked'] = val;

                        // Logika untuk menentukan nilai pembobotan riwayatPenyakit
                        if (sick['isChecked'] && sick['name'] != 'Tidak Ada') {
                          // Jika riwayat penyakit selain 'Tidak Ada', tambahkan skor
                          score += 1;
                        }
                      });
                    });
              }).toList()),

              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 20,
              ),

              // checkboxTitle-2
              Row(
                children: [
                  Text(
                    'Penyakit Keturunan:',
                    style: labelText,
                  ),
                  SizedBox(
                    width: 5,
                  ),

                  //Tooltip_fitur21
                  Tooltip(
                    message: 'Pilih "Lainnya" jika tidak ada di dalam list.',
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 30,
                      width: 20,
                      child: Icon(
                        Icons.info_outline,
                        color: pinkColor,
                      ),
                    ),
                    showDuration: Duration(seconds: 4),
                    waitDuration: Duration(seconds: 1),
                    triggerMode: TooltipTriggerMode.tap,
                    textStyle: labelText.copyWith(color: Colors.white),
                    preferBelow: false,
                    verticalOffset: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // checkbox-2
              Column(
                  children: inheritedSickness.map((inherited) {
                return CheckboxListTile(
                    activeColor: Colors.redAccent,
                    title: Text(inherited['name']),
                    value: inherited['isChecked'],
                    onChanged: (val) {
                      setState(() {
                        inherited['isChecked'] = val;

                        // Logika untuk menentukan nilai pembobotan penyakitKeturunan
                        if (inherited['isChecked'] &&
                            inherited['name'] != 'Tidak Ada') {
                          // Jika penyakit keturunan selain 'Tidak Ada', tambahkan skor
                          score += 1;
                        }
                      });
                    });
              }).toList()),

              const Divider(
                color: Colors.grey,
              ),

              // submitButton
              SizedBox(height: 16),
              Center(
                child: Container(
                  width: 277,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: pinkColor,
                    ),
                    onPressed: () {
                      predictJanin();
                      showDialog(
                        context: context,
                        builder: (context) {
                          final prediksiProvider =
                              Provider.of<PrediksiProvider>(context,
                                  listen: false);
                          return AlertDialog(
                            title: Text('Hasil Prediksi'),
                            content: Text(
                              "Janin anda dalam keadaan: ${score}",
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: pinkColor,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Navbar(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Baik',
                                  style: buttonText.copyWith(
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Prediksi',
                      style: buttonText.copyWith(
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}