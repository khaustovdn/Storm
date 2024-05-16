/* server.vala
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
    public class Server : Object {
        private SocketService service { get; default = new SocketService (); }
        public ClientHandler[] players { get; default = new ClientHandler[2]; }
        public uint16 port { get; construct; }

        public Server (uint16 port) {
            Object (port: port);
        }

        private bool on_incoming_connection (SocketConnection connection) {
            message ("Got incoming connection\n");
            foreach (var player in this.players) {
                if (player == null) {
                    player = new ClientHandler (connection);
                    player.start ();
                }
            }
            return true;
        }

        public void start () {
            try {
                this.service.add_inet_port (this.port, null);
                this.service.incoming.connect (this.on_incoming_connection);
                this.service.start ();
                new MainLoop ().run ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}