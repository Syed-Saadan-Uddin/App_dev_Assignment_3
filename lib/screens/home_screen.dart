import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../models/note.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Work', 'Personal', 'Study'];

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNotes());
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.yellow.shade200; // More vibrant yellow for Work
      case 'Personal':
        return Colors.blue.shade200; // Lighter blue for Personal
      case 'Study':
        return Colors.pink.shade200; // Lighter pink for Study
      default:
        return Colors.grey.shade200;
    }
  }
  
  void _showNoteDetails(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return NoteDetailBottomSheet(note: note);
          },
        );
      },
    ).then((_) {
      // Refresh notes when bottom sheet is closed
      context.read<NotesBloc>().add(LoadNotes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background color like in the image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'NoteIt',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoaded) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButton<String>(
                      value: state.currentFilter,
                      underline: Container(),
                      borderRadius: BorderRadius.circular(16),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Text(category),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          context.read<NotesBloc>().add(
                                FilterNotesByCategory(newValue),
                              );
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 1,
                      isDense: true,
                      menuMaxHeight: 300,
                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                      hint: Text('Filter',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            final notes = state.notes;
            if (notes.isEmpty) {
              return const Center(
                child: Text(
                  'No notes yet. Tap the + button to add one.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9, // Slightly taller cards
                  crossAxisSpacing: 16.0, // More spacing
                  mainAxisSpacing: 16.0, // More spacing
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  // Generate a small random angle for each card for the tilted effect
                  final angle = -0.04 - (Random().nextDouble() * 0.02); // Small negative angle for left tilt
                  
                  return GestureDetector(
                    onTap: () {
                      _showNoteDetails(context, note);
                    },
                    child: Transform.rotate(
                      angle: angle, // Apply rotation transform
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getCategoryColor(note.category),
                          borderRadius: BorderRadius.circular(20.0), // More rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          border: note.isPinned
                              ? Border.all(color: Colors.amber, width: 2)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (note.isPinned)
                                        const Icon(
                                          Icons.push_pin,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  Expanded(
                                    child: note.imagePaths.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              File(note.imagePaths.first),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image_not_supported),
                                                );
                                              },
                                            ),
                                          )
                                        : Text(
                                            note.content,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black.withOpacity(0.7),
                                            ),
                                            maxLines: 6,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          note.category,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditNoteScreen(
                                                    note: note,
                                                  ),
                                                ),
                                              ).then((_) {
                                                context.read<NotesBloc>().add(LoadNotes());
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 16.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          InkWell(
                                            onTap: () {
                                              _showDeleteConfirmationDialog(context, note.id);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 16.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Pin button in top right corner
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  context.read<NotesBloc>().add(ToggleNotePin(note));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: note.isPinned ? Colors.amber : Colors.grey.withOpacity(0.7),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20), // Match the card's corner radius
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Icon(
                                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Click + to add notes'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[200],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          ).then((_) {
            context.read<NotesBloc>().add(LoadNotes());
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                context.read<NotesBloc>().add(DeleteNote(noteId));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}