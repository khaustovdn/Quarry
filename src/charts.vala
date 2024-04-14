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
        public Gee.ArrayList<Series> series { get; construct; }
        public Point center { get; set; }

        public Charts () {
            Object ();
        }

        construct {

            this.series = new Gee.ArrayList<Series> ();

            this.width_request = 360;
            this.height_request = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.set_draw_func (draw);
        }

        private void draw_axis (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            cairo.set_line_width (0.5);

            cairo.move_to (center.x, 0);
            cairo.line_to (center.x, height);
            cairo.move_to (0, center.y);
            cairo.line_to (width, center.y);

            cairo.stroke ();

            cairo.set_line_width (0.1);

            for (double i = center.x; i > 0; i -= center.x.abs ()) {
                cairo.move_to (i, 0);
                cairo.line_to (i, height);
                cairo.stroke ();
            }

            for (double i = center.x; i < width; i += center.x.abs ()) {
                cairo.move_to (i, 0);
                cairo.line_to (i, height);
                cairo.stroke ();
            }

            for (double i = center.y; i > 0; i -= center.y.abs () / 5) {
                cairo.move_to (0, i);
                cairo.line_to (width, i);
                cairo.stroke ();
            }

            for (double i = center.y; i < height; i += center.y.abs () / 5) {
                cairo.move_to (0, i);
                cairo.line_to (width, i);
                cairo.stroke ();
            }
        }

        public void clear () {
            while (series.size > 0) {
                this.series.remove_at (0);
            }
        }

        public void update () {
            this.queue_draw ();
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            var min_x = 0, max_x = 0;

            if (series.size > 0) {
                min_x = max_x = series.first ().points.first ().x;

                foreach (var series_item in series) {
                    foreach (var point in series_item.points) {
                        if (point.x < min_x) {
                            min_x = point.x;
                        }
                        if (point.x > max_x) {
                            max_x = point.x;
                        }
                    }
                }
            }

            this.center = new Point (width / 16, 15 * height / 16);

            draw_axis (drawing_area, cairo, width, height);

            cairo.set_line_width (1.0);

            cairo.move_to (center.x, center.y);

            foreach (var series_item in series) {
                cairo.set_source_rgb (series_item.color.r, series_item.color.g, series_item.color.b);
                foreach (var point in series_item.points) {
                    cairo.line_to (center.x + point.x, center.y - point.y);
                }

                cairo.stroke ();
            }
        }
    }
}