using App.Models;

namespace App.Widgets {
    class PasswordView : Gtk.Grid {
        public PasswordView (Cipher cipher) {
            this.column_spacing = 20;
            this.row_spacing = 10;
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.get_style_context ().add_class ("entry-grid");

            var username_entry = new EntryWithLabel (_ ("Username"), Gtk.Align.START);
            username_entry.entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-copy");
            username_entry.entry.set_hexpand (true);
            username_entry.entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    Gtk.Clipboard clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
                    clipboard.set_text (username_entry.entry.text, -1);
                }
            });

            var password_entry = new EntryWithLabel (_ ("Password"), Gtk.Align.START);
            password_entry.entry.set_visibility (false);
            password_entry.entry.set_hexpand (true);

            password_entry.entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-copy");
            password_entry.entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "system-search");
            password_entry.entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.PRIMARY) {
                    password_entry.entry.set_visibility (!password_entry.entry.get_visibility ());
                } else if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    Gtk.Clipboard clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
                    clipboard.set_text (password_entry.entry.text, -1);
                }
            });

            var totp_entry = new EntryWithLabel (_ ("Authenticator Key (TOTP)"), Gtk.Align.START);
            totp_entry.entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-copy");
            totp_entry.entry.set_hexpand (true);
            totp_entry.entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    Gtk.Clipboard clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
                    clipboard.set_text (totp_entry.entry.text, -1);
                }
            });

            var otp_panel = new OTPPanel ();
            otp_panel.hide ();
            otp_panel.set_no_show_all (true);

            this.attach (username_entry, 0, 2, 1, 1);
            // TODO: Insert folder here
            this.attach (password_entry, 1, 2, 1, 1);
            this.attach (totp_entry, 0, 3, 1, 1);
            this.attach (otp_panel, 1, 3, 1, 1);

            username_entry.text = cipher.username;
            password_entry.text = cipher.password;
            password_entry.entry.set_visibility (false);
            totp_entry.text = cipher.totp != null ? cipher.totp : "";
            if (cipher.totp != null) {
                otp_panel.set_key (cipher.totp);
                otp_panel.set_no_show_all (false);
                otp_panel.show_all();
            } else {
                otp_panel.hide ();
            }
        }
    }
}
