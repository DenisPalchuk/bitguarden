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
        // TODO: remove this hell with general store and wrap store by services
        search_entry.search_changed.connect(() => {
            App.State.get_instance ().search_text = search_entry.get_text().chomp();
        });
        search_entry.width_chars = 28;
        search_entry.tooltip_text = _("Search all");

        search_bar.add(search_entry);
        search_bar.show_all();
        search_bar.connect_entry(search_entry);
        search_bar.set_search_mode(true);

        App.State.get_instance ().notify["is-search-toogled"].connect((obj, val) => {
            if (((State)obj).is_search_toogled == true) {
                search_bar.show_all();
                search_entry.grab_focus();
            } else {
                search_bar.hide();
            }
        });

        /* need to focus on search entry when vault is unlocked */
        App.State.get_instance ().notify["is-vault-unlocked"].connect((obj, val) => {
            if (((State)obj).is_vault_unlocked == true) {
                search_entry.grab_focus();
            }
        });

        this.pack1(search_bar, false, false);
        this.pack2(content_view, true, true);
        
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
