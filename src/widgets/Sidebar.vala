using App.Configs;
using App.Models;
using Gee;

namespace App.Widgets {
    public class Sidebar : Granite.Widgets.SourceList {
        private static Granite.Widgets.SourceList.ExpandableItem folders_parent;
        private Folder all_items;

        public Sidebar () {
            all_items = new Folder ();
            all_items.id = "all-items";
            all_items.name = _ ("All items");
            folders_parent = new Granite.Widgets.SourceList.ExpandableItem (_ ("Folders"));
            folders_parent.expanded = true;

            root.add (folders_parent);
            
        }

        public void setup_folders () {
            var vault_service = App.VaultService.get_instance ();
            var sync_data = vault_service.sync ();
            var folders_obj = sync_data.get_array_member ("Folders");
            parse_folders (folders_obj);
            var ciphers = sync_data.get_array_member ("Ciphers");
            parse_ciphers (ciphers);

            App.Store.get_instance ().folders.notify["size"].connect(() => {
                folders_parent.clear();
                
                all_items.remove_all_ciphers ();
                folders_parent.add (all_items);

                foreach (Folder folder in App.Store.get_instance ().folders.values) {
                    folders_parent.add (folder);
                    all_items.add_all(folder.get_ciphers());
                }

                if (selected == null) {
                    selected = all_items;
                    item_selected (all_items);
                }    
            });
        }



        private void parse_folders (Json.Array ? folders_obj) {
            var vault_service = App.VaultService.get_instance ();
            folders_obj.foreach_element ((array, index, node) => {
                var object = node.get_object ();
                var folder = new Folder ();
                folder.id = object.get_string_member ("Id");
                folder.name = (string) (vault_service.decrypt_string (object.get_string_member ("Name"), vault_service.encryption_key));
                App.Store.get_instance ().folders.set(folder.id, folder);
            });

            
        }

        private void parse_ciphers (Json.Array ? ciphers) {
            var vault_service = App.VaultService.get_instance ();
            ciphers.foreach_element ((array, index, node) => {
                var object = node.get_object ();
                var login = object.get_object_member ("Login");

                var cipher = new Cipher ();
                cipher.name = (string) (vault_service.decrypt_string (object.get_string_member ("Name"), vault_service.encryption_key));
                cipher.username = (string) (vault_service.decrypt_string (login.get_string_member ("Username"), vault_service.encryption_key));
                cipher.password = (string) (vault_service.decrypt_string (login.get_string_member ("Password"), vault_service.encryption_key));
                cipher.uri = (string) (vault_service.decrypt_string (login.get_string_member ("Uri"), vault_service.encryption_key));
                string totp;
                if ((totp = login.get_string_member ("Totp")) != null) {
                    cipher.totp = (string) (vault_service.decrypt_string (totp, vault_service.encryption_key));
                }

                var folderId = object.get_string_member ("FolderId");
                var folder = App.Store.get_instance ().folders.get (folderId);
                if (folder != null) {
                    folder.add_cipher (cipher);
                }
            });
        }
    }
}
