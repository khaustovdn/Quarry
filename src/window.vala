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
            var timer = timer_spin_row.adjustment.value;

            Excavator excavator = new Excavator ();

            excavator.truck_list.add_all_array ({ new DumpTruck (), new DumpTruck (), new DumpTruck () });

            Crusher crusher = new Crusher ();

            while (timer > 0) {
                print ("value: %s\n", timer.to_string ());

                var truck = new DumpTruck ();

                if (excavator.truck_list.size > 0) {
                    truck = excavator.truck_list.first ();
                    excavator.load_dump_truck (truck);
                }

                truck.run_to_crusher (crusher);

                if (crusher.truck_list.size > 0) {
                    truck = crusher.truck_list.first ();
                    crusher.unload_dump_truck (truck);
                }

                truck.run_to_excavator (excavator);

                timer -= 1;

                Idle.add (simulate.callback);
                yield;
            }
        }
    }
}