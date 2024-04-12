/* dump-truck.vala
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
    public class DumpTruck : Object {
        public bool is_loaded { get; set; }
        public bool is_on_the_way { get; set; }
        public int time { get; set; }
        public Excavator excavator { get; construct; }

        public DumpTruck (bool is_loaded, bool is_on_the_way, int time, Excavator excavator) {
            Object (is_loaded: is_loaded, is_on_the_way: is_on_the_way, time: time, excavator: excavator);
        }

        public void update (Crusher crusher) {
            if (is_on_the_way) {
                if (time > 0) {
                    time--;
                } else {
                    is_on_the_way = false;
                }
            } else if (!excavator.truck_list.contains (this) && !crusher.truck_list.contains (this)) {
                if (is_loaded) {
                    run_to_crusher (crusher);
                } else {
                    run_to_excavator (excavator);
                }
            }
        }

        public void run_to_crusher (Crusher crusher) {
            if (!is_loaded) {
                print ("Dump truck is not loaded.\n");
                return;
            }

            this.time = 2;
            this.is_on_the_way = this.time > 0;

            crusher.truck_list.add (this);
        }

        public void run_to_excavator (Excavator excavator) {
            if (is_loaded) {
                print ("Dump truck is not unloaded.\n");
                return;
            }

            this.time = 2;
            this.is_on_the_way = this.time > 0;

            excavator.truck_list.add (this);
        }
    }
}