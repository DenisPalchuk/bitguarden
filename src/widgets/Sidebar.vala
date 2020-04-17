using App.Configs;
using App.Models;
using Gee;

namespace App.Widgets {
    public class Sidebar : Granite.Widgets.SourceList {
        private static Granite.Widgets.SourceList.ExpandableItem folders_parent;
        public Folder all_items;

        public Sidebar () {
            all_items = new Folder ();
            all_items.id = "all-items";
            all_items.name = _ ("All items");
            folders_parent = new Granite.Widgets.SourceList.ExpandableItem (_ ("Folders"));
            folders_parent.expanded = true;

            root.add (folders_parent);
            init_folders_list();
            App.Store.get_instance ().folders.notify["size"].connect(init_folders_list);
            
        }

        private void init_folders_list() {
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
        }

        
    }
}
