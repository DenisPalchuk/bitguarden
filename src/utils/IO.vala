namespace App.Utils {
    public class IO {
        public static async uint8[] input_stream_to_array (InputStream stream) {
            var result = new ByteArray ();
            uint8[] buffer = new uint8[1024];
            size_t bytes_read = -1;
            while (bytes_read != 0) {
                try {
                    yield stream.read_all_async (buffer, Priority.DEFAULT_IDLE, null, out bytes_read);
                    result.append (buffer);
                }   catch (GLib.Error error) {
                    warning("Error during reading data from stream: %s", error.message);
                }
            }

            return result.data;
        }
    }
}
