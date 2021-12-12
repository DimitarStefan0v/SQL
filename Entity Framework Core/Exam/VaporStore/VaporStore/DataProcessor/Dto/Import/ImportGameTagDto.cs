using System.ComponentModel.DataAnnotations;

namespace VaporStore.DataProcessor.Dto.Import
{
    public class ImportGameTagDto
    {
        [Required]
        public string Name { get; set; }
    }
}
