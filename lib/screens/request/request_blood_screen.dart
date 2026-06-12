import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/blood_request_model.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../constants/app_colors.dart';

// RequestBloodScreen is where a user posts a new blood request.
// It pre-fills blood group and city from the logged-in user's profile
// (because usually the person posting IS the patient or family member).
class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _cityController     = TextEditingController();
  final _unitsController    = TextEditingController(text: '1');

  String? _selectedBloodGroup;
  String _selectedUrgency = Urgency.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        _cityController.text = user.city;
        setState(() => _selectedBloodGroup = user.bloodGroup);
      }
    });
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _cityController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    final success = await context.read<RequestProvider>().postRequest(
          poster: user,
          bloodGroup: _selectedBloodGroup!,
          hospital: _hospitalController.text.trim(),
          city: _cityController.text.trim(),
          unitsNeeded: int.parse(_unitsController.text.trim()),
          urgency: _selectedUrgency,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request posted! Donors will be notified.'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _hospitalController.clear();
        _unitsController.text = '1';
        setState(() => _selectedUrgency = Urgency.normal);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post request. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = context.watch<RequestProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fill in the details below',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Blood group needed
              const Text('Blood Group Needed',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.water_drop),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: BloodGroups.all
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) => v == null ? 'Select blood group' : null,
              ),
              const SizedBox(height: 16),

              // Hospital
              const Text('Hospital',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  hintText: 'e.g. AIIMS Delhi',
                  prefixIcon: const Icon(Icons.local_hospital),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    Validators.required(v, fieldName: 'Hospital name'),
              ),
              const SizedBox(height: 16),

              // City
              const Text('City',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => Validators.required(v, fieldName: 'City'),
              ),
              const SizedBox(height: 16),

              // Units needed
              const Text('Units Needed',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _unitsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: Validators.units,
              ),
              const SizedBox(height: 16),

              // Urgency selector
              const Text('Urgency Level',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: Urgency.all.map((level) {
                  final isSelected = _selectedUrgency == level;
                  Color color;
                  switch (level) {
                    case Urgency.critical: color = Colors.red.shade700; break;
                    case Urgency.urgent:   color = AppColors.warning;   break;
                    default:               color = AppColors.success;   break;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedUrgency = level),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              level,
                              style: TextStyle(
                                color: isSelected ? color : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Submit Request',
                onPressed: _submit,
                isLoading: requestProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
