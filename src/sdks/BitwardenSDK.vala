using App.Models;
using App.Configs;
using GCrypt;

namespace App.SDK {
    class BitwardenSDK {

        private Soup.Session session;
        

        public BitwardenSDK () {
            session = new Soup.Session ();
            session.user_agent = "%s/%s".printf (Constants.BITWARDEN_USER_AGENT, Constants.VERSION);
        }

        public Json.Node login (string email, string hashed_password, int ? two_factor_provider = null, string ? two_factor_token = null, bool two_factor_remember = true) {
            var url = "%s/connect/token".printf (Constants.BITWARDEN_IDENTITY_URL);
            HashTable<string, string> form_data = new HashTable<string, string>(str_hash, str_equal);
            var settings = App.Configs.Settings.get_instance ();
            form_data.insert ("grant_type", "password");
            form_data.insert ("username", email);
            form_data.insert ("password", hashed_password);
            form_data.insert ("scope", "api offline_access");
            form_data.insert ("client_id", Constants.BITWARDEN_CLIENT_ID);
            form_data.insert ("deviceType", "3");
            form_data.insert ("deviceIdentifier", settings.device_identifier);
            form_data.insert ("deviceName", "firefox");
            form_data.insert ("devicePushToken", "");
            if (two_factor_provider != null && two_factor_token != null) {
                form_data.insert ("twoFactorProvider", two_factor_provider.to_string ());
                form_data.insert ("twoFactorToken", two_factor_token);
                form_data.insert ("twoFactorRemember", two_factor_remember.to_string ());
            }

            Soup.Message message = Soup.Form.request_new_from_hash ("POST", url, form_data);

            var parser = make_request (message);

            return parser.get_root ();
        }

        

        public Json.Object refresh_token_obj () {
            var url = "%s/connect/token".printf (Constants.BITWARDEN_IDENTITY_URL);
            HashTable<string, string> form_data = new HashTable<string, string>(str_hash, str_equal);
            var settings = App.Configs.Settings.get_instance ();
            form_data.insert ("grant_type", "refresh_token");
            form_data.insert ("client_id", Constants.BITWARDEN_CLIENT_ID);
            form_data.insert ("refresh_token", settings.refresh_token);

            Soup.Message message = Soup.Form.request_new_from_hash ("POST", url, form_data);

            var parser = make_request (message);
            return parser.get_root ().get_object ();
        }

        private Json.Parser make_request (Soup.Message message) {
            session.send_message (message);

            var parser = new Json.Parser ();

            try {
                parser.load_from_data ((string) message.response_body.data, -1);
            } catch (GLib.Error e) {
                stderr.printf ("I think something went wrong!\n");
            }

            return parser;
        }

        public Json.Node get_vault_data(string access_token) {
            var url = "%s/sync".printf (Constants.BITWARDEN_BASE_URL);
            Soup.Message message = new Soup.Message ("GET", url);
            if (access_token != null) {
                message.request_headers.append ("Authorization", "Bearer %s".printf (access_token));
            }

            var parser = make_request (message);
            return parser.get_root();
        }

        
    }    
}
