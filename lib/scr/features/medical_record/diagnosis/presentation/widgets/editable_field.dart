import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/presentation/widgets/edit_modal.dart';

class EditableField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onSave;

  const EditableField({
    required this.label,
    required this.value,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value.isEmpty ? 'Enter $label' : value,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF8F7193), // Texto morado oscuro
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFA788AB)), // Icono morado intermedio
          onPressed: () {
            _showEditModal(context, label, value, onSave);
          },
        ),
      ],
    );
  }

  void _showEditModal(
    BuildContext context,
    String label,
    String currentValue,
    Function(String) onSave,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditModal(
          title: 'Edit $label',
          currentValue: currentValue,
          onSave: onSave,
        );
      },
    );
  }
}