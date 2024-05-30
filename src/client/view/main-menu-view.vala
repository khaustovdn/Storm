/* main-menu-view.vala
 *
 * Copyright 2024 khaustovdn
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
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Storm {
    [GtkTemplate (ui = "/io/github/Storm/ui/main-menu-view.ui")]
    public class MainMenuView : Adw.NavigationPage {
        [GtkChild (name = "name-row")]
        private unowned Adw.EntryRow name_row;
        [GtkChild (name = "port-row")]
        private unowned Adw.EntryRow port_row;
        [GtkChild (name = "type-row")]
        private unowned Adw.ComboRow type_row;
        [GtkChild (name = "show-ship-placement-button")]
        private unowned Gtk.Button show_ship_placement_button;
        [GtkChild (name = "breakpoint")]
        public unowned Adw.Breakpoint breakpoint;

        public INavigationService service { get; construct; }
        public MainMenuViewModel view_model { get; construct; }

        public MainMenuView (INavigationService service) {
            Object (service: service);
        }

        construct {
            this.view_model = new MainMenuViewModel (this.service);
            this.type_row.notify["selected"].connect (this.is_valid_input);
        }

        [GtkCallback (name = "show-ship-placement-view")]
        private void show_ship_placement_view () {
            this.view_model.show_ship_placement_view (this.name_row.text, this.port_row.text, this.type_row.selected);
            this.service.navigation.popped.connect (this.view_model.close_ship_placement_view);
        }

        [GtkCallback (name = "is-valid-input")]
        private void is_valid_input () {
            var is_valid = this.view_model.is_valid_input (this.name_row.text, this.port_row.text, this.type_row.selected);
            this.show_ship_placement_button.set_sensitive (is_valid);
        }
    }
}