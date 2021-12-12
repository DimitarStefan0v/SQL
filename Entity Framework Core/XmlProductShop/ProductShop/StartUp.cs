using ProductShop.Data;
using ProductShop.Dtos.Export;
using ProductShop.Dtos.Import;
using ProductShop.Models;
using ProductShop.XmlHelper;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Serialization;

namespace ProductShop
{
    public class StartUp
    {
        public static void Main(string[] args)
        {
            using ProductShopContext context = new ProductShopContext();

            context.Database.EnsureDeleted();
            context.Database.EnsureCreated();

            var usersXml = File.ReadAllText("../../../Datasets/users.xml");
            var productsXml = File.ReadAllText("../../../Datasets/products.xml");
            var categoriesXml = File.ReadAllText("../../../Datasets/categories.xml");
            var categoryProductsXml = File.ReadAllText("../../../Datasets/categories-products.xml");

            ImportUsers(context, usersXml);
            ImportProducts(context, productsXml);
            ImportCategories(context, categoriesXml);
            ImportCategoryProducts(context, categoryProductsXml);

            var productsInRange = GetProductsInRange(context);
            File.WriteAllText("../../../results/productsInRange.xml", productsInRange);

            var soldProducts = GetSoldProducts(context);
            File.WriteAllText("../../../results/soldProducts.xml", soldProducts);
        }

        public static string ImportUsers(ProductShopContext context, string inputXml)
        {
            const string rootElement = "Users";
            var userResults = XmlConverter.Deserializer<ImportUserDto>(inputXml, rootElement);

            //List<User> users = new List<User>();

            //foreach (var importUserDtos in userResults)
            //{
            //    var user = new User()
            //    {
            //        FirstName = importUserDtos.FirstName,
            //        LastName = importUserDtos.LastName,
            //        Age = importUserDtos.Age
            //    };

            //    users.Add(user);
            //}

            var users = userResults.Select(u => new User()
            {
                FirstName = u.FirstName,
                LastName = u.LastName,
                Age = u.Age
            })
            .ToArray();

            context.Users.AddRange(users);
            context.SaveChanges();

            return $"Successfully imported {users.Length}";
        }

        public static string ImportProducts(ProductShopContext context, string inputXml)
        {
            const string rootElement = "Products";

            var productDto = XmlConverter.Deserializer<ImportProductDto>(inputXml, rootElement);

            var products = productDto.Select(p => new Product
            {
                Name = p.Name,
                Price = p.Price,
                BuyerId = p.BuyerId,
                SellerId = p.SellerId
            })
            .ToArray();

            context.Products.AddRange(products);
            context.SaveChanges();

            return $"Successfully imported {products.Length}";
        }

        public static string ImportCategories(ProductShopContext context, string inputXml)
        {
            const string rootElement = "Categories";

            var categoriesDto = XmlConverter.Deserializer<ImportCategoryDto>(inputXml, rootElement);

            List<Category> categories = new List<Category>();

            foreach (var dto in categoriesDto)
            {
                if (dto.Name == null)
                {
                    continue;
                }

                var category = new Category
                {
                    Name = dto.Name
                };

                categories.Add(category);
            }

            context.Categories.AddRange(categories);
            context.SaveChanges();

            return $"Successfully imported {categories.Count}";
        }

        public static string ImportCategoryProducts(ProductShopContext context, string inputXml)
        {
            var rootElement = "CategoryProducts";

            var categoriesProducts = XmlConverter.Deserializer<ImportCategoriesProductsDto>(inputXml, rootElement);

            var categories = new List<CategoryProduct>();

            foreach (var category in categoriesProducts)
            {
                var doesExist = context.Products.Any(x => x.Id == category.ProductId) &&
                    context.Categories.Any(y => y.Id == category.CategoryId);

                if (!doesExist)
                {
                    continue;
                }

                var categoryProduct = new CategoryProduct
                {
                    CategoryId = category.CategoryId,
                    ProductId = category.ProductId
                };

                categories.Add(categoryProduct);
            }

            context.CategoryProducts.AddRange(categories);
            context.SaveChanges();

            return $"Successfully imported {categories.Count}";
        }

        public static string GetProductsInRange(ProductShopContext context)
        {
            const string rootElement = "Products";

            var products = context.Products
                .Where(p => p.Price >= 500 && p.Price <= 1000)
                .Select(p => new ExportProductDto
                {
                    Name = p.Name,
                    Price = p.Price,
                    Buyer = p.Buyer.FirstName + " " + p.Buyer.LastName
                })
                .OrderBy(p => p.Price)
                .Take(10)
                .ToArray();

            var result = XmlConverter.Serialize(products, rootElement);

            return result;
        }

        public static string GetSoldProducts(ProductShopContext context)
        {
            var rootElement = "Users";

            var users = context.Users
                .Where(u => u.ProductsSold.Any())
                .Select(u => new ExportSoldProductDto
                {
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    soldProducts = u.ProductsSold.Select(p => new UserProductDto
                    {
                        Name = p.Name,
                        Price = p.Price
                    })
                    .Take(5)
                    .ToArray()
                })
                .OrderBy(l => l.LastName)
                .ThenBy(f => f.FirstName)
                .ToArray();

            var result = XmlConverter.Serialize(users, rootElement);

            return result;
        }
    }
}