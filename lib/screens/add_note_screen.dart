import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Work';
  final List<String> _categories = ['Work', 'Personal', 'Study'];
  bool _isPinned = false;
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imagePaths.add(photo.path);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Note',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            if (_imagePaths.isNotEmpty) const SizedBox(height: 16.0),
            if (_imagePaths.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: FileImage(File(_imagePaths[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 0,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and content cannot be empty'),
                    ),
                  );
                  return;
                }
                
                final note = Note(
                  id: '',  
                  title: title,
                  content: content,
                  category: _selectedCategory,
                  createdAt: DateTime.now(),
                  isPinned: _isPinned,
                  imagePaths: _imagePaths,
                );
                
                context.read<NotesBloc>().add(AddNote(note));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}