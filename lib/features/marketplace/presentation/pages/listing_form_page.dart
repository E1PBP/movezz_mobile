import 'package:flutter/material.dart';
import '../../data/models/marketplace_model.dart'; 

class ListingFormPage extends StatefulWidget {
  final Future<void> Function({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
  }) onSubmit;

  // initial values (kalau edit)
  final String? initialTitle;
  final int? initialPrice;
  final String? initialLocation;
  final String? initialImageUrl;
  final Condition? initialCondition;

  const ListingFormPage({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialPrice,
    this.initialLocation,
    this.initialImageUrl,
    this.initialCondition,
  });

  bool get isEdit => initialTitle != null;

  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late final TextEditingController _imageUrlController;

  Condition? _selectedCondition;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialLocation ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialImageUrl ?? '',
    );

    _selectedCondition = widget.initialCondition ?? Condition.USED;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCondition == null) return;

    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
        condition: _selectedCondition!,
      );

      if (!mounted) return;
      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Listing' : 'Create Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Title is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final p = int.tryParse(value.trim());
                  if (p == null || p <= 0) {
                    return 'Price must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Location is required'
                        : null,
              ),
              const SizedBox(height: 12),
                TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Condition>(
                    value: _selectedCondition,
                    items: Condition.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          conditionValues.reverse[c]!, 
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}