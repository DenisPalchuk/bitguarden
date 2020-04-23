using App.Widgets;
using Gtk;

class App.Views.QuickLoginView : Gtk.Grid {

    public signal void successful_vault_decrypt();
    
    private Gtk.Entry password_entry;
    private Gtk.Button login_button;
    
    public QuickLoginView() {
        var logo = new Image.from_resource ("/com/github/denispalchuk/bitguarden/images/logo128");
        logo.halign = Gtk.Align.CENTER;
        logo.hexpand = true;
        logo.margin_bottom = 15;

        password_entry = new Gtk.Entry ();
        password_entry.set_visibility (false);
        login_button = new Gtk.Button.with_label (_ ("Unlock"));
        login_button.margin_top = 15;
        login_button.halign = Gtk.Align.CENTER;
        login_button.clicked.connect (on_login_clicked);

        this.column_spacing = 12;
        this.row_spacing = 6;
        this.hexpand = true;
        this.halign = Gtk.Align.CENTER;
        this.valign = Gtk.Align.CENTER;
        this.attach (logo, 0, 0, 2);
        this.attach (new AlignedLabel (_ ("Password:")), 0, 1);
        this.attach (password_entry, 1, 1);
        this.attach (login_button, 0, 2, 2);

        password_entry.activate.connect(() => {
            login_button.clicked();
        });
    }

    private async void on_login_clicked () {
        var vault_service = App.VaultService.get_instance ();
        yield vault_service.unlock (password_entry.text);
    }
}
