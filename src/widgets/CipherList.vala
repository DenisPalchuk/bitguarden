using App.Configs;
using App.Models;
using Gee;

namespace App.Widgets {
    public class CipherList : Gtk.Box {
        public Gtk.ListBox listbox;
        public CipherPage cipher_page;
        private ArrayList<Cipher> _ciphers;

        public CipherList (CipherPage page) {
            _ciphers = new ArrayList<Cipher>();
            this.cipher_page = page; 

            build_ui ();
            connect_signals ();
        }

        private void build_ui () {
            orientation = Gtk.Orientation.VERTICAL;

            var scroll_box = new Gtk.ScrolledWindow (null, null);
            listbox = new Gtk.ListBox ();
            listbox.vexpand = true;
            listbox.activate_on_single_click = false;
            listbox.set_size_request (200, 100);
            // TODO: Filter
            //  HeaderBar.get_instance ().search_entry.search_changed.connect((user_data) => {
            //      listbox.set_filter_func( (row) => {
            //          debug(user_data.get_text());
            //          debug(row.get_children().to_string());
            //          return ((AlignedLabel)row.get_children().nth_data(2)).label.contains(user_data.get_text());
            //      });
            //  });
            // listbox.set_filter_func

            scroll_box.set_size_request (200, 100);
            scroll_box.add (listbox);

            this.add (scroll_box);
        }

        public void load_ciphers (ArrayList<Cipher> ciphers) {
            _ciphers = ciphers;
            clear_listbox ();
            foreach (Cipher cipher in _ciphers) {
                var row = new CipherItem (cipher);
                listbox.add (row);
            }
        }

        private void clear_listbox () {
            listbox.unselect_all ();
            foreach (Gtk.Widget child in listbox.get_children ()) {
                if (child is Gtk.ListBoxRow) {
                    listbox.remove (child);
                }
            }
        }

        private void connect_signals () {
            listbox.row_selected.connect ((row) => {
                if (row == null) return;
                this.cipher_page.set_cipher (((CipherItem) row).cipher);
            });
        }
    }
}
