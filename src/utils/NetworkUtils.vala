namespace App.Utils {
    public class NetworkUtils {
        public static bool check_internet_connectivity () {
            try {
                Socket socket = new Socket (SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
                assert (socket != null);

                var googleAddress = new InetAddress.from_string ("8.8.8.8");
                var googleDns = new InetSocketAddress (googleAddress, 53);

                socket.connect (googleDns);
                socket.close ();
            } catch (GLib.Error e) {
                return false;
            }

            return true;
        }

        public static string get_host_name (string uri) {
            return GLib.NetworkAddress.parse_uri (uri, 80).get_hostname ();
        }
    }
}
