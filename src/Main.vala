public static int main (string[] args) {
	int op = 0;

	// Open a database:
	Sqlite.Database db;
	int ec = Sqlite.Database.open ("icons_missing.db", out db);
	if (ec != Sqlite.OK) {
		stderr.printf ("Can't open database: %s\n", get_database_error_message (db));
		return -1;
	}

	do {
		stdout.printf ("""
=== Select Option:
1- Create Table
2- Insert new record
3- Show all values
4- Get by icon value
0- Exit

Op Code: """);

		op = int.parse (stdin.read_line ());

		switch (op) {
			case 0: stdout.printf ("Exiting...\n"); break;
			case 1: create_table (db); break;
			case 2: create_record (db); break;
			case 3: get_all (db); break;
			case 4: get_by_icon_value (db); break;
			default: stdout.printf ("Invalid option!"); break;
		}

	} while (op != 0);

	return 0;
}

public static string get_database_error_message (Sqlite.Database db) {
	int code_error = db.errcode ();
	string errmsg = db.errmsg ();

	return @"$code_error: $errmsg";
}

public static bool create_table (Sqlite.Database db) {
	string errmsg;

	// Create table
	string query = """
		CREATE TABLE icons (
			id			INTEGER		PRIMARY KEY		NOT NULL,
			app_name	TEXT						NOT NULL,
			icon		TEXT		UNIQUE			NOT NULL,
			icon_link	TEXT						NOT NULL
		);
	""";

	int ec = db.exec (query, null, out errmsg);
	if (ec != Sqlite.OK) {
		stderr.printf ("Error: %s!\n", errmsg);
		return false;
	}
	stdout.printf ("Successfully created table!\n");
	return true;
}

public static bool create_record (Sqlite.Database db) {
	// TODO Block duplicate entries when insert

	string errmsg;

	print ("App name: ");
	string app_name = stdin.read_line ();

	print ("Icon: ");
	string icon = stdin.read_line ();

	print ("Icon link: ");
	string icon_link = stdin.read_line ();

	// Create table
	string query = @"INSERT INTO icons (app_name,icon,icon_link) values ('$app_name', '$icon', '$icon_link')";

	int ec = db.exec (query, null, out errmsg);
	if (ec != Sqlite.OK) {
		if (errmsg.contains ("UNIQUE constraint failed")) {
			errmsg = "This icon is already registered";
		}
		stderr.printf ("Error: %s!\n", errmsg);
		return false;
	}
	stdout.printf ("Successfully created record!\n");
	return true;
}

public static void get_all (Sqlite.Database db) {
	int ec;

	Sqlite.Statement stmt;

	const string prepared_query_str = "SELECT id, icon FROM icons";
	ec = db.prepare_v2 (prepared_query_str, prepared_query_str.length, out stmt);

	if (ec != Sqlite.OK) {
		stderr.printf ("Error: %s\n", get_database_error_message (db));
	}

	//
	// Use the prepared statement:
	//
	int cols = stmt.column_count ();
	print ("\n");
	for (int i = 0; i < cols; i++) {
		string col_name = stmt.column_name (i) ?? "<none>";
		print ("%s\t", col_name);
	}
	print ("\n");
	while (stmt.step () == Sqlite.ROW) {
		for (int i = 0; i < cols; i++) {
			string val = stmt.column_text (i) ?? "<none>";
			print ("%s\t", val);
		}
		print ("\n");
	}
	print ("\n");
	// Reset the statement to rebind parameters:
	stmt.reset ();
}

public static void get_by_icon_value (Sqlite.Database db) {
	int ec;
	print ("Icon value: ");
	string icon_link = stdin.read_line ();

	Sqlite.Statement stmt;

	string prepared_query_str = @"SELECT icon_link FROM icons where icon = '$icon_link'";
	ec = db.prepare_v2 (prepared_query_str, prepared_query_str.length, out stmt);

	if (ec != Sqlite.OK) {
		stderr.printf ("Error: %s\n", get_database_error_message (db));
	}

	//
	// Use the prepared statement:
	//
	print ("Icon link: ");
	while (stmt.step () == Sqlite.ROW) {
		string val = stmt.column_text (0) ?? "<none>";
		print ("%s", val);
	}
	print ("\n");
	// Reset the statement to rebind parameters:
	stmt.reset ();
}
