using App.Models;

namespace App.Widgets {
    class SecureNoteView : Gtk.Grid {
        public SecureNoteView (Cipher cipher) {
            this.column_spacing = 20;
            this.row_spacing = 10;
            this.orientation = Gtk.Orientation.HORIZONTAL;
            var label = new AlignedLabel (_("Note"), Gtk.Align.START);
            var note_entry = new Gtk.TextView ();
            note_entry.buffer.text = cipher.note;
            note_entry.get_style_context ().add_class ("entry-grid");
            note_entry.set_size_request(400, 200);
            note_entry.set_wrap_mode(Gtk.WrapMode.WORD);
            note_entry.set_border_width(10);

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.add(label);
            grid.add(note_entry);

            this.attach (grid, 0, 2);
        }
    }
}
