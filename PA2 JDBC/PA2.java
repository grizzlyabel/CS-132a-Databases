import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PA2 {

	public static void main (String[] args) {

		// Database connection.
		Connection conn = null;

		try {
			// Load the JDBC class.
			Class.forName("org.sqlite.JDBC");

			// Get connection to database.

			conn = DriverManager.getConnection("jdbc:sqlite:pa2.db");
			// System.out.println("Opened database successfully.");

			Statement stmt = conn.createStatement();

			// Create the Delta table to use for the loop in the semi-naive algorithm.
			stmt.executeUpdate("DROP TABLE IF EXISTS Delta;");
			stmt.executeUpdate("CREATE TABLE Delta(Airline, Origin, Destination);");
			stmt.executeUpdate("INSERT INTO Delta SELECT Airline, Origin, Destination FROM Flight;");

			// Create the old table that will be used in the loop.
			stmt.executeUpdate("DROP TABLE IF EXISTS TOld;");
			stmt.executeUpdate("CREATE TABLE TOld(Airline char(32), Origin char(32), Destination char(32), Stops int);");
			
			// Create a copy of the Connected for use in the loop
			stmt.executeUpdate("DROP TABLE IF EXISTS Copy");
			stmt.executeUpdate("CREATE TABLE Copy(Airline char(32), Origin char(32), Destination char(32), Stops int);");
			stmt.executeUpdate("INSERT INTO Copy(Airline, Origin, Destination) SELECT airline, destination, origin FROM Flight;");

			// Retrieving current size of the table for use as loop condition.		
			int flightTotal = stmt.executeQuery("SELECT COUNT(*) FROM Delta;").getInt(1);
			// Representing the stops between cities
			int stopOvers = 0;

			// Making Stops 0 for all flights initially and Deleting NULL Values.
			stmt.executeUpdate("INSERT INTO Copy(Airline, Origin, Destination, Stops) SELECT *, 0 FROM Flight;");
			stmt.executeUpdate("DELETE FROM Copy WHERE Copy.Stops IS NULL;");

			stopOvers++;

			while (flightTotal > 0) {

				// Resetting TOld
				stmt.executeUpdate("DELETE FROM TOld;");
				stmt.executeUpdate("INSERT INTO TOld SELECT * FROM Copy;");

				// Union part where we start finding more Stops and eliminate any cycles
				stmt.executeUpdate("INSERT INTO Copy SELECT d.Airline, d.Origin, f.destination," + stopOvers + 
						" FROM Delta d, Flight f WHERE f.origin = d.Destination AND d.Airline = f.airline AND " + 
						"d.Origin <> f.destination;");

				// Set Delta to Connected - TOld
				stmt.executeUpdate("DELETE FROM Delta;");
				stmt.executeUpdate("INSERT INTO Delta SELECT Airline, Origin, Destination FROM Copy " + 
				"EXCEPT SELECT Airline, Origin, Destination FROM TOld;");

				// Updating remaining flights and stopOvers
				flightTotal = stmt.executeQuery("SELECT COUNT(*) FROM Delta;").getInt(1);		
				stopOvers++;
			}

			stmt.executeUpdate("DROP TABLE IF EXISTS Delta;");
			stmt.executeUpdate("DROP TABLE IF EXISTS TOld;");
			stmt.executeUpdate("DROP TABLE IF EXISTS Connected;");

			// Create the Connected table to input values into. 
			stmt.executeUpdate("CREATE TABLE Connected(Airline char(32), Origin char(32), Destination char(32), Stops int);");
			// Handling case with multiple paths
			stmt.executeUpdate("INSERT INTO Connected SELECT DISTINCT Airline, Origin, Destination, MIN(Stops) "
					+ "FROM Copy GROUP BY Airline, Origin, Destination;");
			
			stmt.executeUpdate("DROP TABLE IF EXISTS Copy;");

			/* Output of the Database for Testing
			ResultSet rset = stmt.executeQuery("SELECT * FROM Connected;");

			System.out.println( "\nStatement result:");

			// Traverse through Connected result table.
			while ( rset.next() ) {
				System.out.printf("AIRLINE: " + "%-10s", rset.getString("Airline"));
				System.out.printf(" ORIGIN: " + "%-25s", rset.getString("Origin"));
				System.out.printf(" DESTINATION: " + "%-10s", rset.getString("Destination"));
				System.out.printf(" Stops: " + "%-5d\n", rset.getInt("Stops"));
			}
			int count = stmt.executeQuery("SELECT COUNT(*) FROM Connected;").getInt(1);
			System.out.println(count);
			rset.close();
			*/
			
			
			stmt.close();

		} catch (Exception e) {
			throw new RuntimeException("There was a runtime problem!", e);
		}
	}

}