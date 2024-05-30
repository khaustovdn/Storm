/* ship-placement-view.vala
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
    [GtkTemplate(ui = "/io/github/Storm/ui/ship-placement-view.ui")]
    public class ShipPlacementView : Adw.NavigationPage {
        [GtkChild(name = "start-button")]
        private unowned Gtk.Button start_button;
        [GtkChild(name = "board-box")]
        private unowned Gtk.Box board;

        public INavigationService service { get; construct; }
        public ShipPlacementViewModel view_model { get; construct; }

        public ShipPlacementView(INavigationService service) {
            Object(service: service);
        }

        construct {
            this.board.prepend(Storm.game.player.board);
            this.view_model = new ShipPlacementViewModel(this.service);
        }

        [GtkCallback(name = "place-ships")]
        private void place_ships() {
            this.view_model.place_ships();
            this.start_button.set_sensitive(true);
        }

        [GtkCallback(name = "show-battle-view")]
        private void show_battle_view() {
            this.view_model.show_battle_view();
        }
    }
}