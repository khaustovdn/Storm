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
        private MainLoop loop { get; default = new MainLoop (); }
        private SocketService service { get; default = new SocketService (); }
        public Gee.ArrayList<ClientHandler?> players { get; default = new Gee.ArrayList<ClientHandler?> (); }
        public uint16 port { get; construct; }

        public Server (uint16 port) {
            Object (port: port);
        }

        private bool on_incoming_connection (SocketConnection socket) {
            stdout.printf ("Got incoming connection\n");
            process_request.begin (socket);
            return true;
        }

        private async void process_request (SocketConnection socket) {
            new ClientHandler (this, socket);
        }

        public void start () {
            try {
                this.service.add_inet_port (this.port, null);
                this.service.incoming.connect (this.on_incoming_connection);
                this.service.start ();
                this.loop.run ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        public void close () {
            this.broadcast (null, "server was closed\r\n");
            this.remove_all_clients ();
            this.service.stop ();
            this.service.close ();
            this.loop.quit ();
        }

        public void broadcast (ClientHandler? client, string value) {
            foreach (var player in this.players) {
                if (player != client) {
                    player.send (value);
                }
            }
        }

        public void remove_client (ClientHandler client) {
            this.broadcast (client, "the player logged off the server\r\n");
            client.close ();
            this.players.remove (client);
        }

        public void remove_all_clients () {
            this.players.foreach (f => f.close ());
            this.players.clear ();
        }

        public void add_client (ClientHandler client) {
            this.broadcast (client, "player logged into the server\r\n");
            this.players.add (client);
        }
    }
}