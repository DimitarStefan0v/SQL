namespace BookShop
{
    using BookShop.Models.Enums;
    using Data;
    using Initializer;
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Linq;
    using System.Text;

    public class StartUp
    {
        public static void Main()
        {
            using var db = new BookShopContext();
            // DbInitializer.ResetDatabase(db);

            // string input = Console.ReadLine();

            // int year = int.Parse(Console.ReadLine());

            // int lengthCheck = int.Parse(Console.ReadLine());

            // string result = GetMostRecentBooks(db);

            // IncreasePrices(db);

            // Console.WriteLine(result);

            Console.WriteLine(RemoveBooks(db));
        }

        // P.02
        public static string GetBooksByAgeRestriction(BookShopContext context, string command)
        {
            var books = context.Books
                    .AsEnumerable() // Detaching from Database because EF core 3.1.3 has bug with the next line filtration
                    .Where(ar => ar.AgeRestriction.ToString().ToLower() == command.ToLower())
                    .Select(bt => bt.Title)
                    .OrderBy(b => b)
                    .ToList();

            return string.Join(Environment.NewLine, books);
        }

        // P.03
        public static string GetGoldenBooks(BookShopContext context)
        {
            List<string> books = context.Books
                    .Where(b => b.EditionType == EditionType.Gold && b.Copies < 5000)
                    .OrderBy(b => b.BookId)
                    .Select(b => b.Title)
                    .ToList();

            return string.Join(Environment.NewLine, books);
        }

        // P.04
        public static string GetBooksByPrice(BookShopContext context)
        {
            StringBuilder sb = new StringBuilder();

            var books = context.Books
                    .Where(b => b.Price > 40)
                    .OrderByDescending(b => b.Price)
                    .Select(b => new
                    {
                        b.Title,
                        b.Price
                    })
                    .ToList();

            foreach (var book in books)
            {
                sb.AppendLine($"{book.Title} - ${book.Price:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.05
        public static string GetBooksNotReleasedIn(BookShopContext context, int year)
        {
            List<string> bookTitles = context.Books
                    .Where(b => b.ReleaseDate.Value.Year != year)
                    .OrderBy(b => b.BookId)
                    .Select(b => b.Title)
                    .ToList();

            return string.Join(Environment.NewLine, bookTitles);
        }

        // P.06
        public static string GetBooksByCategory(BookShopContext context, string input)
        {
            var categoryInput = input
                    .Split(' ', StringSplitOptions.RemoveEmptyEntries)
                    .Select(c => c.ToLower())
                    .ToArray();

            List<string> bookTitles = new List<string>();

            foreach (var category in categoryInput)
            {
                List<string> currCategory = context.Books
                        .Where(b => b.BookCategories
                                        .Any(c => c.Category.Name.ToLower() == category))
                        .Select(b => b.Title)
                        .ToList();

                bookTitles.AddRange(currCategory);
            }

            bookTitles = bookTitles
                            .OrderBy(b => b)
                            .ToList();

            return string.Join(Environment.NewLine, bookTitles);
        }

        // P.07
        public static string GetBooksReleasedBefore(BookShopContext context, string date)
        {
            DateTime dateInput = DateTime.ParseExact(date, "dd-MM-yyyy", CultureInfo.InvariantCulture);

            StringBuilder sb = new StringBuilder();

            var books = context.Books
                    .Where(b => b.ReleaseDate < dateInput)
                    .OrderByDescending(b => b.ReleaseDate)
                    .Select(b => new
                    {
                        b.Title,
                        EditionType = b.EditionType.ToString(),
                        b.Price
                    })
                    .ToList();

            foreach (var book in books)
            {
                sb.AppendLine($"{book.Title} - {book.EditionType} - ${book.Price:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.08
        public static string GetAuthorNamesEndingIn(BookShopContext context, string input)
        {
            StringBuilder sb = new StringBuilder();

            var authors = context.Authors
                        .Where(a => a.FirstName.EndsWith(input))
                        .Select(a => new AuthorsFullName 
                        {
                            FullName = a.FirstName + " " + a.LastName
                        })
                        .OrderBy(a => a.FullName)
                        .ToList();

            foreach (var author in authors)
            {
                sb.AppendLine(author.FullName);
            }

            return sb.ToString().TrimEnd();
        }

        // P.09
        public static string GetBookTitlesContaining(BookShopContext context, string input)
        {
            List<string> bookTitles = context.Books
                        .Where(b => b.Title.ToLower().Contains(input.ToLower()))
                        .Select(b => b.Title)
                        .OrderBy(b => b)
                        .ToList();

            return string.Join(Environment.NewLine, bookTitles);
        }

        // P.10
        public static string GetBooksByAuthor(BookShopContext context, string input)
        {
            StringBuilder sb = new StringBuilder();

            var bookTitlesAndAuthors = context.Books
                        .Where(b => b.Author.LastName.StartsWith(input, StringComparison.InvariantCultureIgnoreCase))
                        .OrderBy(b => b.BookId)
                        .Select(b => new
                        {
                            b.Title,
                            AuthorName = b.Author.FirstName + " " + b.Author.LastName
                        })
                        .ToList();

            foreach (var item in bookTitlesAndAuthors)
            {
                sb.AppendLine($"{item.Title} ({item.AuthorName})");
            }

            return sb.ToString().TrimEnd();
        }

        // P.11
        public static int CountBooks(BookShopContext context, int lengthCheck)
        {
            int count = context.Books
                        .Where(b => b.Title.Length > lengthCheck)
                        .Select(b => b.Title)
                        .Count();

            return count;
        }

        // P.12
        public static string CountCopiesByAuthor(BookShopContext context)
        {
            StringBuilder sb = new StringBuilder();

            var authorCopies = context.Authors
                        .Select(a => new
                        {
                            FullName = a.FirstName + ' ' + a.LastName,
                            BookCopies = a.Books.Sum(b => b.Copies)
                        })
                        .OrderByDescending(b => b.BookCopies)
                        .ToList();

            foreach (var item in authorCopies)
            {
                sb.AppendLine($"{item.FullName} - {item.BookCopies}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.13
        public static string GetTotalProfitByCategory(BookShopContext context)
        {
            StringBuilder sb = new StringBuilder();

            var categoryProfits = context.Categories
                        .Select(c => new
                        {
                            c.Name,
                            TotalProfits = c.CategoryBooks
                                                .Select(cb => new
                                                {
                                                    BookProfit = cb.Book.Copies * cb.Book.Price
                                                })
                                                .Sum(cb => cb.BookProfit)
                        })
                        .OrderByDescending(c => c.TotalProfits)
                        .ThenBy(c => c.Name)
                        .ToList();

            foreach (var item in categoryProfits)
            {
                sb.AppendLine($"{item.Name} ${item.TotalProfits:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        // P.14
        public static string GetMostRecentBooks(BookShopContext context)
        {
            StringBuilder sb = new StringBuilder();

            var categoriesWithMostRecentBooks = context.Categories
                        .Select(c => new
                        {
                            CategoryName = c.Name,
                            MostRecentBooks = c.CategoryBooks
                                    .OrderByDescending(cb => cb.Book.ReleaseDate)
                                    .Take(3)
                                    .Select(cb => new
                                    {
                                        BookTitle = cb.Book.Title,
                                        ReleaseDate = cb.Book.ReleaseDate.Value.Year
                                    })
                                    .ToList()
                        })
                        .OrderBy(c => c.CategoryName)
                        .ToList();

            foreach (var item in categoriesWithMostRecentBooks)
            {
                sb.AppendLine($"--{item.CategoryName}");

                foreach (var b in item.MostRecentBooks)
                {
                    sb.AppendLine($"{b.BookTitle} ({b.ReleaseDate})");
                }
            }

            return sb.ToString().TrimEnd();
        }

        // P.15
        public static void IncreasePrices(BookShopContext context)
        {
            var books = context.Books
                        .Where(b => b.ReleaseDate.Value.Year < 2010);

            foreach (var b in books)
            {
                b.Price += 5;
            }

            context.SaveChanges();
        }

        // P.16
        public static int RemoveBooks(BookShopContext context)
        {
            var books = context.Books
                    .Where(b => b.Copies < 4200)
                    .ToArray();

            var removedBooks = books.Length;

            context.Books.RemoveRange(books);
            context.SaveChanges();

            return removedBooks;
        }

        private class AuthorsFullName
        {
            public string FullName { get; set; }
        }
    }

    
}
