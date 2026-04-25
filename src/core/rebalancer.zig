// Rebalancer — background thread that scans the access table and pulls hot blocks local or evicts cold blocks remote; holds migration_mutex only during the atomic ptr flip, not during the byte copy
