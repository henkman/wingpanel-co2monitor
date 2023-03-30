public class Sample.Indicator : Wingpanel.Indicator {
    private CO2Monitor co2monitor;
    private Gtk.Grid displayWidget;
    private Gtk.Label tempLabel;
    private Gtk.Label co2Label;
    private Thread<void> readThread;
    private bool running;

    public Indicator () {
        Object (code_name : "co2monitor");
    }

    ~Indicator() {
        running = false;
        readThread.join();
    }

    construct {
        co2monitor = new CO2Monitor();
        this.visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        if(displayWidget == null) {
            tempLabel = new Gtk.Label("");
            co2Label = new Gtk.Label("");

            displayWidget = new Gtk.Grid ();
            displayWidget.attach (tempLabel, 0, 0);
            displayWidget.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL) {
                margin_left = 2,
                margin_right = 2
            }, 1, 0);
            displayWidget.attach (co2Label, 2, 0);
            readThread = new Thread<void>("read", readFunc);
        }
        return displayWidget;
    }

    public override Gtk.Widget? get_widget () {
        return null;
    }

    public override void opened () {}
    public override void closed () {}

    private void readFunc() {
        running = true;
        while(running) {
            Reading r = co2monitor.Read();
            tempLabel.set_markup("<span size=\"13pt\">%.2f °C</span>".printf(r.TemperatureCelcius()));
            if (r.CO2PPM < 400)
                co2Label.set_markup("<span size=\"13pt\" color=\"#29AB87\">%d PPM</span>".printf(r.CO2PPM));
            else if (r.CO2PPM < 600)
                co2Label.set_markup("<span size=\"13pt\" color=\"#228B22\">%d PPM</span>".printf(r.CO2PPM));
            else if (r.CO2PPM < 800)
                co2Label.set_markup("<span size=\"13pt\" color=\"#568203\">%d PPM</span>".printf(r.CO2PPM));
            else if (r.CO2PPM < 1000)
                co2Label.set_markup("<span size=\"13pt\" color=\"#FDFF00\">%d PPM</span>".printf(r.CO2PPM));
            else if (r.CO2PPM < 1200)
                co2Label.set_markup("<span size=\"13pt\" color=\"#FD320C\">%d PPM</span>".printf(r.CO2PPM));
            else
                co2Label.set_markup("<span size=\"13pt\" color=\"#FF0000\">%d PPM</span>".printf(r.CO2PPM));
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        return null;
    }
    return new Sample.Indicator ();
}