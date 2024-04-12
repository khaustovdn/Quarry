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
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.Box simulation_box;
        [GtkChild]
        public unowned Adw.SpinRow timer_spin_row;
        [GtkChild]
        public unowned Gtk.Button simulate_button;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            simulate_button.clicked.connect (() => {
                simulate.begin ();
            });
        }

        public async void simulate () {
            int timer = (int) timer_spin_row.adjustment.value;

            Excavator excavator = new Excavator ();

            excavator.truck_list.add_all_array ({ new DumpTruck (), new DumpTruck (), new DumpTruck () });

            Crusher crusher = new Crusher ();

            while (timer > 0) {
                print ("time %d\n", timer);
                if (!excavator.is_free) {
                    if (excavator.time > 0) {
                        print ("excavator time %d\n", excavator.time);
                        excavator.time--;
                    } else {
                        excavator.is_free = true;
                    }
                }

                if (excavator.is_free && !excavator.truck_list.is_empty) {
                    excavator.is_free = false;
                    excavator.load_dump_truck (excavator.truck_list.first ());
                    print ("load truck %d\n", excavator.truck_list.size);
                }

                timer--;

                Idle.add (simulate.callback);
                yield;
            }
        }
    }
}