/* player-array-list.vala
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
    public class PlayerArrayList : Gee.ArrayList<PlayerHandler> {
        public PlayerArrayList () {
            Object ();
        }

        public void broadcast (GXml.Element element) {
            // think about the margin for error
            foreach (var player in this) {
                player.send (element);
            }
        }

        public override bool remove (PlayerHandler player) {
            // think about the margin for error
            player.close_connection ();
            return base.remove (player);
        }

        public override void clear () {
            // think about the margin for error
            foreach (var player in this) {
                player.close_connection ();
            }
            base.clear ();
        }
    }
}