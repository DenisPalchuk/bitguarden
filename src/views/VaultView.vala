using App.Widgets;

class App.Views.VaultView: Gtk.Paned {

    private Gtk.Paned main_panel;
    private Gtk.Paned child_panel;
    private Sidebar sidebar;


    public VaultView(Gtk.Orientation orientation) {
        Object (orientation: orientation);
    
        child_panel = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        sidebar = new Sidebar ();

        this.pack1 (sidebar, false, false);
        this.pack2 (child_panel, true, false);
        child_panel.pack1 (CipherList.get_instance (), false, false);
        child_panel.pack2 (CipherPage.get_instance (), true, false);
        this.position = (150);

        sidebar.setup_folders();
    }
}
