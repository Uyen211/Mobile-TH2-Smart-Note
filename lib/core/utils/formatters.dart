import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat noteDate = DateFormat('dd/MM/yyyy HH:mm');

  static String formatNoteDate(DateTime dt) => noteDate.format(dt);
}
