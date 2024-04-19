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
        public Gtk.GestureZoom zoom_gesture;
        public Point current_position;
        public double current_scale;

        public int min_x { private get; set; }
        public int max_x { private get; set; }

        public Chart () {
            Object ();
        }

        construct {
            this.series = new Gee.ArrayList<Series> ();

            this.current_position = new Point (0, 0);
            this.current_scale = 1.0;

            this.content_width = 360;
            this.content_height = 294;

            this.margin_bottom = 18;
            this.margin_top = 18;
            this.margin_start = 12;
            this.margin_end = 12;

            this.min_x = -this.get_content_width () / 16; this.max_x = this.get_content_width ();
            calculate_min_max_x ();
            this.calculate_center (this.get_content_width (), this.get_content_height ());

            this.set_draw_func (draw);

            this.move_gesture = new Gtk.GestureDrag ();
            this.zoom_gesture = new Gtk.GestureZoom ();

            this.move_gesture.drag_update.connect ((offset_x, offset_y) => {
                var move_x = center.x + ((offset_x - this.current_position.x > 0) ? 1 : -1) * (int) (offset_x - this.current_position.x).abs ();
                var move_y = center.y + ((offset_y - this.current_position.y > 0) ? 1 : -1) * (int) (offset_y - this.current_position.y).abs ();
                center = new Point ((int) move_x, (int) move_y);
                this.current_position = new Point ((int) offset_x, (int) offset_y);
                this.queue_draw ();
            });

            this.move_gesture.drag_end.connect (() => {
                this.current_position = new Point (0, 0);
            });

            this.zoom_gesture.scale_changed.connect ((scale) => {
                if (this.current_scale >= 1 / (double) this.get_content_width ()) {
                    if (this.current_scale - ((double) 1 / 100 - scale / 100) >= 1 / (double) this.get_content_width ()) {
                        this.current_scale -= ((double) 1 / 100 - scale / 100);
                    }
                    print ("scale: %f\n", this.current_scale);
                } else {
                    this.current_scale = 1 / (double) this.get_content_width ();
                }
                this.queue_draw ();
            });

            this.add_controller (this.move_gesture);
            this.add_controller (this.zoom_gesture);
        }

        public void draw (Gtk.DrawingArea drawing_area, Cairo.Context cairo, int width, int height) {
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

            double step = calculate_grid_step ((int) (width * current_scale));

            for (double i = this.center.x, j = this.center.y; (i.abs () > 0 && i < width || i.abs () < 0 && i > -width) || (j > 0 && j < height.abs () || j < 0 && j > -height.abs ()); i += step, j -= step) {
                if (i > 0 && i < width || i < 0 && i > -width) {
                    draw_line (cairo, i, 0, i, height);
                    draw_line (cairo, 2 * this.center.x - i, 0, 2 * this.center.x - i, height);
                }
                if (j > 0 && j < height.abs () || j < 0 && j > -height.abs ()) {
                    draw_line (cairo, 0, j, width, j);
                    draw_line (cairo, 0, 2 * this.center.y - j, width, 2 * this.center.y - j);
                }
            }
        }

        private void draw_series (Cairo.Context cairo, Series series_item, int width) {
            cairo.set_source_rgb (series_item.color.red, series_item.color.green, series_item.color.blue);
            cairo.move_to (calculate_x_coordinate (series_item.points.first ().x, width), calculate_y_coordinate (series_item.points.first ().y));

            foreach (var point in series_item.points) {
                cairo.line_to (calculate_x_coordinate (point.x, (int) (width * current_scale)), calculate_y_coordinate (point.y));
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

            while (step < 10 || step > 120) {
                if (step < 10) {
                    step *= 10;
                } else if (step > 120) {
                    step /= 10;
                }
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