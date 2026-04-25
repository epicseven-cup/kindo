// ConnectionCache — stores *Connection by pointer so the mutex is never moved when the map resizes;
// lazy connections evicted after idle timeout; one permanent connection to seed (v1)
