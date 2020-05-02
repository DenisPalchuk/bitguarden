using App.Configs;
using App.Models;
using App.Utils;
using GCrypt;

namespace App {
    public class VaultService {

        public signal void vault_unlocked();
        
        private App.SDK.BitwardenSDK bitwardenSDK;
        private const int TOTP_TFA_ID = 0;
        private string bitguarden_dir;
        private string sync_data_file = "sync-data.json";
        public uint8[] encryption_key;

        public VaultService () {
            this.bitwardenSDK = new App.SDK.BitwardenSDK (); 

            bitguarden_dir = GLib.Environment.get_user_data_dir () + "/bitguarden/";
            DirUtils.create_with_parents (bitguarden_dir, 0766);
        }

        public ErrorObject login(string email, string password, int ? two_factor_provider = null, string ? two_factor_token = null, bool two_factor_remember = true) {
            var node = this.bitwardenSDK.login(email, hash_password (password, email), two_factor_provider,two_factor_token, two_factor_remember);

            var root_object = node.get_object();

            ErrorObject error_object = check_login_response (root_object);
            if (error_object.error != null) {
                return error_object;
            }
            
            if (root_object.has_member ("access_token")
                && root_object.has_member ("refresh_token")
                && root_object.has_member ("expires_in")
                ) {
                    parse_and_update_tokens (root_object);
            }

            if (root_object.has_member ("Key")) {
                var key = root_object.get_string_member ("Key");

                try {
                encryption_key = decrypted_key (key, email, password);
                } catch (GLib.Error error) {
                    warning("Error during decrypting key: %s", error.message);
                }
            }

            return error_object;
        }

        private ErrorObject check_login_response (Json.Object root_object) {
            var error_object = new ErrorObject ();
            var error = root_object.get_string_member ("error");
            if (error != null) {
                error_object.error = error;
                error_object.error_description = root_object.get_string_member ("error_description");
                var tfa_providers = root_object.get_array_member ("TwoFactorProviders");
                if (tfa_providers != null) {
                    bool supported_tfa_found = false;
                    for (int i = 0; i < tfa_providers.get_length (); i++) {
                        if (tfa_providers.get_int_element (i) == TOTP_TFA_ID) {
                            supported_tfa_found = true;
                        }
                    }

                    if (supported_tfa_found) {
                        error_object.error = "two_factor_required";
                    } else {
                        error_object.error_description = _ ("No supported two factor provider found");
                    }
                }

                return error_object;
            }

            return error_object;
        }

        public async bool unlock (string password) {
            var parser = new Json.Parser ();
            File file = File.new_for_path (bitguarden_dir + sync_data_file);

            try {
                FileInputStream stream = yield file.read_async ();
                yield parser.load_from_stream_async (stream);
            } catch (GLib.Error error) {
                warning("Error during parsing json file: %s", error.message);
            }

            var root_object = parser.get_root ().get_object ();
            if (!root_object.has_member ("Profile")) {
                return false;
            }
            var profile = root_object.get_object_member ("Profile");
            if (!profile.has_member ("Key")) {
                return false;
            }
            var key = profile.get_string_member ("Key");
            var email = profile.get_string_member ("Email");
            try {
                encryption_key = decrypted_key (key, email, password);
                var state = App.State.get_instance ();
                state.encryption_key = (string)encryption_key;
                state.is_vault_unlocked = true;
            } catch (GLib.Error _) {
                return false;
            }
            return true;
        }

        public Json.Object ? sync () {
            if (!NetworkUtils.check_internet_connectivity ()) {
                return this.get_local_data_backup ();
            }
            var settings = App.Configs.Settings.get_instance ();
            var expiry_time = new DateTime.from_unix_utc (settings.expiry_time);
            var current_time = new DateTime.now_utc ();
            if (current_time.compare (expiry_time) >= 0) {
                var new_token_obj = this.bitwardenSDK.refresh_token_obj ();
                this.parse_and_update_tokens(new_token_obj);
            }

            
            var root_node = this.bitwardenSDK.get_vault_data(settings.access_token);
            this.backup_data_locally(settings, root_node, current_time);
            return root_node.get_object ();
        }

        public void backup_data_locally (App.Configs.Settings settings, Json.Node root_node, DateTime current_time) {
            try {
                FileUtils.set_contents (bitguarden_dir + sync_data_file, Json.to_string (root_node, false));
            } catch (GLib.FileError error) {
                warning("Error during saving json to file: %s", error.message);
            }
            
            settings.last_sync = current_time.to_unix ();
        }

        public Json.Object ? get_local_data_backup () {
            var parser = new Json.Parser ();
            
            try {
                parser.load_from_file (bitguarden_dir + sync_data_file);
                return parser.get_root ().get_object ();
            } catch (GLib.Error error) {
                warning("Error during loading json from file: %s", error.message);
                return null;
            }
            

        }

        private void parse_and_update_tokens (Json.Object object) {
            var settings = App.Configs.Settings.get_instance ();
            var access_token = object.get_string_member ("access_token");
            var refresh_token = object.get_string_member ("refresh_token");
            var expires_in = object.get_int_member ("expires_in");
            settings.access_token = access_token;
            settings.refresh_token = refresh_token;
            var expiry_time = new DateTime.now_utc ();
            expiry_time.add_seconds (expires_in);
            settings.expiry_time = expiry_time.to_unix ();
        }

        public async string ? download_and_cache_icon (string url) {
            var icon_url = Constants.BITWARDEN_ICONS_URL + "/" + url + "/icon.png";

            var icon_path = bitguarden_dir + "icons/" + Crypto.md5_string (url) + ".png";
            var icon_file = File.new_for_path (icon_path);
            if (icon_file.query_exists ()) {
                string etag;
                var icon = yield icon_file.load_bytes_async (null, out etag);

                // Check if icon is newer than 7 days
                if (((GLib.get_real_time () / 1000000) - int64.parse (etag.split (":")[0])) / 1440000 < 7) {
                    return icon_path;
                }
            }

            Soup.Session session = new Soup.Session ();
            var message = new Soup.Message ("GET", icon_url);
            var stream = yield session.send_async (message);
            var data = yield Utils.IO.input_stream_to_array(stream);

            yield icon_file.replace_contents_async(data, null, false, FileCreateFlags.NONE, null, null);

            return icon_path;
        }

        private uint8[] decrypted_key (string encrypted_key, string email, string password) throws GLib.Error {
            var key = make_key (password.data, email.down ().data, 5000);

            return decrypt_string (encrypted_key, key)[0 : 64];
        }

        private string hash_password (string password, string email, ulong iterations = 5000) {
            var key = make_key (password.data, email.data, iterations);

            return Base64.encode (make_key (key, password.data, 1));
        }

        private uint8[] make_key (uint8[] data, uint8[] salt, ulong iterations = 5000) {
            uint8 keybuffer[256 / 8];
            KeyDerivation.derive (data, KeyDerivation.Algorithm.PBKDF2, Hash.Algorithm.SHA256, salt, iterations, keybuffer);

            return keybuffer;
        }

        //  // TODO: Verify that this works
        //  private string make_enc_key (uint8[] key) {
        //      var pt = GCrypt.Random.random_bytes (64);
        //      var iv = GCrypt.Random.random_bytes (16);

        //      GCrypt.Cipher.Cipher cipher;
        //      GCrypt.Cipher.Cipher.open (out cipher, GCrypt.Cipher.Algorithm.AES256, GCrypt.Cipher.Mode.CBC, GCrypt.Cipher.Flag.SECURE);
        //      cipher.set_key (pt);
        //      cipher.set_iv (iv);
        //      uchar[] out_buffer = null;
        //      cipher.encrypt (out_buffer, key);

        //      return compose_encrypted_string (0, iv, out_buffer);
        //  }

        //  // TODO: Verify that this works
        //  private string compose_encrypted_string (int enc_type, uint8[] iv, uchar[] ct, uchar[] ? mac = null) {
        //      string outMac = null;
        //      if (mac != null) {
        //          outMac = Base64.encode (mac);
        //      }
        //      string[] v = { "%d.%s".printf (enc_type, Base64.encode (iv)), Base64.encode (ct), outMac };

        //      return string.join ("|", v);
        //  }

        // https://github.com/bitwarden/mobile/blob/1ec31c6899fd9ec6d86738986c75720ec490880f/src/App/Services/CryptoService.cs#L92
        public uint8[] decrypt_string (string encrypted_string, owned uint8[] key, owned uint8[] ? mac_key = null) throws GLib.Error {
            string[] split_string = encrypted_string.substring (2, -1).split ("|");
            var type = int.parse (encrypted_string.substring (0, 1));
            var iv = Base64.decode (split_string[0]);
            var ct = Base64.decode (split_string[1]);
            uint8[] mac = null;
            if (split_string.length > 2) {
                mac = Base64.decode (split_string[2]);
            }
            if (type == 2 && key.length == 32) {
                key = Crypto.stretch_key (key);
            }
            if (mac_key == null) {
                mac_key = key[key.length / 2 : key.length];
                key = key[0 : key.length / 2];
            }

            if (type != 0 && type != 2) {
                stderr.printf ("Type %d is not implemented", type);
            }
            if (type == 2) {
                if (mac == null) {
                    throw new GLib.Error.literal (Quark.from_string (""), -1, "mac required");
                }

                var macData = new ByteArray ();
                macData.append (iv);
                macData.append (ct);
                var cmac = Crypto.hmac (GLib.ChecksumType.SHA256, mac_key, macData.data);
                cmac = Crypto.trim_end (cmac);
                cmac = Crypto.trim_end (cmac);
                if (!Crypto.macs_equal (mac, cmac)) {
                    throw new GLib.Error.literal (Quark.from_string (""), -1, "mac is invalid");
                }
            }

            GCrypt.Cipher.Cipher cipher;
            GCrypt.Cipher.Cipher.open (out cipher, GCrypt.Cipher.Algorithm.AES256, GCrypt.Cipher.Mode.CBC, GCrypt.Cipher.Flag.SECURE);
            cipher.set_key (key);
            cipher.set_iv (iv);
            uint8[] out_buffer = new uint8[ct.length];
            cipher.decrypt (out_buffer, ct);

            return Crypto.add_terminating_zero (Crypto.remove_padding (out_buffer));
        }

        public void sync_folders_with_store () throws GLib.Error {
            var sync_data = this.sync ();
            var folders_obj = sync_data.get_array_member ("Folders");
            parse_folders (folders_obj);
            var ciphers = sync_data.get_array_member ("Ciphers");
            parse_ciphers (ciphers);
        }

        private void parse_folders (Json.Array ? folders_obj) throws GLib.Error {
            folders_obj.foreach_element ((array, index, node) => {
                var object = node.get_object ();
                var folder = new Folder ();
                folder.id = object.get_string_member ("Id");
                folder.name = this.get_decrypt_value_from_object(object, "Name");
                App.State.get_instance ().folders.set(folder.id, folder);
            });

            
        }

        private void parse_ciphers (Json.Array ? ciphers) {
            ciphers.foreach_element ((array, index, node) => {
                var object = node.get_object ();
                var login = object.get_object_member ("Login");

                var cipher = new App.Models.Cipher ();
                cipher.cipher_type = CipherType.from_type(object.get_int_member("Type"));
                cipher.name = this.get_decrypt_value_from_object(object, "Name");
                
                if (cipher.cipher_type == CipherType.PASSWORD) {
                    cipher.username = this.get_decrypt_value_from_object(login, "Username");
                    cipher.password = this.get_decrypt_value_from_object(login, "Password");
                    cipher.uri = this.get_decrypt_value_from_object(login, "Uri");
                    if (cipher.uri != null) {
                        var regex = new Regex("^https?://([^/:?#]+)(?:[/:?#]|$)");
                        var result = regex.split(cipher.uri);
                        if (result.length >= 2) {
                            this.download_and_cache_icon.begin(result[1],(obj, res) => {
                                cipher.icon = this.download_and_cache_icon.end(res);
                            });
                        }
                        
                    }
                    if (login != null && login.has_member ("Totp")) {
                        cipher.totp = this.get_decrypt_value_from_object(login, "Totp");
                    }
                    cipher.note = this.get_decrypt_value_from_object(object, "Notes");
                }

                if (cipher.cipher_type == CipherType.NOTE) {
                    cipher.note = this.get_decrypt_value_from_object(object, "Notes");
                }

                

                Folder folder = null;
                var folder_id = this.get_string_value_if_exist(object, "FolderId");
                folder = App.State.get_instance ().folders.get (folder_id);
                
                if (folder == null) {
                    folder = App.State.get_instance ().folders.get("Without folder");
                }

                folder.add_cipher (cipher);
            });
        }

        private string ? get_string_value_if_exist(Json.Object object, string key) {
            if (!object.has_member (key)) {
                return null;
            }

            return object.get_string_member (key);
        }

        private string ? get_decrypt_value_from_object (Json.Object object, string key) {
            var encrypted_value = this.get_string_value_if_exist(object, key);

            if (encrypted_value == null) {
                return null;
            }
            try {
                var decrypted_string = (string)(this.decrypt_string(encrypted_value, this.encryption_key));
                return decrypted_string;
            } catch (GLib.Error error) {
                warning("Error during string decryption %s", error.message);
                return null;
            }
        }

        

        

        private static VaultService ? instance;

        public static unowned VaultService get_instance () {
            if (instance == null) {
                instance = new VaultService ();
            }

            return instance;
        }
    }
}
