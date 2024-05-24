/* main-server.vala
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

public static int main(string[] args) {
    int port = 0;
    if (args[1] == "--port" && int.try_parse(args[2], out port)) {
        if (port > Math.pow(2, 11) && port < Math.pow(2, 16)) {
            message("Server running ...");
            new Storm.Server((uint16) port);
            return 0;
        }
    }
    return 1;
}