namespace App.Models {
    public class Cipher {
        public string id { get; set; }
        public string name { get; set; }
        public string username { get; set; }
        public string password { get; set; }
        public string uri { get; set; }
        public string totp { get; set; }
        public string note { get; set; }
        public CipherType cipher_type { get; set; default = CipherType.PASSWORD; }
    }

    public enum CipherType {
        PASSWORD,
        NOTE,
        CARD;

        public static CipherType from_type(int64 type) {
            switch (type) {
                case 1:
                    return CipherType.PASSWORD;

                case 2:
                    return CipherType.NOTE;

                case 3:
                    return CipherType.CARD;

                default:
                    warning("unsupported cipher type %i", (int)type);
                    assert_not_reached();
            }
        }
    }
}
