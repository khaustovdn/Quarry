/* series.vala
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
    public class Series : Object {
        public Gee.ArrayList<Point> points { get; construct; }
        public Color color { get; construct; }

        public Series (Color color) {
            Object (color: color);
        }

        construct {
            this.points = new Gee.ArrayList<Point> ();
        }

        public void add_point (int x, int y) {
            this.points.add (new Point (x, y));
        }
    }
}