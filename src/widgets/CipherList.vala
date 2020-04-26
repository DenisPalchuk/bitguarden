using App.Configs;
using App.Models;
using Gee;

namespace App.Widgets {
    public class CipherList : Gtk.Box {
        public Gtk.ListBox listbox;
        public CipherPage cipher_page;
        private ArrayList<Cipher> _ciphers;

        public CipherList (CipherPage page) {
            this.set_size_request(250, -1);
            _ciphers = new ArrayList<Cipher>();
            this.cipher_page = page; 

            build_ui ();
        }

        private void build_ui () {
            orientation = Gtk.Orientation.VERTICAL;

            var scroll_box = new Gtk.ScrolledWindow (null, null);
            listbox = new Gtk.ListBox ();
            listbox.vexpand = true;
            listbox.activate_on_single_click = false;
            listbox.set_size_request (200, 100);
            

            scroll_box.set_size_request (200, 100);
            scroll_box.add (listbox);

            this.add (scroll_box);
        }

        public void load_ciphers (ArrayList<Cipher> ciphers) {
            _ciphers = ciphers;
            this.load_all_ciphers ();
        }

        public void filter_by_string(string search_text) {
            if (search_text == "") {
                this.load_all_ciphers ();
                return;
            }

            clear_listbox();
            foreach (var cipher in _ciphers) {
                if (cipher.name.contains (search_text) ||
                    // TODO: uncomment it later when will add URI entry to cipher page
                    //  cipher.uri.contains (search_text) ||
                    cipher.username != null && cipher.username.contains (search_text)
                ) {
                    var row = new CipherItem (cipher);
                    listbox.add (row);
                }
            }
        }

        public void load_all_ciphers() {
            clear_listbox ();
            foreach (Cipher cipher in _ciphers) {
                // TODO: add cards support
                //  if (cipher.cipher_type == CipherType.CARD || cipher.cipher_type == CipherType.NOTE) {
                //      continue;
                //  }
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
    }
}
