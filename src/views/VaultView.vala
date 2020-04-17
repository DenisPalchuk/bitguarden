using App.Widgets;
using App.Models;

class App.Views.VaultView: Gtk.Paned {

    private Gtk.Paned main_panel;
    private Gtk.Paned child_panel;
    private Sidebar sidebar;


    public VaultView(Gtk.Orientation orientation) {
        Object (orientation: orientation);
    
        child_panel = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        
        var cipher_page = new CipherPage ();
        var cipher_list = new CipherList (cipher_page);
        child_panel.pack1 (cipher_list, false, false);
        child_panel.pack2 (cipher_page, true, false);
        
        sidebar = new Sidebar ();

        sidebar.item_selected.connect ((item) => {
            if (item != null && item is Folder) {
                Folder folder = (Folder) item;
                var ciphers = folder.get_ciphers ();
                cipher_list.load_ciphers (ciphers);
                var listbox = cipher_list.listbox; 
                listbox.select_row (listbox.get_row_at_index (0));
            }
        });

        this.pack1 (sidebar, false, false);
        this.pack2 (child_panel, true, false);
        this.position = (150);


        sidebar.setup_folders();
    }
}
