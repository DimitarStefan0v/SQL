namespace VaporStore.DataProcessor.Dto
{
    using System.ComponentModel.DataAnnotations;
    using VaporStore.DataProcessor.Dto.Import;

    public class ImportGameDto
    {
        [Required]
        public string Name { get; set; }

        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }

        [Required]
        public string ReleaseDate { get; set; }

        [Required]
        public string Developer { get; set; }

        [Required]
        public string Genre { get; set; }
        
        
        public ImportGameTagDto[] Tags { get; set; }
    }
}
