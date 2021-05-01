using App.Widgets;
using App.Models;

class App.Views.VaultView: Gtk.Paned {

    private Gtk.Paned child_panel;
    private Sidebar sidebar;


    public VaultView(Gtk.Orientation orientation) {
        Object (orientation: orientation);
        try {
            App.VaultService.get_instance().sync_folders_with_store();
        } catch (GLib.Error error) {
            warning("Error during syncing folders with state: %s", error.message);
        }


        var content_view = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
    
        child_panel = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        
        var cipher_list = new CipherList ();
        child_panel.pack1 (cipher_list, false, false);
        
        sidebar = new Sidebar ();

        cipher_list.listbox.row_selected.connect ((row) => {
            if (row == null) return;
            var cipher_page = new CipherPage(((CipherItem) row).cipher);
            child_panel.remove(child_panel.get_child2());
            child_panel.pack2(cipher_page, true, false);
            cipher_page.show_all();
        });

        this.initialize_chipher_list_by_folder (sidebar.all_passwords, cipher_list);
        sidebar.item_selected.connect ((item) => {
            this.initialize_chipher_list_by_folder((Folder) item, cipher_list);
        });
        App.State.get_instance ().notify["search-text"].connect((obj, val) => {
            cipher_list.filter_by_string(((App.State)(obj)).search_text);
        });
        

        content_view.pack1 (sidebar, false, false);
        content_view.pack2 (child_panel, true, false);

        var search_bar = new Gtk.SearchBar();
        var search_entry = new Gtk.SearchEntry();
        search_entry.width_chars = 28;
        search_entry.tooltip_text = _("Search all mail in account for keywords (Ctrl+S)");
        search_entry.has_focus = true;
        search_entry.show();
        

        search_bar.add(search_entry);
        this.pack1(search_bar, false, false);
        this.pack2(content_view, true, true);
        this.position = (150);
    }

    private void initialize_chipher_list_by_folder (Folder item, CipherList cipher_list) {
        if (item != null && item is Folder) {
            Folder folder = (Folder) item;
            var ciphers = folder.get_sorted_ciphers ();
            cipher_list.load_ciphers (ciphers);
            var listbox = cipher_list.listbox; 
            listbox.select_row (listbox.get_row_at_index (0));
        }
    }
}
