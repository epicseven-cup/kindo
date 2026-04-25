// Wire format — 14-byte packed WireHeader (version, msg_type, msg_id, msg_size) plus typed payload structs;
// msg_size capped at MAX_MSG_SIZE (64mb) before any allocation to prevent DoS via crafted headers
