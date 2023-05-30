
public struct Reading {
    public double TemperatureKelvin;
    public uint16 CO2PPM;

    public double TemperatureCelcius() {
        return TemperatureKelvin - 273.15;
    }
}

public class CO2Monitor {
    HID.Device device;
    char[] key;
    char[] buf;

    public CO2Monitor() {
        HID.Init();
        key = new char[9];
        buf = new char[8];
        Refresh();
    }

    ~CO2Monitor() {
        if(device != null)
            device.Close();
        HID.Exit();
    }

    public void Refresh() {
        if (device != null) {
            device.Close();
        }
        device = new HID.Device(0x04d9, 0xa052, null);
        if(device != null)
            device.SendFeatureReport(key, 9);
    }

    public Reading Read() {
        Reading r = {0};
        if(device == null) {
            this.Refresh();
            if(device == null) {
                GLib.Thread.usleep(3000000);
                return r;
            }
        }
        bool readTemp = false;
        bool readCO2 = false;
        while (device.Read(buf, 8) > 0) {
            uint8 first = buf[2] ^ key[0];
            uint8 last = buf[3] ^ key[7];
            uint8 unit = ((first >> 3) | (last << 5)) - 0x84;
            if(unit == 0x50) {
                uint8 second = buf[4] ^ key[1];
                uint8 third = buf[0] ^ key[2];
                uint8 high = ((second >> 3) | (first << 5)) - 0x47;
                uint8 low = ((third >> 3) | (second << 5)) - 0x56;
                uint16 value = (((uint16)high) << 8) | ((uint16)low);
                r.CO2PPM = value;
                if (readTemp)
                    break;
                readCO2 = true;
            } else if (unit == 0x42) {
                uint8 second = buf[4] ^ key[1];
                uint8 third = buf[0] ^ key[2];
                uint8 high = ((second >> 3) | (first << 5)) - 0x47;
                uint8 low = ((third >> 3) | (second << 5)) - 0x56;
                uint16 value = (((uint16)high) << 8) | ((uint16)low);
                r.TemperatureKelvin = ((double)(value)) / 16.0;
                if (readCO2)
                    break;
                readTemp = true;
            }
        }
        return r;
    }
}
