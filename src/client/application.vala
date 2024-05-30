/* application.vala
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
    private const string HOST = "127.0.0.1";
    private const uint16 PORT = 3333;
    private const uint16 LINE_COUNT = 10;
    public static Game game;

    public class Application : Adw.Application {
        public Application () {
            Object (application_id: "io.github.Storm", flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        construct {
            Storm.game = new Game (HOST, PORT);
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", { "<primary>q" });
        }

        public override void activate () {
            if (Storm.game.state == Game.State.CONNECTED) {
                base.activate ();
                var win = this.active_window;
                if (win == null) {
                    win = new Storm.WindowView (this);
                }
                win.close_request.connect (Storm.game.client.close_connection);
                win.present ();
            }
        }

        private void on_about_action () {
            string[] developers = { "khaustovdn" };
            var about = new Adw.AboutWindow () {
                transient_for = this.active_window,
                application_name = "storm",
                application_icon = "io.github.Storm",
                developer_name = "khaustovdn",
                version = "0.1.0",
                developers = developers,
                copyright = "© 2024 khaustovdn",
            };

            about.present ();
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}