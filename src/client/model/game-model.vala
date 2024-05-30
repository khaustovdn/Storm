/* game-model.vala
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
    public class Game : Object {
        public Client client { get; construct; }
        public Player player { get; set; }
        public string room { get; set; }
        public State state { get; set; }

        public string host { private get; construct; }
        public uint16 port { private get; construct; }

        public Game (string host, uint16 port) {
            Object (host: host, port: port);
        }

        construct {
            this.client = new Client (this.host, this.port);
        }

        public enum State {
            NULL,
            CONNECTED,
            MAIN_MENU,
            SHIP_PLACEMENT,
            GAME_PLAY,
            GAME_OVER,
            DISCONNECTED
        }
    }
}