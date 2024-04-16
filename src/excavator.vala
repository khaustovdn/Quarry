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
    public class Excavator : Station {
        public Excavator(int time, Gee.ArrayList<DumpTruck> truck_list) {
            Object(time: time, truck_list: truck_list);
        }

        protected override void handle_unloaded_truck(DumpTruck truck) {
            if (this.time == 0) {
                truck.load = Load.IN_PROCESS;
                int random_time = generate_random_time((truck.tonnage == 50) ? 600 : 300);
                this.time = random_time - 1;
            }
        }

        protected override void handle_in_process_truck(DumpTruck truck) {
            base.handle_in_process_truck(truck);
            if (this.time == 0)truck.load = Load.LOADED;
        }

        protected override void handle_loaded_truck(DumpTruck truck) {
            if (this.time > 0) {
                printerr("Error: time does not correspond to the type of dump truck loading\n");
                this.time = 0;
            }
            handle_in_process_truck(truck);
        }
    }
}