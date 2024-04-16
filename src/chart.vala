/* chart.vala
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
    public class Chart : Gtk.DrawingArea {
        public Gee.ArrayList<Series> series { get; construct; }
        public Point center { get; set; }

        public int min_x { private get; set; }
        public int max_x { private get; set; }

        public Chart () {
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

            cairo.move_to (this.center.x, 0);
            cairo.line_to (this.center.x, height);
            cairo.move_to (0, this.center.y);
            cairo.line_to (width, this.center.y);

            cairo.stroke ();

            cairo.set_line_width (0.1);

            for (double i = this.center.x; i > 0; i -= (60 / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ()))) {
                cairo.move_to (i, 0);
                cairo.line_to (i, height);
                cairo.stroke ();
            }

            for (double i = this.center.x; i < width; i += (60 / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ()))) {
                cairo.move_to (i, 0);
                cairo.line_to (i, height);
                cairo.stroke ();
            }

            for (double i = this.center.y; i > 0; i -= (60 / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ()))) {
                cairo.move_to (0, i);
                cairo.line_to (width, i);
                cairo.stroke ();
            }

            for (double i = this.center.y; i < height; i += (60 / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ()))) {
                cairo.move_to (0, i);
                cairo.line_to (width, i);
                cairo.stroke ();
            }
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            this.min_x = 0;
            this.max_x = width;

            if (this.series.size > 0) {
                this.min_x = this.max_x = this.series.first ().points.first ().x;

                foreach (var series_item in this.series) {
                    foreach (var point in series_item.points) {
                        if (point.x < this.min_x) {
                            this.min_x = point.x;
                        }
                        if (point.x > this.max_x) {
                            this.max_x = point.x;
                        }
                    }
                }
            }

            this.center = new Point (-(int) (this.min_x / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ())), 15 * height / 16);

            draw_axis (drawing_area, cairo, width, height);

            cairo.set_line_width (1.0);

            foreach (var series_item in this.series) {
                cairo.set_source_rgb (series_item.color.r, series_item.color.g, series_item.color.b);
                cairo.move_to (this.center.x + (series_item.points.first ().x / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ())), this.center.y - (series_item.points.first ().y* 10));
                foreach (var point in series_item.points) {
                    cairo.line_to (this.center.x + (point.x / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ())), this.center.y - (point.y * 10));
                }
                cairo.stroke ();
            }
        }
    }
}