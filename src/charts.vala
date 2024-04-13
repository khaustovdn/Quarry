/* charts.vala
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
    public class Charts : Gtk.DrawingArea {
        public Series series { get; construct; }
        public Point center { get; set; }

        public Charts () {
            Object ();
        }

        construct {
            this.series = new Series ();

            this.width_request = 360;
            this.height_request = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.set_draw_func (draw);
        }

        private void draw_coordinate_axis (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            var x = 0, y = 0;

            for (int i = 0; i < width; i += 20) {
                cairo.set_line_width ((i == 20) ? 0.5 : 0.1);
                x = (i == 20) ? i : x;
                cairo.move_to (i, 0);
                cairo.line_to (i, height);
                cairo.stroke ();
            }
            for (int i = 0; i < height; i += 20) {
                cairo.set_line_width ((i + 20 > height) ? 0.5 : 0.1);
                y = (i + 20 > height) ? i : x;
                cairo.move_to (0, i);
                cairo.line_to (width, i);
                cairo.stroke ();
            }

            this.center = new Point (x, y);
        }

        public void clear () {
            while (series.points.size > 0) {
                this.series.points.remove_at (0);
            }
        }

        public void update () {
            this.queue_draw ();
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            draw_coordinate_axis (drawing_area, cairo, width, height);

            cairo.move_to (center.x, center.y);

            foreach (var point in series.points) {
                cairo.line_to (center.x + point.x, center.y - point.y);
            }

            cairo.stroke ();
        }
    }
}