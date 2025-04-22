import '../models/note.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final String currentFilter;

  NotesLoaded(this.notes, {this.currentFilter = 'All'});
}

class NotesError extends NotesState {
  final String message;

  NotesError(this.message);
}