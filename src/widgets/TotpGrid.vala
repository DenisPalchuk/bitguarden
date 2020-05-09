using App.Models;
namespace App.Widgets {
    class TotpGrid: Gtk.Grid {
        public TotpGrid(Cipher cipher) {
            var totp_entry = new Gtk.Entry ();
            var totp_label = new Granite.HeaderLabel(_ ("Authenticator Key (TOTP):"));
            totp_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-copy");
            totp_entry.set_hexpand (true);
            totp_entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    Gtk.Clipboard clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
                    clipboard.set_text (totp_entry.text, -1);
                }
            });

            var otp_panel = new OTPPanel ();
            otp_panel.hide ();
            otp_panel.set_no_show_all (true);
            otp_panel.set_margin_start(20);
            //  otp_panel.vexpand = true;
            otp_panel.set_valign(Gtk.Align.CENTER);

            totp_entry.text = cipher.totp != null ? cipher.totp : "";
            if (cipher.totp != null) {
                otp_panel.set_key (cipher.totp);
                otp_panel.set_no_show_all (false);
                otp_panel.show_all();
            } else {
                otp_panel.hide ();
            }
            this.attach(totp_label, 0, 0, 1);
            this.attach(totp_entry, 0, 1, 1);
            this.attach(otp_panel, 1, 1, 1);
        }
    }
}
