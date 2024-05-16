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
        public SocketConnection socket { private get; construct; }
        public DataInputStream in { private get; construct; }
        public DataOutputStream out { private get; construct; }

        public ClientHandler (SocketConnection socket) {
            Object (socket: socket);
        }

        construct {
            this.in = new DataInputStream (this.socket.input_stream);
            this.out = new DataOutputStream (this.socket.output_stream);
        }

        public void start () {
            try {
                new Thread<void> ("socket-thread", () => {
                });
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}