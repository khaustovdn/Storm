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
        public Player opponent { get; set; }
        public string user_name { get; construct; }
        public long game_id { get; construct; }

        private SocketClient client { get; default = new SocketClient (); }
        private SocketConnection socket { get; set; }

        public Player (string user_name, long game_id) {
            Object (user_name: user_name, game_id: game_id);
        }

        public void start () {
            new Thread<void> ("client-thread", () => {
                try {
                    socket = client.connect_to_host ("127.0.0.1", 8080);

                    PlayerParameters xml = new PlayerParameters(user_name, game_id);
                    var message = @"$(xml.write_string ().replace("\n", ""))\n";
                    socket.output_stream.write (message.data);

                    while (true) {

                    }
                } catch (Error e) {
                    warning (e.message);
                }
            });
        }

        public void random_set () {
            Rand rand = new Rand ();
            for (int i = 0; i < 10; i++) {
                this.ships.add (new Point (i, (int) rand.int_range (0, 10)));
            }
        }
    }
}