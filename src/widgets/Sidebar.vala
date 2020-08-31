using App.Configs;
using App.Models;
using Gee;

namespace App.Widgets {
    public class Sidebar : Granite.Widgets.SourceList {
        private Granite.Widgets.SourceList.ExpandableItem types_root;
        private Granite.Widgets.SourceList.ExpandableItem folders_parent;
        public Folder all_passwords;
        public Folder all_notes;

        public Sidebar () {
            this.set_size_request(220, -1);
            types_root = new Granite.Widgets.SourceList.ExpandableItem ("Types");
            types_root.expanded =true;
            root.add (types_root);

            all_passwords = this.create_new_folder("all-passwords", _ ("All passwords"));
            init_all_items_list(all_passwords, CipherType.PASSWORD);
            types_root.add(all_passwords);

            all_notes = this.create_new_folder("all-notes", _("All secure notes"));
            init_all_items_list(all_notes, CipherType.NOTE);
            types_root.add(all_notes);

            folders_parent = new Granite.Widgets.SourceList.ExpandableItem (_ ("Folders"));
            folders_parent.expanded = true;
            
            root.add (folders_parent);
            init_folders_list();
            App.State.get_instance ().folders.notify["size"].connect(init_folders_list);
            
        }

        private Folder create_new_folder(string folder_id, string folder_name) {
            var folder = new Folder ();
            folder.id = folder_id;
            folder.name = folder_name;
            return folder;
        }

        private void init_all_items_list(Folder current_folder, CipherType type) {
            current_folder.remove_all_ciphers ();
            foreach (Folder folder in App.State.get_instance ().folders.values) {
                foreach (Cipher cipher in folder.get_ciphers()) {
                    if (cipher.cipher_type == type) {
                        current_folder.add_cipher (cipher);
                    }
                }
            }
        }

        private void init_folders_list() {
            folders_parent.clear();

            foreach (Folder folder in App.State.get_instance ().folders.values) {
                folders_parent.add (folder);
            }

            if (selected == null) {
                selected = all_passwords;
                item_selected (all_passwords);
            }    
        }

        
    }
}
