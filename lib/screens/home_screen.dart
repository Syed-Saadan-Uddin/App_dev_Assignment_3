import 'dart:io';
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
                  return DropdownButton<String>(
                    value: state.currentFilter,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(8),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
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
                    selectedItemBuilder: (BuildContext context) {
                      return categories.map<Widget>((String item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 16),
                            ),
                          ),
                        );
                      }).toList();
                    },
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
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(note: note),
                        ),
                      ).then((_) {
                        // Refresh notes when returning from detail screen
                        context.read<NotesBloc>().add(LoadNotes());
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontSize: 16.0,
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
                              const SizedBox(height: 8.0),
                              if (note.imagePaths.isNotEmpty)
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(note.imagePaths.first),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (note.imagePaths.isEmpty)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    note.content,
                                    style: const TextStyle(fontSize: 14.0),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    note.category,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditNoteScreen(
                                                note: note,
                                              ),
                                            ),
                                          ).then((_) {
                                            // Refresh notes when returning from edit screen
                                            context.read<NotesBloc>().add(LoadNotes());
                                          });
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          size: 18.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      GestureDetector(
                                        onTap: () {
                                          _showDeleteConfirmationDialog(
                                              context, note.id);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 18.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              context.read<NotesBloc>().add(ToggleNotePin(note));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: note.isPinned ? Colors.amber : Colors.grey.withOpacity(0.7),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
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
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[100],
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          ).then((_) {
            // Refresh notes when returning from add screen
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