import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final _uuid = const Uuid();
  String _currentFilter = 'All';
  late Box<Note> _notesBox;

  NotesBloc() : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<FilterNotesByCategory>(_onFilterNotes);
    on<ToggleNotePin>(_onToggleNotePin);
    on<AddImageToNote>(_onAddImageToNote);
    on<RemoveImageFromNote>(_onRemoveImageFromNote);
    _initHive();
  }

  Future<void> _initHive() async {
    _notesBox = await Hive.openBox<Note>('notes');
  }

  List<Note> _getNotesFromBox() {
    return _notesBox.values.toList();
  }

  FutureOr<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      List<Note> filteredNotes = _getFilteredNotes();
      emit(NotesLoaded(filteredNotes, currentFilter: _currentFilter));
    } catch (e) {
      emit(NotesError("Failed to load notes: ${e.toString()}"));
    }
  }

  FutureOr<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    if (event.note.title.isEmpty || event.note.content.isEmpty) {
      emit(NotesError("Title and content cannot be empty"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      return;
    }

    try {
      final newNote = Note(
        id: _uuid.v4(),
        title: event.note.title,
        content: event.note.content,
        category: event.note.category,
        createdAt: DateTime.now(),
        isPinned: event.note.isPinned,
        imagePaths: event.note.imagePaths,
      );

      await _notesBox.put(newNote.id, newNote);
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    } catch (e) {
      emit(NotesError("Failed to add note: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  FutureOr<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    if (event.note.title.isEmpty || event.note.content.isEmpty) {
      emit(NotesError("Title and content cannot be empty"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      return;
    }

    try {
      await _notesBox.put(event.note.id, event.note);
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    } catch (e) {
      emit(NotesError("Failed to update note: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  FutureOr<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _notesBox.delete(event.id);
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    } catch (e) {
      emit(NotesError("Failed to delete note: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  FutureOr<void> _onFilterNotes(FilterNotesByCategory event, Emitter<NotesState> emit) {
    _currentFilter = event.category;
    emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
  }

  FutureOr<void> _onToggleNotePin(ToggleNotePin event, Emitter<NotesState> emit) async {
    try {
      final updatedNote = event.note.copyWith(
        isPinned: !event.note.isPinned,
      );
      await _notesBox.put(updatedNote.id, updatedNote);
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    } catch (e) {
      emit(NotesError("Failed to toggle pin: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  FutureOr<void> _onAddImageToNote(AddImageToNote event, Emitter<NotesState> emit) async {
    try {
      final note = _notesBox.get(event.noteId);
      if (note != null) {
        final updatedImagePaths = List<String>.from(note.imagePaths)
          ..add(event.imagePath);
        final updatedNote = note.copyWith(imagePaths: updatedImagePaths);
        await _notesBox.put(note.id, updatedNote);
        emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      } else {
        emit(NotesError("Note not found"));
        emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      }
    } catch (e) {
      emit(NotesError("Failed to add image: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  FutureOr<void> _onRemoveImageFromNote(RemoveImageFromNote event, Emitter<NotesState> emit) async {
    try {
      final note = _notesBox.get(event.noteId);
      if (note != null) {
        final updatedImagePaths = List<String>.from(note.imagePaths)
          ..remove(event.imagePath);
        final updatedNote = note.copyWith(imagePaths: updatedImagePaths);
        await _notesBox.put(note.id, updatedNote);
        emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      } else {
        emit(NotesError("Note not found"));
        emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
      }
    } catch (e) {
      emit(NotesError("Failed to remove image: ${e.toString()}"));
      emit(NotesLoaded(_getFilteredNotes(), currentFilter: _currentFilter));
    }
  }

  List<Note> _getFilteredNotes() {
    final allNotes = _getNotesFromBox();
    
    
    allNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      return b.createdAt.compareTo(a.createdAt);
    });
    
    if (_currentFilter == 'All') {
      return allNotes;
    } else {
      return allNotes.where((note) => note.category == _currentFilter).toList();
    }
  }
}