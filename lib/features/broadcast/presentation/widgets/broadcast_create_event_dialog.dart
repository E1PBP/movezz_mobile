import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/broadcast_controller.dart';

class BroadcastCreateEventDialog extends StatefulWidget {
  const BroadcastCreateEventDialog({super.key});

  @override
  State<BroadcastCreateEventDialog> createState() =>
      _BroadcastCreateEventDialogState();
}

class _BroadcastCreateEventDialogState
    extends State<BroadcastCreateEventDialog> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationLatController = TextEditingController();
  final _locationLngController = TextEditingController();
  final _rsvpController = TextEditingController();
  final _feeController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMime;
  String? _selectedImageName;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _locationLatController.dispose();
    _locationLngController.dispose();
    _rsvpController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ScaffoldMessenger(
      child: Builder(
        builder: (messengerContext) => Scaffold(
          backgroundColor: Colors.black.withOpacity(0.07),
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: size.width,
              height: size.height,
              color: Colors.transparent,
              child: Center(

                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: bottomInset > 0 ? bottomInset + 20 : 20,
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.85,
                      maxWidth: 500,
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaleFactor: 0.85),
                      child: AlertDialog(
                        backgroundColor: Colors.white,
                        titleTextStyle: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          24,
                          20,
                          24,
                          0,
                        ),
                        insetPadding: EdgeInsets.zero,
                        title: const Text('Create Event'),
                        content: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTextField(
                                    _descriptionController,
                                    'Description',
                                    maxLines: 4,
                                    labelIcon: Icons.notes,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildImageSection(),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    _locationController,
                                    'Location name',
                                    labelIcon: Icons.location_on,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildCoordinatesRow(),
                                  const SizedBox(height: 16),
                                  _buildDateTimeTile('Start time', _startTime, (
                                    dt,
                                  ) {
                                    setState(() => _startTime = dt);
                                  }),
                                  _buildDateTimeTile('End time', _endTime, (
                                    dt,
                                  ) {
                                    setState(() => _endTime = dt);
                                  }),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    _feeController,
                                    'Fee',
                                    keyboardType: TextInputType.number,
                                    labelIcon: Icons.attach_money,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    _rsvpController,
                                    'RSVP link',
                                    labelIcon: Icons.event_available,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actionsPadding: EdgeInsets.zero,
                        actionsAlignment: MainAxisAlignment.end,
                        actions: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 36,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 60,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _handleCreateEvent(messengerContext),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Create',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add Image',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImageBytes != null) _buildImagePreview(),
        _buildImagePicker(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _selectedImageBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 16,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clearImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),
            const SizedBox(width: 8),
            if (_selectedImageBytes != null)
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
          ],
        ),
        if (_selectedImageBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _selectedImageName != null
                  ? 'Selected: $_selectedImageName'
                  : 'Image selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildCoordinatesRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            _locationLatController,
            'Latitude (optional)',
            keyboardType: TextInputType.number,
            labelIcon: Icons.explore,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextField(
            _locationLngController,
            'Longitude (optional)',
            keyboardType: TextInputType.number,
            labelIcon: Icons.explore,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? labelIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        prefixIcon: labelIcon != null ? Icon(labelIcon) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3BA55C), width: 1.5),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateTimeTile(
    String title,
    DateTime? value,
    Function(DateTime) onSelected,
  ) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.3),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        value != null ? _formatDateTimeShort(value) : 'Not set',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _selectDateTime(onSelected),
    );
  }

  Future<void> _selectDateTime(Function(DateTime) onSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.green,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        onSelected(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _selectedImage = img;
        _selectedImageBytes = bytes;
        _selectedImageMime = _getMimeType(img.name);
        _selectedImageName = img.name;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _selectedImageMime = null;
      _selectedImageName = null;
    });
  }

  String _getMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/png';
  }

  String _formatDateTimeShort(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $h:$m';
  }

  Future<void> _handleCreateEvent(BuildContext messengerContext) async {
    final feeRaw = _feeController.text.trim();
    final rsvpRaw = _rsvpController.text.trim();
    final latRaw = _locationLatController.text.trim();
    final lngRaw = _locationLngController.text.trim();

    if (_descriptionController.text.isEmpty ||
        _startTime == null ||
        _endTime == null ||
        feeRaw.isEmpty ||
        rsvpRaw.isEmpty) {
      _showSnackBar(
        messengerContext,
        'Please fill all required fields (description, start/end time, fee, RSVP).',
      );
      return;
    }

    final fee = int.tryParse(feeRaw);
    if (fee == null || fee < 0) {
      _showSnackBar(messengerContext, 'Fee must be a non-negative number.');
      return;
    }

    final lat = latRaw.isEmpty ? null : double.tryParse(latRaw);
    final lng = lngRaw.isEmpty ? null : double.tryParse(lngRaw);
    final onlyOneCoord =
        (lat != null && lng == null) || (lat == null && lng != null);
    if (onlyOneCoord) {
      _showSnackBar(
        messengerContext,
        'Provide both latitude and longitude, or leave both empty.',
      );
      return;
    }

    final controller = context.read<BroadcastController>();

    try {
      final success = await controller.createEvent(
        description: _descriptionController.text,
        startTime: _startTime!,
        endTime: _endTime!,
        locationName: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        locationLat: lat,
        locationLng: lng,
        fee: fee,
        rsvpUrl: rsvpRaw,
        imageBytes: _selectedImageBytes,
        imageMime: _selectedImageMime,
        imageUrl: null,
      );

      if (success && mounted) {
        Navigator.pop(context);
        _showSnackBar(messengerContext, 'Event created successfully');
      } else if (mounted) {
        final err = controller.error ?? 'Event creation failed';
        _showSnackBar(messengerContext, err);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(messengerContext, e.toString());
      }
    }
  }

  void _showSnackBar(BuildContext messengerContext, String message) {
    ScaffoldMessenger.of(
      messengerContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
