using System;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using Microsoft.EntityFrameworkCore;
using SoftUni.Data;
using SoftUni.Models;

namespace SoftUni
{
    public class StartUp
    {
        static void Main(string[] args)
        {
            using SoftUniContext context = new SoftUniContext();

            string result = RemoveTown(context);

            Console.WriteLine(result);
        }

        // P.03
        public static string GetEmployeesFullInformation(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees.Select(x => new
            {
                x.FirstName,
                x.LastName,
                x.MiddleName,
                x.JobTitle,
                x.Salary
            }).ToList();

            foreach (var employee in employees)
            {
                sb.AppendLine($"{employee.FirstName} {employee.LastName} {employee.MiddleName} {employee.JobTitle} {employee.Salary:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.04
        public static string GetEmployeesWithSalaryOver50000(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(s => s.Salary > 50000)
                .Select(x => new
                {
                    x.FirstName,
                    x.Salary
                })
                .OrderBy(x => x.FirstName)
                .ToList();

            foreach (var employee in employees)
            {
                sb.AppendLine($"{employee.FirstName} - {employee.Salary:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.05
        public static string GetEmployeesFromResearchAndDevelopment(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(x => x.Department.Name == "Research and Development")
                .Select(x => new
                {
                    x.FirstName,
                    x.LastName,
                    DepartmentName = x.Department.Name,
                    x.Salary
                })
                .OrderBy(s => s.Salary)
                .ThenByDescending(f => f.FirstName)
                .ToList();

            foreach (var em in employees)
            {
                sb.AppendLine($"{em.FirstName} {em.LastName} from {em.DepartmentName} - ${em.Salary:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.06
        public static string AddNewAddressToEmployee(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            Address newAdress = new Address()
            {
                AddressText = "Vitoshka 15",
                TownId = 4
            };

            var employeeNakov = context.Employees
                .Where(x => x.LastName == "Nakov")
                .FirstOrDefault();

            employeeNakov.Address = newAdress;

            context.SaveChanges();

            var addresses = context.Employees
                .OrderByDescending(x => x.AddressId)
                .Take(10)
                .Select(x => x.Address.AddressText)
                .ToList();

            foreach (var ad in addresses)
            {
                sb.AppendLine(ad);
            }

            return sb.ToString().TrimEnd();
        }

        // P.07
        public static string GetEmployeesInPeriod(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(ep => ep.EmployeesProjects
                        .Any(p => p.Project.StartDate.Year >= 2001 && p.Project.StartDate.Year <= 2003))
                .Take(10)
                .Select(e => new
                {
                    e.FirstName,
                    e.LastName,
                    ManagerFirstName = e.Manager.FirstName,
                    ManagerLastName = e.Manager.LastName,
                    Projects = e.EmployeesProjects.Select(x => new
                    {
                        ProjectName = x.Project.Name,
                        StartDate = x.Project.StartDate.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture),
                        EndDate = x.Project.EndDate.HasValue ?
                               x.Project.EndDate.Value.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture) :
                                  "not finished"
                    }).ToList(),

                }).ToList();

            foreach (var em in employees)
            {
                sb.AppendLine($"{em.FirstName} {em.LastName} - Manager: {em.ManagerFirstName} {em.ManagerLastName}");

                foreach (var project in em.Projects)
                {
                    sb.AppendLine($"--{project.ProjectName} - {project.StartDate} - {project.EndDate}");
                }
            }

            return sb.ToString().TrimEnd();
        }

        // P.08
        public static string GetAddressesByTown(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var addresses = context.Addresses
                .Select(a => new
                {
                    a.AddressText,
                    TownName = a.Town.Name,
                    EmployeesCount = a.Employees.Count()
                })
                .OrderByDescending(e => e.EmployeesCount)
                .ThenBy(t => t.TownName)
                .ThenBy(a => a.AddressText)
                .Take(10)
                .ToList();

            foreach (var ad in addresses)
            {
                sb.AppendLine($"{ad.AddressText}, {ad.TownName} - {ad.EmployeesCount} employees");
            }

            return sb.ToString().TrimEnd();
        }

        // P.09
        public static string GetEmployee147(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employee = context.Employees
                .Where(e => e.EmployeeId == 147)
                .Select(x => new
                {
                    x.FirstName,
                    x.LastName,
                    x.JobTitle,
                    ProjectsName = x.EmployeesProjects.Select(p => new
                    {
                        p.Project.Name
                    })
                    .OrderBy(p => p.Name)
                    .ToList()
                })
                .ToList();

            foreach (var item in employee)
            {
                sb.AppendLine($"{item.FirstName} {item.LastName} - {item.JobTitle}");

                foreach (var project in item.ProjectsName)
                {
                    sb.AppendLine($"{project.Name}");
                }
            }

            return sb.ToString().TrimEnd();
        }

        // P.10
        public static string GetDepartmentsWithMoreThan5Employees(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var departments = context.Departments
                .Where(e => e.Employees.Count() > 5)
                .OrderBy(c => c.Employees.Count())
                .ThenBy(n => n.Name)
                .Select(d => new
                {
                    d.Name,
                    ManagerFirstName = d.Manager.FirstName,
                    ManagerLastName = d.Manager.LastName,
                    EmployeesInfo = d.Employees.Select(e => new
                    {
                        EmployeeFirstName = e.FirstName,
                        EmployeeLastName = e.LastName,
                        e.JobTitle
                    })
                    .OrderBy(x => x.EmployeeFirstName)
                    .ThenBy(x => x.EmployeeLastName)
                    .ToList()
                }).ToList();

            foreach (var department in departments)
            {
                sb.AppendLine($"{department.Name} - {department.ManagerFirstName}  {department.ManagerLastName}");

                foreach (var employee in department.EmployeesInfo)
                {
                    sb.AppendLine($"{employee.EmployeeFirstName} {employee.EmployeeLastName} - {employee.JobTitle}");
                }
            }

            return sb.ToString().TrimEnd();
        }

        // P.11
        public static string GetLatestProjects(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var projects = context.Projects
                .OrderByDescending(s => s.StartDate)
                .Take(10)
                .OrderBy(n => n.Name)
                .Select(p => new
                {
                    p.Name,
                    p.Description,
                    StartDate = p.StartDate.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture)
                })
                .ToList();

            foreach (var project in projects)
            {
                sb.AppendLine(project.Name);
                sb.AppendLine(project.Description);
                sb.AppendLine(project.StartDate);
            }

            return sb.ToString().TrimEnd();
        }

        // P.12
        public static string IncreaseSalaries(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            IQueryable<Employee> employeesToIncrease = context.Employees.Where(d => d.Department.Name == "Engineering" ||
                                         d.Department.Name == "Tool Design" || d.Department.Name == "Marketing" ||
                                         d.Department.Name == "Information Services");


            foreach (var em in employeesToIncrease)
            {
                em.Salary *= 1.12m;
            }

            context.SaveChanges();

            var employees = employeesToIncrease.Select(e => new
            {
                e.FirstName,
                e.LastName,
                e.Salary
            })
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .ToList();

            foreach (var employee in employees)
            {
                sb.AppendLine($"{employee.FirstName} {employee.LastName} (${employee.Salary:f2})");
            }

            return sb.ToString().TrimEnd();
        }

        // P.13
        public static string GetEmployeesByFirstNameStartingWithSa(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var employees = context.Employees
                .Where(f => f.FirstName.StartsWith("Sa"))
                .Select(e => new
                {
                    e.FirstName,
                    e.LastName,
                    e.JobTitle,
                    e.Salary
                })
                .OrderBy(e => e.FirstName)
                .ThenBy(e => e.LastName)
                .ToList();

            foreach (var em in employees)
            {
                sb.AppendLine($"{em.FirstName} {em.LastName} - {em.JobTitle} - (${em.Salary:f2})");
            }

            return sb.ToString().TrimEnd();
        }

        // P.14
        public static string DeleteProjectById(SoftUniContext context)
        {
            StringBuilder sb = new StringBuilder();

            var projectToDelete = context.Projects
                .Find(2);

            foreach (var item in context.EmployeesProjects.Where(p => p.Project.ProjectId == 2))
            {
                context.EmployeesProjects.Remove(item);
            }

            context.Projects.Remove(projectToDelete);

            context.SaveChanges();

            var projects = context.Projects.Take(10).Select(pn => pn.Name);

            foreach (var pr in projects)
            {
                sb.AppendLine(pr);
            }

            return sb.ToString().TrimEnd();
        }

        // P.15
        public static string RemoveTown(SoftUniContext context)
        {
            var townToDelete = context.Towns
                .First(t => t.Name == "Seattle");

            IQueryable<Address> addressesToDel = context.Addresses
                .Where(t => t.TownId == townToDelete.TownId);

            int addressesCount = addressesToDel.Count();

            IQueryable<Employee> employeesOnDeletedAddress = context.Employees
                .Where(e => addressesToDel.Any(a => a.AddressId == e.AddressId));

            foreach (var e in employeesOnDeletedAddress)
            {
                e.AddressId = null;
            }

            foreach (var address in addressesToDel)
            {
                context.Addresses.Remove(address);
            }

            context.Towns.Remove(townToDelete);

            context.SaveChanges();

            return $"{addressesCount} addresses in Seattle were deleted";
        }
    }
}
