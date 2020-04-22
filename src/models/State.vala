using Gee;
using App.Models;

namespace App { 
    class State: GLib.Object {
        public bool is_vault_unlocked { get; set; default = false; }

        public uint8[] encryption_key { get; set; }
        public HashMap<string ? , Folder> folders;

        public string search_text { get; set; default = ""; }
    
        public State() {
            folders = new HashMap<string ? , Folder>();
            var folder = new Folder ();
            folder.id = "Without folder";
            folder.name = folder.id;
            folders.set(folder.id, folder);
        }


    
        private static State ? instance;
    
        public static unowned State get_instance () {
            if (instance == null) {
                instance = new State ();
            }
    
            return instance;
        }
    }    
}

