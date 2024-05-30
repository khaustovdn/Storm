/* ship-placement-model.vala
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
    public class ShipPlacement : Object {
        public ShipPlacement () {
            Object ();
        }

        public void show_battle_view (INavigationService service) {
            try {
                Storm.game.client.send (Storm.game.client.serialize ("battle"));
                var name_msg = Storm.game.client.receive ();
                var name = new GXml.Document.from_string (name_msg).first_element_child.get_attribute ("name");
                Storm.game.player.opponent_board = new BoardView (name);
                var view = new BattleView (service);
                service.navigation.push (view);
            } catch (Error e) {
                warning (@"$(e.message)");
            }
        }

        public void close_ship_placement_view () {
            Storm.game.client.send (Storm.game.client.serialize ("end"));
        }
    }
}