import 'package:flutter/material.dart';

import '../../data/models/marketplace_model.dart';

class ListingFormPage extends StatefulWidget {
  final MarketplaceModel? initial;
  final Future<void> Function({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
  })? onSubmit;

  const ListingFormPage({
    super.key,
    this.initial,
    this.onSubmit,
  });

  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late final TextEditingController _imageUrlController;

  Condition _selectedCondition = Condition.USED;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final initialFields = widget.initial?.fields;

    _titleController = TextEditingController(text: initialFields?.title ?? '');
    _priceController =
        TextEditingController(text: initialFields?.price.toString() ?? '');
    _locationController =
        TextEditingController(text: initialFields?.location ?? '');
    _imageUrlController =
        TextEditingController(text: initialFields?.imageUrl ?? '');

    _selectedCondition = initialFields?.condition ?? Condition.USED;
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

    final title = _titleController.text.trim();
    final price = int.parse(_priceController.text.trim());
    final location = _locationController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final condition = _selectedCondition;

    setState(() {
      _isSubmitting = true;
    });

        try {
      if (widget.onSubmit != null) {
        // Mode pakai callback async
        await widget.onSubmit!.call(
          title: title,
          price: price,
          location: location,
          imageUrl: imageUrl,
          condition: condition,
        );
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          Navigator.pop(context, {
            'title': title,
            'price': price,
            'location': location,
            'image_url': imageUrl,
            'condition': conditionValues.reverse[condition],
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Listing' : 'Add Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Ex: Soccer Shoes',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  hint: 'Ex: 250000',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price cannot be empty';
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Ex: Depok',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Location cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Image URL (optional)',
                  hint: 'https://example.com/image.jpg',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    if (!value.startsWith('http')) {
                      return 'URL invalid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionDropdown(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save Changes' : 'Add Listing'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<Condition>(
      value: _selectedCondition,
      decoration: const InputDecoration(
        labelText: 'Condition',
        border: OutlineInputBorder(),
      ),
      items: Condition.values.map((c) {
        final text = c == Condition.BRAND_NEW ? 'New' : 'Used';
        return DropdownMenuItem(
          value: c,
          child: Text(text),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedCondition = value;
        });
      },
    );
  }
}