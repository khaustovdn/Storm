/* player.vala
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
    public class Player : Gtk.Widget {
        public Gee.ArrayList<Point> ships { get; default = new Gee.ArrayList<Point> (); }

        public Player () {
            Object ();
        }

        public void random_set () {
            Rand rand = new Rand ();
            for (int i = 0; i < 10; i++) {
                this.ships.add (new Point (i, (int) rand.int_range (0, 10)));
            }
        }
    }
}