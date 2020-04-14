using App.Widgets;

class App.Views.QuickLoginView : Gtk.Grid {

    public signal void successful_vault_decrypt();
    
    private Gtk.Grid grid;
    private Gtk.Entry password_entry;
    private Gtk.Button login_button;
    private Json.Object ? sync_data;
    
    public QuickLoginView() {
        password_entry = new Gtk.Entry ();
        password_entry.set_visibility (false);
        login_button = new Gtk.Button.with_label (_ ("Unlock"));
        login_button.halign = Gtk.Align.CENTER;
        login_button.clicked.connect (on_login_clicked);

        this.column_spacing = 12;
        this.row_spacing = 6;
        this.hexpand = true;
        this.halign = Gtk.Align.CENTER;
        this.valign = Gtk.Align.CENTER;
        this.attach (new AlignedLabel (_ ("Password:")), 0, 0);
        this.attach (password_entry, 1, 0);
        this.attach (login_button, 1, 1);
    }

    private async void on_login_clicked () {
        var bitwarden = App.Vault.get_instance ();
        if (yield bitwarden.unlock (password_entry.text)) {
            successful_vault_decrypt();
        }
    }
}
