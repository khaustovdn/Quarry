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
        public Gtk.GestureDrag move_gesture;
        public Point current_position;

        public int min_x { private get; set; }
        public int max_x { private get; set; }

        public Chart () {
            Object ();
        }

        construct {
            this.series = new Gee.ArrayList<Series> ();

            this.content_width = 360;
            this.content_height = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.min_x = -this.get_content_width () / 16; this.max_x = this.get_content_width ();
            this.calculate_center (this.get_content_width (), this.get_content_height ());

            this.set_draw_func (draw);

            this.move_gesture = new Gtk.GestureDrag ();

            this.move_gesture.drag_update.connect ((_, x_pos, y_pos) => {
                var move_x = center.x + ((x_pos - this.current_position.x > 0) ? 1 : -1) * (int) (x_pos - this.current_position.x).abs ();
                var move_y = center.y + ((y_pos - this.current_position.y > 0) ? 1 : -1) * (int) (y_pos - this.current_position.y).abs ();
                center = new Point ((int) move_x, (int) move_y);
                this.current_position = new Point ((int) x_pos, (int) y_pos);
                this.queue_draw ();
            });

            this.move_gesture.drag_end.connect ((_, x, y) => {
                this.current_position = new Point (0, 0);
            });

            this.add_controller (this.move_gesture);
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
            calculate_min_max_x ();
            draw_grid (drawing_area, cairo, width, height);

            cairo.set_line_width (1.0);

            foreach (var series_item in this.series) {
                draw_series (cairo, series_item, width);
            }
        }

        private void draw_grid (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {

            cairo.set_line_width (0.5);

            draw_line (cairo, this.center.x, 0, this.center.x, height);
            draw_line (cairo, 0, this.center.y, width, this.center.y);

            cairo.set_line_width (0.1);
            cairo.set_source_rgb (0.5, 0.5, 0.5);

            double step = calculate_grid_step (width);

            for (double i = this.center.x, j = this.center.y; (i.abs () > 0 && i.abs () < width) || (j.abs () > 0 && j.abs () < height); i += step, j -= step) {
                if (i.abs () > 0 && i.abs () < width) {
                    draw_line (cairo, i, 0, i, height);
                    draw_line (cairo, 2 * this.center.x - i, 0, 2 * this.center.x - i, height);
                }
                if (j.abs () > 0 && j.abs () < height) {
                    draw_line (cairo, 0, j, width, j);
                    draw_line (cairo, 0, 2 * this.center.y - j, width, 2 * this.center.y - j);
                }
            }
        }

        private void draw_series (Cairo.Context cairo, Series series_item, int width) {
            cairo.set_source_rgb (series_item.color.red, series_item.color.green, series_item.color.blue);
            cairo.move_to (calculate_x_coordinate (series_item.points.first ().x, width), calculate_y_coordinate (series_item.points.first ().y));

            foreach (var point in series_item.points) {
                cairo.line_to (calculate_x_coordinate (point.x, width), calculate_y_coordinate (point.y));
            }

            cairo.stroke ();
        }

        private void draw_line (Cairo.Context cairo, double x1, double y1, double x2, double y2) {
            cairo.move_to (x1, y1);
            cairo.line_to (x2, y2);
            cairo.stroke ();
        }

        private void calculate_center (int width, int height) {
            this.center = new Point (-(int) (this.min_x / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ())), 15 * height / 16);
        }

        private double calculate_x_coordinate (double x, int width) {
            return this.center.x + (x / ((double) (this.max_x - this.min_x).abs () / (double) (width).abs ()));
        }

        private double calculate_y_coordinate (double y) {
            return this.center.y - (y * 10);
        }

        private double calculate_grid_step (int width) {
            double step = 60 / ((double) (this.max_x - this.min_x).abs () / (double) width.abs ());

            while (step < 10) {
                step *= 10;
            }

            return step;
        }

        private void calculate_min_max_x () {
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
        }
    }
}