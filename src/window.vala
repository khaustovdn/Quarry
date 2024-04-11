/* window.vala
 *
 * Copyright 2024 khaustov
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Quarry {
    [GtkTemplate (ui = "/io/github/Quarry/window.ui")]
    public class Window : Adw.PreferencesWindow {
        [GtkChild]
        public unowned Adw.SpinRow timer_spin_row;
        [GtkChild]
        public unowned Gtk.Button simulate_button;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            Excavator excavator = new Excavator ();
            DumpTruck dump_truck = new DumpTruck ();
            Crusher crusher = new Crusher ();
            simulate_button.clicked.connect (simulate);
        }

        public void simulate (Gtk.Button sender) {
            var timer = timer_spin_row.value;

            while (timer > 0) {
                print ("value: %s\n", timer.to_string ());
                timer -= 1;
            }
        }
    }
}