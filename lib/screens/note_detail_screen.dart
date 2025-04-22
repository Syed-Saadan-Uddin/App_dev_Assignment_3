import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../models/note.dart';
import 'edit_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.amber.shade100;
      case 'Personal':
        return Colors.blue.shade100;
      case 'Study':
        return Colors.pink.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Note Details',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: note.isPinned ? Colors.amber : Colors.black,
            ),
            onPressed: () {
              context.read<NotesBloc>().add(ToggleNotePin(note));
              Navigator.pop(context); // Return to previous screen to see changes
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              ).then((_) => Navigator.pop(context)); // Close details screen when returning from edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getCategoryColor(note.category),
                borderRadius: BorderRadius.circular(8.0),
                border: note.isPinned
                    ? Border.all(color: Colors.amber, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (note.imagePaths.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: note.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(note.imagePaths[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, size: 50),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Text(
                    note.content,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Chip(
                        label: Text(note.category),
                        backgroundColor: Colors.white.withOpacity(0.7),
                      ),
                      if (note.isPinned) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.push_pin, size: 16),
                              SizedBox(width: 4),
                              Text('Pinned'),
                            ],
                          ),
                          backgroundColor: Colors.amber.withOpacity(0.3),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<NotesBloc>().add(DeleteNote(note.id));
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Close detail screen
              },
            ),
          ],
        );
      },
    );
  }
}