/* station.vala
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
    public abstract class Station : Machine {
        public Gee.ArrayList<DumpTruck> truck_list { get; construct; }

        protected Station(int time, Gee.ArrayList<DumpTruck> truck_list) {
            Object(time: time, truck_list: truck_list);
        }

        public override void update() {
            if (this.truck_list.is_empty)return;

            DumpTruck current_truck = this.truck_list.first();

            switch (current_truck.load) {
            case Load.UNLOADED:
                handle_unloaded_truck(current_truck);
                break;
            case Load.IN_PROCESS:
                handle_in_process_truck(current_truck);
                break;
            case Load.LOADED:
                handle_loaded_truck(current_truck);
                break;
            }
        }

        protected abstract void handle_unloaded_truck(DumpTruck truck);

        protected virtual void handle_in_process_truck(DumpTruck truck) {
            if (this.time > 0) {
                this.time--;
            } else {
                this.truck_list.remove_at(0);
                this.time = 0;
            }
        }

        protected abstract void handle_loaded_truck(DumpTruck truck);

        protected int generate_random_time(int math_expectaton) {
            return (int) (-Math.log(1 - Random.next_double()) * math_expectaton);
        }
    }
}