/* room.vala
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
    public class Room : Object {
        public string port { get; construct; }
        public bool switcher { get; set; }
        public Gee.ArrayList<Player> players { get; construct; }

        public Room (string port) {
            Object (port: port);
        }

        construct {
            this.players = new Gee.ArrayList<Player> ();
        }

        public void remove_player (Player? player) {
            if (player != null) {
                this.players.remove (player);
            } else {
                warning ("Failed to process a null object.");
            }
        }

        public void add_player (Player? player) {
            if (player != null) {
                if (this.players.size < 2) {
                    this.players.add (player);
                } else {
                    warning ("The room is already full.");
                }
            } else {
                warning ("Failed to process a null object.");
            }
        }
    }
}