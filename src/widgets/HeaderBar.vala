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

namespace App.Widgets {

    /**
     * The {@code HeaderBar} class is responsible for displaying top bar. Similar to a horizontal box.
     *
     * @see Gtk.HeaderBar
     * @since 1.0.0
     */
    public class HeaderBar : Gtk.HeaderBar {

        public signal void menu_clicked ();

        public Gtk.MenuButton menu_button { get; private set; }

        /**
         * Constructs a new {@code HeaderBar} object.
         *
         * @see App.Configs.Properties
         * @see icon_settings
         */
        public HeaderBar () {

            var search_entry = new Gtk.SearchEntry();
            search_entry.set_no_show_all(true);
            search_entry.hide();
            
            search_entry.search_changed.connect(() => {
                App.State.get_instance ().search_text = search_entry.get_text().chomp();
            });

            App.State.get_instance ().notify["is-vault-unlocked"].connect((obj, val) => {
                if (((State)obj).is_vault_unlocked == true) {
                    search_entry.set_no_show_all (false);
                    search_entry.show_all();
                    search_entry.grab_focus();
                }
            });

            this.set_title ("Bitguarden");
            this.show_close_button = true;
            this.has_subtitle = false;
            this.pack_end (search_entry);
        }
    }
}
