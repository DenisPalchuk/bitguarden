/*
 * Copyright (C) 2018  Daniel Liljeberg <liljebergxyz@protonmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using App.Configs;


    /**
     * The {@code AppView} class.
     *
     * @since 1.0.0
     */
public class App.Views.AppView : Gtk.Box {

    

    /**
     * Constructs a new {@code AppView} object.
     */
    public AppView () {
        if (App.Bitwarden.get_instance ().encryption_key == null) {
            this.show_quick_login();
        } else {
            this.show_vault();
        }
    }

    private void show_quick_login() {
        var quick_welcome = new App.Views.QuickLoginView();
        this.add (quick_welcome);
        
        quick_welcome.successful_vault_decrypt.connect(() => {
            this.remove(quick_welcome);
            this.show_vault();
        });
    }

    private void show_vault() {
        var vault_view = new App.Views.VaultView(Gtk.Orientation.HORIZONTAL);
        debug("changing layout triggered");
        this.add (vault_view);
        this.show_all ();
    }
}
