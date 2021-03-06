using Gee;

namespace App.Models {
    public class Folder : Granite.Widgets.SourceList.ExpandableItem {
        private ArrayList<Cipher> _ciphers;

        public string ? id { get; set; }

        public Folder (string name = "") {
            base (name);
            _ciphers = new ArrayList<Cipher>();
        }

        public ArrayList<Cipher> get_ciphers () {
            return _ciphers;
        }

        public ArrayList<Cipher> get_sorted_ciphers () {
            _ciphers.sort((a,b) => {
                return a.name.ascii_casecmp(b.name); 
            });

            return _ciphers;
        }

        public void add_cipher (Cipher cipher) {
            _ciphers.add (cipher);
        }

        public void remove_all_ciphers () {
            _ciphers.clear();
        }

        public void add_all (Collection<Cipher> ciphers) {
            _ciphers.add_all(ciphers);
        }

        public bool remove_cipher (Cipher cipher) {
            return _ciphers.remove (cipher);
        }
    }
}
