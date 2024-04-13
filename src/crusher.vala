/* crusher.vala
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
    public class Crusher : Object {
        public int time { get; set; }
        public Gee.ArrayList<DumpTruck> truck_list { get; construct; }

        public Crusher (int time, Gee.ArrayList<DumpTruck> truck_list) {
            Object (time: time, truck_list: truck_list);
        }

        public void update () {
            if (this.truck_list.is_empty)return;

            if (this.truck_list.first ().load == Load.IN_PROGRESS) {
                if (this.time > 0) {
                    print ("crusher time %d\n", this.time);
                    this.time--;
                } else {
                    this.truck_list.first ().load = Load.UNLOADED;
                    this.truck_list.remove_at (0);
                    count++;
                }
            }

            if (this.truck_list.is_empty)return;

            if (this.truck_list.first ().load == Load.LOADED && this.time == 0) {
                print ("unloading the truck\n");
                this.truck_list.first ().load = Load.IN_PROGRESS;
                this.time = 2;
                this.time--;
            }
        }
    }
}