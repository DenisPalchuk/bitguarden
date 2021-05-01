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
            var image_search = new Gtk.Image.from_icon_name("edit-find-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            var search_button = new Gtk.ToggleButton();
            search_button.set_image(image_search);
            search_button.set_active(true);
            search_button.clicked.connect(() => { App.State.get_instance ().is_search_toogled = search_button.get_active(); });

            var stack = new Gtk.Stack();
            stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            stack.set_transition_duration(1000);
            
            var paswords_button = new Gtk.CheckButton.with_label("Passwords");
            stack.add_titled(paswords_button, "passowords", "Passwords");
            var secure_notes = new Gtk.CheckButton.with_label("Secure notes");
            stack.add_titled(secure_notes, "notes", "Secure notes");
            
            
            var views = new Gtk.StackSwitcher();
            views.set_stack(stack);

            this.set_custom_title(views);

            this.pack_end(search_button);
            this.show_close_button = true;
            this.has_subtitle = false;
        }
    }
}
