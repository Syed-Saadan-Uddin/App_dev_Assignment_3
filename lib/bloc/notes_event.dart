import '../models/note.dart';

abstract class NotesEvent {}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final Note note;

  AddNote(this.note);
}

class UpdateNote extends NotesEvent {
  final Note note;

  UpdateNote(this.note);
}

class DeleteNote extends NotesEvent {
  final String id;

  DeleteNote(this.id);
}

class FilterNotesByCategory extends NotesEvent {
  final String category;

  FilterNotesByCategory(this.category);
}

class ToggleNotePin extends NotesEvent {
  final Note note;

  ToggleNotePin(this.note);
}

class AddImageToNote extends NotesEvent {
  final String noteId;
  final String imagePath;

  AddImageToNote(this.noteId, this.imagePath);
}

class RemoveImageFromNote extends NotesEvent {
  final String noteId;
  final String imagePath;

  RemoveImageFromNote(this.noteId, this.imagePath);
}