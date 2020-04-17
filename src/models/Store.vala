using Gee;
using App.Models;

namespace App { 
    class Store: GLib.Object {
        public bool is_vault_unlocked { get; set; default = false; }

        public uint8[] encryption_key { get; set; }
        public HashMap<string ? , Folder> folders;
    
        public Store() {
            folders = new HashMap<string ? , Folder>();
            var folder = new Folder ();
        }


    
        private static Store ? instance;
    
        public static unowned Store get_instance () {
            if (instance == null) {
                instance = new Store ();
            }
    
            return instance;
        }
    }    
}

