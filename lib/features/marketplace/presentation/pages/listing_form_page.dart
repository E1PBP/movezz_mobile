import 'package:flutter/material.dart';
import '../../data/models/marketplace_model.dart';

class ListingFormPage extends StatefulWidget {
  final Future<void> Function({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    required String description,
  })
  onSubmit;

  // initial values (kalau edit)
  final String? initialTitle;
  final int? initialPrice;
  final String? initialLocation;
  final String? initialImageUrl;
  final Condition? initialCondition;
  final String? initialDescription;

  const ListingFormPage({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialPrice,
    this.initialLocation,
    this.initialImageUrl,
    this.initialCondition,
    this.initialDescription,
  });

  String conditionLabel(Condition c) {
    switch (c) {
      case Condition.BRAND_NEW:
        return 'Brand New';
      case Condition.USED:
        return 'Used';
    }
  }

  bool get isEdit => initialTitle != null;

  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  late Condition _selectedCondition;

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
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _selectedCondition = widget.initialCondition ?? Condition.USED;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        title: _titleController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        location: _locationController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        condition: _selectedCondition,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(title: Text(isEdit ? 'Edit Listing' : 'Create Listing')),
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
                validator: (value) => (value == null || value.trim().isEmpty)
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
                validator: (value) => (value == null || value.trim().isEmpty)
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
                    dropdownColor: Colors.grey[100],
                    isExpanded: true,
                    items: Condition.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(widget.conditionLabel(c)), 
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCondition = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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
