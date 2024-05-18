/* client-handler.vala
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
    public class ClientHandler : Object {
        public Server server { private get; construct; }
        public SocketConnection socket { private get; construct; }
        public DataInputStream in { private get; construct; }
        public DataOutputStream out { private get; construct; }

        private string user_name { get; set; }
        private long game_id { get; set; }

        public ClientHandler (Server server, SocketConnection socket) {
            Object (server: server, socket: socket);
        }

        construct {
            this.in = new DataInputStream (this.socket.input_stream);
            this.out = new DataOutputStream (this.socket.output_stream);
            new Thread<void> ("socket-thread", () => {
                try {
                    this.server.add_client (this);

                    while (!this.socket.is_closed ()) {
                        string? msg = this.in.read_line ();
                        if (msg == null) {
                            break;
                        }

                        GXml.Element element = null;

                        if (msg.contains ("PlayerParameters")) {
                            element = new PlayerParameters ();
                            element.read_from_string (msg);
                            this.user_name = ((PlayerParameters) element).user_name;
                            this.game_id = long.parse (((PlayerParameters) element).game_id);

                            if (this.server.games.map<long> (x => x.game_id).all_match (x => x != this.game_id)) {
                                this.server.games.add (new GameHandler (this.game_id));
                            }

                            var game = this.server.games.first_match (x => x.game_id == this.game_id);
                            if (game.players.size < 2) {
                                game.players.add (this);
                            }
                        }

                        message (@"server $(this.server.games.first ().game_id)");
                        this.server.broadcast (this, "ok");
                    }
                } catch (Error e) {
                    warning (e.message);
                } finally {
                    this.server.remove_client (this);
                }
                return;
            });
        }

        public void send (string value) {
            try {
                this.out.write (@"$(value)\r\n".data);
                this.out.flush ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        public bool close () {
            try {
                this.socket.close ();
                return true;
            } catch (Error e) {
                warning (e.message);
            }
            return false;
        }
    }
}