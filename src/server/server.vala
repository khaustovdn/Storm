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
        public uint16 port { get; construct; }
        public SocketService socket_service { get; construct; }
        public PlayerArrayList players { get; construct; }
        public Gee.ArrayList<Room> rooms { get; construct; }

        public Server (uint16 port) {
            Object (port: port);
        }

        construct {
            this.socket_service = new SocketService ();
            this.players = new PlayerArrayList ();
            this.rooms = new Gee.ArrayList<Room> ();

            try {
                this.socket_service.add_inet_port (this.port, null);
                this.socket_service.incoming.connect (on_incoming_connection);
                this.socket_service.start ();
                new MainLoop ().run ();
            } catch (Error e) {
                warning (@"Failed to start the server. $(e.message)");
            } finally {
                this.players.clear ();
                this.socket_service.close ();
            }
        }

        private bool on_incoming_connection (SocketConnection socket) {
            message ("Got incoming connection");
            this.process_request.begin (socket);
            return true;
        }

        private async void process_request (SocketConnection socket) {
            new Player (this, socket);
        }
    }
}