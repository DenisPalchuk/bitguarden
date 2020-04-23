using App.Widgets;
using Gtk;

class App.Views.QuickLoginView : Gtk.Grid {

    public signal void successful_vault_decrypt();
    
    private Gtk.Entry password_entry;
    private Gtk.Spinner spinner;
    private Gtk.Label password_feedback;
    private Gtk.Revealer feedback_revealer;
    private Gtk.Button login_button;
    private Gtk.Window window;
    
    public QuickLoginView(Gtk.Window window) {
        this.window = window;
        var logo = new Image.from_resource ("/com/github/denispalchuk/bitguarden/images/logo128");
        logo.halign = Gtk.Align.CENTER;
        logo.hexpand = true;
        logo.margin_bottom = 15;

        password_entry = new Gtk.Entry ();
        password_entry.set_visibility (false);
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        password_entry.primary_icon_name = "dialog-password-symbolic";

        password_feedback = new Gtk.Label (null);
        password_feedback.justify = Gtk.Justification.RIGHT;
        password_feedback.max_width_chars = 40;
        password_feedback.wrap = true;
        password_feedback.xalign = 1;
        password_feedback.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);

        feedback_revealer = new Gtk.Revealer ();
        feedback_revealer.add (password_feedback);

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        login_button = new Gtk.Button.with_label (_ ("Unlock"));
        login_button.margin_top = 15;
        login_button.halign = Gtk.Align.CENTER;
        login_button.clicked.connect (on_login_clicked);

        spinner = new Gtk.Spinner();

        box.pack_start(login_button);
        box.pack_start(spinner);
        
        this.column_spacing = 12;
        this.row_spacing = 6;
        this.hexpand = true;
        this.halign = Gtk.Align.CENTER;
        this.valign = Gtk.Align.CENTER;
        this.attach (logo, 0, 0, 2);
        this.attach (new AlignedLabel (_ ("Password:")), 0, 1);
        this.attach (password_entry, 1, 1);
        this.attach (feedback_revealer, 0, 2, 2);
        this.attach (box, 0, 3, 2);
        spinner.hide();
        password_entry.activate.connect(() => {
            login_button.clicked();
        });
    }

    private async void on_login_clicked () {
        feedback_revealer.reveal_child = false;
        spinner.show();
        spinner.start();
        var vault_service = App.VaultService.get_instance ();
        var result = yield vault_service.unlock (password_entry.text);
        if (!result) {
            this.show_error();
        }
    }

    private void show_error () {
        password_entry.secondary_icon_name = "dialog-error-symbolic";
        password_feedback.label = "Wrong password. Please try later";
        feedback_revealer.reveal_child = true;
        shake ();
        spinner.stop();
        spinner.hide();
    }

    // From https://github.com/GNOME/PolicyKit-gnome/blob/master/src/polkitgnomeauthenticationdialog.c#L901
    private void shake () {
        int x, y;
        this.window.get_position (out x, out y);

        for (int n = 0; n < 10; n++) {
            int diff = 15;
            if (n % 2 == 0) {
                diff = -15;
            }

            this.window.move (x + diff, y);

            while (Gtk.events_pending ()) {
                Gtk.main_iteration ();
            }

            Thread.usleep (10000);
        }

        this.window.move (x, y);
    }
}
