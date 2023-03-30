[CCode (cheader_filename = "hidapi/hidapi.h")]
namespace HID {
    [Compact, CCode (cname = "hid_device", free_function = "")]
    public class Device {
        // HID_API_EXPORT hid_device * HID_API_CALL hid_open(unsigned short vendor_id, unsigned short product_id, const wchar_t *serial_number);
        [CCode (cname = "hid_open")]
        public Device(short vendorId, short productId, uint16 *serialNumber);

        // int HID_API_EXPORT HID_API_CALL hid_send_feature_report(hid_device *dev, const unsigned char *data, size_t length);
        [CCode (cname = "hid_send_feature_report")]
        public int SendFeatureReport([CCode (array_length = false)] char[] data, size_t length);

        // int  HID_API_EXPORT HID_API_CALL hid_read(hid_device *dev, unsigned char *data, size_t length);
        [CCode (cname = "hid_read")]
        public int Read([CCode (array_length = false)] char[] data, size_t length);

        // void HID_API_EXPORT HID_API_CALL hid_close(hid_device *dev);
        [CCode (cname = "hid_close")]
        public void Close();
    }
    [CCode (cname = "hid_init")]
    int Init();
    [CCode (cname = "hid_exit")]
    int Exit();
}