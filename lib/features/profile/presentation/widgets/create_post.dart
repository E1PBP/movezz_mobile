import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import 'package:nb_utils/nb_utils.dart';

class CreatePostDialog extends StatefulWidget {
  final String username;

  const CreatePostDialog({super.key, required this.username});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();

  String? _selectedSport;
  XFile? _pickedImage;
  bool _isLoading = false;

  final List<String> _sports = [
    'Soccer',
    'Basketball',
    'Running',
    'Cycling',
    'Swimming',
    'Badminton',
    'Tennis',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + username
              const SizedBox(height: 4),
              Text(
                'Create a new post',
                style: const TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 18,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${widget.username}',
                style: const TextStyle(
                  color: Color(0xFF525252),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Caption
              TextField(
                controller: _captionController,
                maxLines: 5,
                decoration: _inputDecoration('Type here'),
              ),
              const SizedBox(height: 12),

              // Sport + dropdown
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: _inputDecoration('Select Sport'),
                items: _sports
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSport = v),
              ),
              const SizedBox(height: 12),

              // Location
              TextField(
                controller: _locationController,
                decoration: _inputDecoration('Location (Optional)'),
              ),
              const SizedBox(height: 12),

              // Time
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF737373),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Time',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 64,
                    child: TextField(
                      controller: _hourController,
                      decoration: _inputDecoration('00'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 16, color: Color(0xFF737373)),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: TextField(
                      controller: _minuteController,
                      decoration: _inputDecoration('00'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hour',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hashtags
              const Text(
                'Hashtags (max 5)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF525252),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hashtagController,
                decoration: _inputDecoration('Type a tag and press Enter'),
              ),

              const SizedBox(height: 16),

              // Pick image + preview
              Row(
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF737373),
                    ),
                  ),
                  if (_pickedImage != null)
                    Expanded(
                      child: Text(
                        _pickedImage!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Expanded(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Color(0xFF737373)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      foregroundColor: const Color(0xFF365314),
                      minimumSize: const Size(80, 45), 
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);

                            final success = await context
                                .read<ProfileController>()
                                .createPost(
                                  caption: _captionController.text,
                                  sport: _selectedSport,
                                  location: _locationController.text,
                                  hashtags: _hashtagController
                                      .text,
                                  hours: _hourController.text,
                                  minutes: _minuteController.text,
                                  imageFile: _pickedImage,
                                );

                            if (mounted) {
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Post created successfully!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to create post"),
                                  ),
                                );
                              }
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Post"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFA3A3A3)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFA3A3A3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF84CC16), width: 1.5),
    ),
  );
}
