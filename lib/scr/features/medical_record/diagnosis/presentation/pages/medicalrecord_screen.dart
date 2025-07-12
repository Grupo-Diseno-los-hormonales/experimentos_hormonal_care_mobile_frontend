import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/usecases/fakechat_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Importa la librería intl para formatear fechas
import 'package:flutter_spinbox/flutter_spinbox.dart'; // Importa la librería flutter_spinbox para usar SpinBox
import 'package:provider/provider.dart';
import '../../../medical_prescription/domain/models/patient_model.dart';
import '../../domain/models/medication_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../domain/models/treatment_model.dart';
import '../../domain/services/medicalrecord_service.dart';
import '../../domain/models/medicationpost_model.dart';
import '../../domain/models/prescriptionpost_model.dart';
import '../../domain/models/medicaltype_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/data/data_sources/remote/communication_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';



class MedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordScreen({required this.patientId});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late Future<Patient> _patientFuture;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 5 pestañas en el TabBar
    _tabController.addListener(_handleTabSelection); // Añadimos un listener para manejar el cambio de pestañas
    _patientFuture = MedicalRecordService().getPatientById(widget.patientId);
    }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Eliminamos el listener cuando ya no se necesite
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para manejar el desplazamiento del TabBar cuando se cambia de pestaña
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      double tabPosition = _tabController.index.toDouble();
      _scrollController.animateTo(
        tabPosition * 120,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Función para mostrar el menú flotante
  void _showPatientInfo(Patient patient) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_getImageUrl(patient.profile?.image)),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    child: patient.profile?.image == null || patient.profile!.image.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 15),
                  _buildInfoField('Full name', patient.profile?.fullName ?? 'Unknown'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoField('Gender', patient.profile?.gender ?? 'Unknown')),
                      SizedBox(width: 10),
                      Expanded(child: _buildInfoField('Birthday', _formatDate(patient.profile?.birthday))),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInfoField('Phone number', patient.profile?.phoneNumber ?? 'Unknown'),
                  SizedBox(height: 10),
                  _buildInfoField('Type of blood', patient.typeOfBlood),
                  SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8F7193), // Color de fondo
                      foregroundColor: Color(0xFFE5DDE6), // Color del texto
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),


                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para construir los campos de información
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Función para formatear la fecha
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Unknown';
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  int calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildPatientHeader(Patient patient) {
    return GestureDetector(
      onTap: () => _showPatientInfo(patient),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8F7193), // Cambiado a tu color de fondo
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_getImageUrl(patient.profile?.image)),
                  backgroundColor: Color(0xFFA788AB), // Color de fondo del avatar
                  child: patient.profile?.image == null || patient.profile!.image.isEmpty
                      ? Icon(Icons.person, color: Color(0xFFE5DDE6)) // Color del ícono
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.profile?.fullName ?? 'Unknown',
                      style: TextStyle(
                        color: Color(0xFFE5DDE6), // Color del texto
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Age: ${calculateAge(patient.profile?.birthday)}',
              style: TextStyle(
                color: Color(0xFFE5DDE6), // Color del texto
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Color(0xFFE5DDE6), // Color del indicador
        labelColor: Color(0xFFA788AB), // Color del texto seleccionado
        unselectedLabelColor: Color(0xFF8F7193), // Color del texto no seleccionado
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: AppLocalizations.of(context)?.patientHistoryTab ?? 'Patient History'),
          Tab(text: AppLocalizations.of(context)?.diagnosisTreatmentsTab ?? 'Diagnosis & Treatments'),
          Tab(text: AppLocalizations.of(context)?.chatWithPatientTab ?? 'Chat with Patient'),
          Tab(text: AppLocalizations.of(context)?.externalReportsTab ?? 'External Reports')
        ],
      ),
    );
  }

 Widget _buildTabBarView(Patient patient) {
  return Expanded(
    child: TabBarView(
      controller: _tabController,
      children: [

        _buildPatientHistoryTab(patient),
        _buildDiagnosisAndTreatmentsTab(patient.id), // Usar el medicalRecordId
        _buildChatWithPatientTab(patient), // Cambiado aquí
        _buildExternalReportsTab(patient.id)
      ],
    ),
  );
}
 Widget _buildPatientHistoryTab(Patient patient) {
   return ListView(
     padding: EdgeInsets.all(16),
     children: [
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(
             AppLocalizations.of(context)?.personalHistoryLabel ?? 'Personal history:',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
             ),
           ),
           IconButton(
             icon: Icon(Icons.edit),
             onPressed: () => _showEditDialog('Personal history', patient.personalHistory, (newValue) {
               _updatePersonalHistory(patient.id, newValue);
             }),
           ),
         ],
       ),
       SizedBox(height: 10),
       Text(
         patient.personalHistory,
         style: TextStyle(fontSize: 16),
       ),
       SizedBox(height: 20),
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(
             AppLocalizations.of(context)?.familyHistoryLabel ?? 'Family history:',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
             ),
           ),
           IconButton(
             icon: Icon(Icons.edit),
             onPressed: () => _showEditDialog('Family history', patient.familyHistory, (newValue) {
               _updateFamilyHistory(patient.id, newValue);
             }),
           ),
         ],
       ),
       SizedBox(height: 10),
       Text(
         patient.familyHistory,
         style: TextStyle(fontSize: 16),
       ),
     ],
   );
 }

void _showEditDialog(String title, String initialValue, Function(String) onSave) {
  final TextEditingController _controller = TextEditingController(text: initialValue);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
         backgroundColor: Color(0xFFE5DDE6), // Fondo del diálogo
         
        title: Text('Edit $title',
        style: TextStyle(color: Color(0xFF8F7193)), // Color del título
        ),
        content: TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8F7193), // Color de fondo
              foregroundColor: Color(0xFFE5DDE6), // Color del texto
            ),
            onPressed: () {
              onSave(_controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

  void _updatePersonalHistory(int patientId, String newPersonalHistory) async {
    try {
      final response = await MedicalRecordService().updatePersonalHistory(patientId, newPersonalHistory);
      if (response.statusCode == 200) {
        setState(() {
          _patientFuture = MedicalRecordService().getPatientById(widget.patientId);
        });
      } else {
        print('Error updating personal history: ${response.body}');
      }
    } catch (e) {
      print('Exception updating personal history: $e');
    }
  }

  void _updateFamilyHistory(int patientId, String newFamilyHistory) async {
    try {
      final response = await MedicalRecordService().updateFamilyHistory(patientId, newFamilyHistory);
      if (response.statusCode == 200) {
        setState(() {
          _patientFuture = MedicalRecordService().getPatientById(widget.patientId);
        });
      } else {
        print('Error updating family history: ${response.body}');
      }
    } catch (e) {
      print('Exception updating family history: $e');
    }
  }

Widget _buildDiagnosisAndTreatmentsTab(int medicalRecordId) {
  print('medicalrecordid: $medicalRecordId');
  return FutureBuilder<List<Medication>>(
    future: MedicalRecordService().getMedicationsByRecordId(medicalRecordId),
    builder: (context, medicationSnapshot) {
      if (medicationSnapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (medicationSnapshot.hasError) {
        return Center(child: Text('Error: ${medicationSnapshot.error}'));
      } else {
        final medications = medicationSnapshot.data ?? [];
        print('Medications: ${medicationSnapshot.data}');

        return FutureBuilder<List<Prescription>>(
          future: MedicalRecordService().getPrescriptionsByRecordId(medicalRecordId),
            builder: (context, prescriptionSnapshot) {
              if (prescriptionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (prescriptionSnapshot.hasError) {
                return Center(child: Text('Error: ${prescriptionSnapshot.error}'));
              } else {
                final prescriptions = prescriptionSnapshot.data ?? [];
                print('Prescriptions: ${prescriptionSnapshot.data}');


                            return FutureBuilder<List<Treatment>>(
                future: MedicalRecordService().getTreatmentsByRecordId(medicalRecordId),
                builder: (context, treatmentSnapshot) {
                  if (treatmentSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    final treatments = treatmentSnapshot.data ?? [];
                    print('Treatments: ${treatmentSnapshot.data}');
                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        // Diagnosis Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFFE5DDE6), // Fondo del contenedor
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.diagnosisLabel ?? 'Diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8F7193), // Color del texto
                                ),
                              ),
                              SizedBox(height: 10),
                              if (prescriptions.isEmpty)
                                Center(
                                  child: Text(
                                    'No prescriptions found. Add one below.',
                                    style: TextStyle(color: Color(0xFFA788AB)), // Color del texto
                                  ),
                                  ),
                                
                              ...prescriptions.map((prescription) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatDate(prescription.prescriptionDate ?? ''),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      prescription.notes ?? 'No notes available',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                              Center(
                                child: ElevatedButton(
                                   style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8F7193), // Color de fondo
                                  foregroundColor: Color(0xFFE5DDE6), // Color del texto
                                ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddPrescriptionDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)?.addDiagnosisButton ?? 'Add Diagnosis'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Medication Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFFE5DDE6), // Fondo del contenedor
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.medicationLabel ?? 'Medication',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8F7193), // Color del texto
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)?.medicationLabel ?? 'Medication',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)?.concentrationLabel ?? 'Concentration',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)?.unitLabel ?? 'Unit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)?.frequencyLabel ?? 'Frequency',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                                                          if (medications.isEmpty)
                                Center(child: Text('No medications found. Add one below.',
                                style: TextStyle(color: Color(0xFFA788AB)), // Color del texto
                                )),
                              ...medications.map((medication) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        medication.drugName ?? 'Unknown',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.quantity ?? '0',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.concentration ?? '0',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.frequency ?? 'Unknown',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              Center(
                                child: ElevatedButton(
                                   style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF8F7193), // Color de fondo
                                        foregroundColor: Color(0xFFE5DDE6), // Color del texto
                                      ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddMedicationDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)?.addMedicationButton ?? 'Add Medication'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Treatment Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFFE5DDE6), // Fondo del contenedor
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.treatmentLabel ?? 'Treatment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8F7193), // Color del texto
                                ),
                              ),
                              SizedBox(height: 10),
                              if (treatments.isEmpty)
                                Center(child: Text('No treatments found. Add one below.',
                                style: TextStyle(color: Color(0xFFA788AB)), // Color del texto
                                )),
                              ...treatments.map((treatment) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      treatment.description ?? 'No description available',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              Center(
                                child: ElevatedButton(
                                   style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8F7193), // Color de fondo
                                    foregroundColor: Color(0xFFE5DDE6), // Color del texto
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddTreatmentDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)?.addTreatmentButton ?? 'Add Treatment'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
}

  Widget _AddMedicationDialog(int medicalRecordId) {
    final _formKey = GlobalKey<FormState>();
    final _medicationPost = MedicationPost(
      medicalRecordId: medicalRecordId,
      medicalTypeId: 0,
      prescriptionId: 0,
      name: '',
      amount: 0,
      unitQ: '',
      value: 0,
      unit: '',
      timesPerDay: 0,
      timePeriod: '',
    );
    Future<List<MedicalType>> _medicalTypesFuture() async {
      return await MedicalRecordService().fetchMedicalTypes();
    }

    Future<List<Prescription>> _fetchPrescriptions() async {
      return await MedicalRecordService().getPrescriptionsByRecordId(medicalRecordId);
    }
  

    
    return AlertDialog(
       backgroundColor: Color(0xFFE5DDE6), // Fondo del diálogo
  title: Text('Add Diagnosis',
  style: TextStyle(color: Color(0xFF8F7193)), // Color del título
  ),
  content: Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<MedicalType>>(
  future: _medicalTypesFuture(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      final medicalTypes = snapshot.data ?? [];
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Medical Type',
          border: OutlineInputBorder(),
        ),
        items: medicalTypes.asMap().entries.map((entry) {
          int index = entry.key;
          MedicalType type = entry.value;
          return DropdownMenuItem<int>(
            value: index + 1, // Sumar 1 al índice
            child: Text(type.typeName),
          );
        }).toList(),
        onChanged: (value) {
          _medicationPost.medicalTypeId = value!;
        },
      );
    }
  },
),
          SizedBox(height: 10),
          FutureBuilder<List<Prescription>>(
            future: _fetchPrescriptions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final prescriptions = snapshot.data ?? [];
                return Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Prescription',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true, // Usar el ancho completo
                    items: prescriptions.map((prescription) {
                       final formattedDate = DateFormat('yyyy-MM-dd').format(
                        DateTime.parse(prescription.prescriptionDate ?? '2025-04-26'),
                      );
                      return DropdownMenuItem<int>(
                        value: prescription.id,
                        child: Row(
                          children: [
                            // Usar Flexible para el texto de las notas y limitar su overflow
                            Flexible(
                              child: Text(
                                prescription.notes ?? 'No notes available', // Valor predeterminado
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            SizedBox(width: 8), // Separación entre texto y fecha
                            // Mostrar fecha completa sin overflow
                            Text(
                              formattedDate,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _medicationPost.prescriptionId = value!;
                    },
                  ),
                );
              }
            },
          ),

          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.name = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.amount = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Unit Quantity',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.unitQ = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.value = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.unit = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Times Per Day',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.timesPerDay = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Time Period',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.timePeriod = value!,
          ),
        ],
      ),
    ),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('Cancel'),
    ),
    ElevatedButton(
       style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8F7193), // Color de fondo
              foregroundColor: Color(0xFFE5DDE6), // Color del texto
            ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          try {
            final response = await MedicalRecordService().addMedication(_medicationPost);
            if (response.statusCode == 200 || response.statusCode == 201) {
              Navigator.of(context).pop();
              setState(() {}); // Recargar la sección de medicamentos
            } else {
              throw Exception('Error posting medication');
            }
          } catch (e) {
            print(e);
          }
        }
      },
      child: Text('Submit'),
    ),
  ],
);

  }

  Widget _AddPrescriptionDialog(int medicalRecordId) {
    final _formKey = GlobalKey<FormState>();
    final _prescriptionPost = PrescriptionPost(
      medicalRecordId: medicalRecordId,
      prescriptionDate: '',
      notes: '',
    );

    TextEditingController _dateController = TextEditingController();

    Future<void> _submitPrescriptionForm() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          final response = await MedicalRecordService().addPrescription(_prescriptionPost);
          print('Response status: ${response.statusCode}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            Navigator.of(context).pop();
            setState(() {}); // Recargar la sección de prescripciones
          } else {
            print('Error posting prescription: ${response.body}');
            throw Exception('Error posting prescription');
          }
        } catch (e) {
          print(e);
        }
      }
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          _prescriptionPost.prescriptionDate = DateFormat('yyyy-MM-dd').format(picked);
          _dateController.text = _prescriptionPost.prescriptionDate;
        });
      }
    }

    return AlertDialog(
       backgroundColor: Color(0xFFE5DDE6), // Fondo del diálogo
      title: Text('Add Prescription',
      style: TextStyle(color: Color(0xFF8F7193)), // Color del título
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Prescription Date',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _prescriptionPost.prescriptionDate = value!,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _prescriptionPost.notes = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
           style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8F7193), // Color de fondo
              foregroundColor: Color(0xFFE5DDE6), // Color del texto
            ),
          onPressed: _submitPrescriptionForm,
          child: Text('Submit'),
        ),
      ],
    );
  }

Widget _AddTreatmentDialog(int medicalRecordId) {
  final _formKey = GlobalKey<FormState>();
  final _treatment = Treatment(
    description: '',
    medicalRecordId: medicalRecordId,
  );

  Future<void> _submitTreatmentForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await MedicalRecordService().addTreatment(_treatment);
        print('Response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.of(context).pop();
          setState(() {}); // Recargar la sección de tratamientos
        } else {
          print('Error posting treatment: ${response.body}');
          throw Exception('Error posting treatment');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  return AlertDialog(
    backgroundColor: Color(0xFFE5DDE6), // Fondo del diálogo
    title: Text('Add Treatment',
    style: TextStyle(color: Color(0xFF8F7193)), // Color del título
    ),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Color(0xFF8F7193)), // Color del label
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _treatment.description = value!,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancel'),
      ),
      ElevatedButton(
         style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8F7193), // Color de fondo
              foregroundColor: Color(0xFFE5DDE6), // Color del texto
            ),
        onPressed: _submitTreatmentForm,
        child: Text('Submit'),
      ),
    ],
  );
}


Widget _buildChatWithPatientTab(Patient patient) {
  return FutureBuilder<int?>(
    future: JwtStorage.getProfileId(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      final doctorProfileId = snapshot.data!;
      final patientProfileId = patient.profile?.id ?? 0;
      return _ChatLocalWidget(
        doctorProfileId: doctorProfileId,
        patientProfileId: patientProfileId,
      );
    },
  );
}


// External Reports Tab
Widget _buildExternalReportsTab(int patientId) {
  return Stack(
    children: [
      FutureBuilder<List<Map<String, String>>>(
        // TODO: Reactivar esta línea cuando Firebase esté configurado correctamente
        // future: FirebaseStorageService().getExternalReports(patientId),
        future: Future.value([]), // Temporalmente devuelve una lista vacía
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)?.noExternalReportsMessage ?? 'No external reports found'));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                // TODO: Reactivar esta sección cuando Firebase esté configurado correctamente
                /*
                return FutureBuilder<DateTime?>(
                  future: _getExternalReportModificationDate(patientId, report['name']!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final modificationDate = snapshot.data;
                      return _buildReportItem(report['name']!, report['url']!, modificationDate, patientId);
                    }
                  },
                );
                */
                return _buildReportItem(report['name']!, report['url']!, null, patientId); // Temporalmente sin fecha
              },
            );
          }
        },
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          // TODO: Reactivar esta línea cuando Firebase esté configurado correctamente
          // onPressed: () => _uploadExternalReport(patientId),
          onPressed: () {}, // Temporalmente deshabilitado
          backgroundColor: Colors.grey[300], // Color de fondo gris claro
          child: Icon(Icons.upload),
        ),
      ),
    ],
  );
}
Widget _buildReportItem(String reportName, String url, DateTime? modificationDate, int patientId) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reportName,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              if (modificationDate != null)
                Text(
                  DateFormat('yyyy-MM-dd').format(modificationDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.download, size: 24, color: Colors.blue),
              // TODO: Reactivar esta línea cuando Firebase esté configurado correctamente
              // onPressed: () async {
              //   await _downloadExternalReport(url, reportName);
              // },
              onPressed: () {}, // Temporalmente deshabilitado
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 24, color: Colors.red),
              // TODO: Reactivar esta línea cuando Firebase esté configurado correctamente
              // onPressed: () async {
              //   await _deleteExternalReport(patientId, reportName);
              // },
              onPressed: () {}, // Temporalmente deshabilitado
            ),
          ],
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
        title: Text(
          'Medical record',
          style: TextStyle(
            color: Color(0xFFE5DDE6), // Color del texto
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF8F7193), // Color de fondo
        iconTheme: IconThemeData(color: Color(0xFFE5DDE6)), // Color de los íconos
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final patient = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(patient),
                  SizedBox(height: 20),
                  _buildTabBar(),
                  SizedBox(height: 20),
                  _buildTabBarView(patient),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Función para obtener la URL de la imagen
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    if (!imageUrl.startsWith('http')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }
}

class _ChatLocalWidget extends StatefulWidget {
  final int doctorProfileId;
  final int patientProfileId;

  const _ChatLocalWidget({
    required this.doctorProfileId,
    required this.patientProfileId,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatLocalWidget> createState() => _ChatLocalWidgetState();
}

class _ChatLocalWidgetState extends State<_ChatLocalWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await FakeChatApi.getMessages(widget.doctorProfileId, widget.patientProfileId);
    setState(() {
      _messages = msgs;
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final msg = {
      'text': text,
      'senderProfileId': widget.doctorProfileId,
      'receiverProfileId': widget.patientProfileId,
      'sentAt': DateTime.now().toIso8601String(),
    };
    await FakeChatApi.addMessage(widget.doctorProfileId, widget.patientProfileId, msg);
    _controller.clear();
    await _loadMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

 // Reemplazar el método build de _ChatLocalWidgetState:
@override
Widget build(BuildContext context) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      if (_loading) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8F7193)),
          ),
        );
      }
      
      return Column(
        children: [
          // Header del chat
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? Color(0xFF2D2D2D)
                  : Color(0xFF8F7193),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: themeProvider.isDarkMode 
                      ? Color(0xFF8F7193)
                      : Color(0xFFA788AB),
                  child: Icon(
                    Icons.chat,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Chat with Patient',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Área de mensajes
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                    ? Color(0xFF1A1A1A) 
                    : Colors.grey[50],
                border: Border.all(
                  color: themeProvider.isDarkMode 
                      ? Colors.white12 
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: themeProvider.isDarkMode 
                                ? Colors.white54 
                                : Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: TextStyle(
                              color: themeProvider.isDarkMode 
                                  ? Colors.white70 
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) {
                        final msg = _messages[idx];
                        final isDoctor = msg['senderProfileId'] == widget.doctorProfileId;
                        final timestamp = msg['sentAt'] != null 
                            ? DateTime.tryParse(msg['sentAt']) 
                            : null;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isDoctor 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isDoctor) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFF4CAF50),
                                  child: Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isDoctor 
                                      ? CrossAxisAlignment.end 
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isDoctor 
                                            ? Color(0xFF8F7193)
                                            : (themeProvider.isDarkMode 
                                                ? Color(0xFF3A3A3A) 
                                                : Colors.white),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(isDoctor ? 16 : 4),
                                          bottomRight: Radius.circular(isDoctor ? 4 : 16),
                                        ),
                                        border: !isDoctor ? Border.all(
                                          color: themeProvider.isDarkMode 
                                              ? Colors.white24 
                                              : Colors.grey.withOpacity(0.3),
                                        ) : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeProvider.isDarkMode 
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        msg['text'] ?? '',
                                        style: TextStyle(
                                          // ✅ TEXTO LEGIBLE EN AMBOS MODOS
                                          color: isDoctor 
                                              ? Colors.white // Doctor: blanco sobre morado
                                              : (themeProvider.isDarkMode 
                                                  ? Colors.white // Paciente modo oscuro: blanco sobre gris oscuro
                                                  : Colors.black87), // Paciente modo claro: negro sobre blanco
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (timestamp != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('hh:mm a').format(timestamp),
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode 
                                              ? Colors.white54 
                                              : Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isDoctor) ...[
                                SizedBox(width: 6),
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFF8F7193),
                                  child: Icon(
                                    Icons.medical_services,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          // Divisor
          Container(
            height: 1,
            color: themeProvider.isDarkMode 
                ? Colors.white24 
                : Colors.grey.withOpacity(0.3),
          ),
          
          // Input para escribir mensaje
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? Color(0xFF2D2D2D)
                  : Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? Color(0xFF1A1A1A) 
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: themeProvider.isDarkMode 
                            ? Colors.white24 
                            : Colors.transparent,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: themeProvider.isDarkMode 
                            ? Colors.white 
                            : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.typeMessageHint ?? 'Type a message...',
                        hintStyle: TextStyle(
                          color: themeProvider.isDarkMode 
                              ? Colors.white54 
                              : Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF8F7193),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
}