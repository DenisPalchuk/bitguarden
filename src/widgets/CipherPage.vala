using App.Configs;
using App.Models;
using App.Widgets;
using Gee;

namespace App.Widgets {
    public class CipherPage : Gtk.Box {
        private CipherHeader cipher_header;

        public CipherPage (Cipher cipher) {
            this.orientation = Gtk.Orientation.VERTICAL;

            var user_grid = new Gtk.Grid ();
            user_grid.column_spacing = 20;
            user_grid.row_spacing = 20;
            user_grid.orientation = Gtk.Orientation.HORIZONTAL;

            cipher_header = new CipherHeader ();
            cipher_header.set_vexpand (false);
            cipher_header.set_hexpand (false);
            
            user_grid.attach (cipher_header, 0, 0, 1, 1);
            add (user_grid);
            margin = 20;
            Gtk.Grid entry_grid;

            if (cipher.cipher_type == CipherType.NOTE) {
                entry_grid = new SecureNoteView (cipher);
            } else {
                entry_grid = new PasswordView (cipher);
            } 

            user_grid.attach (entry_grid, 0, 1, 1, 1);
            cipher_header.set_text (cipher.name);
            
        }

    }
}
