using Microsoft.Data.SqlClient;
using System;

namespace AdoNetLab
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=.;Database=SoftUni;Integrated Security=true";
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                string command = "SELECT FirstName, LastName, Salary FROM [Employees] WHERE FirstName LIKE 'N%'";
                SqlCommand sqlCommand = new SqlCommand(command, sqlConnection);

                using (SqlDataReader reader = sqlCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string firstName = (string)reader["FirstName"];
                        string lastName = (string)reader["LastName"];
                        decimal salary = (decimal)reader["Salary"];
                        Console.WriteLine(firstName + " " + lastName + " => " + salary);
                    }
                }

                SqlCommand updateSalary = new SqlCommand("UPDATE Employees SET Salary = Salary * 1.1", sqlConnection);
                int updatedRows = updateSalary.ExecuteNonQuery();

                Console.WriteLine($"Salary updated for {updatedRows}");

                var reader2 = sqlCommand.ExecuteReader();
                using (reader2)
                {
                    while (reader2.Read())
                    {
                        string firstName = (string)reader2["FirstName"];
                        string lastName = (string)reader2["LastName"];
                        decimal salary = (decimal)reader2["Salary"];
                        Console.WriteLine(firstName + " " + lastName + " => " + salary);
                    }
                }
            }
        }
    }
}
