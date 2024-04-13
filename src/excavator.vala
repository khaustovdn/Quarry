/* excavator.vala
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
    public class Excavator : Object {
        public int time { get; set; }
        public Gee.ArrayList<DumpTruck> truck_list { get; construct; }

        public Excavator (int time, Gee.ArrayList<DumpTruck> truck_list) {
            Object (time: time, truck_list: truck_list);
        }

        public void update () {
            if (truck_list.is_empty)return;

            var truck = truck_list.first ();

            if (truck != null && truck.is_loaded) {
                if (time > 0) {
                    print ("excavator time %d\n", time);
                    time--;
                } else {
                    truck_list.remove (truck);
                    if (truck_list.is_empty)return;
                    truck = truck_list.first ();
                }
            }

            if (!truck.is_loaded) {
                load_dump_truck (truck);
                print ("load truck %d\n", truck_list.size);
            }
        }

        private void load_dump_truck (DumpTruck truck) {
            if (truck.is_loaded) {
                print ("Dump truck is already loaded. Cannot load again.\n");
                return;
            }

            this.time = 2;
            truck.is_loaded = true;
        }
    }
}