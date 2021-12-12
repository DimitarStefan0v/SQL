using Microsoft.EntityFrameworkCore;
using P03_FootballBetting.Data.Models;

namespace P03_FootballBetting.Data
{
    public class FootballBettingContext : DbContext
    {
        public FootballBettingContext()
        {

        }

        public FootballBettingContext(DbContextOptions options)
            : base(options)
        {

        }

        public DbSet<Team> Teams { get; set; }

        public DbSet<Color> Colors { get; set; }

        public DbSet<Town> Towns { get; set; }

        public DbSet<Country> Countries { get; set; }

        public DbSet<Player> Players { get; set; }

        public DbSet<Position> Positions { get; set; }

        public DbSet<PlayerStatistic> PlayerStatistics { get; set; }

        public DbSet<Game> Games { get; set; }

        public DbSet<Bet> Bets { get; set; }

        public DbSet<User> Users { get; set; }


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder
                    .UseSqlServer(Configuration.ConnectionString);
            }

            base.OnConfiguring(optionsBuilder);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Team>(entity =>
            {
                entity
                    .HasKey(t => t.TeamId);

                entity
                    .Property(t => t.Name)
                    .IsRequired()
                    .IsUnicode()
                    .HasMaxLength(50);

                entity
                    .Property(t => t.LogoUrl)
                    .IsRequired()
                    .IsUnicode(false);

                entity
                    .Property(t => t.Initials)
                    .IsRequired()
                    .IsUnicode()
                    .HasMaxLength(3);

                entity
                    .HasOne(t => t.PrimaryKitColor)
                    .WithMany(c => c.PrimaryKitTeams)
                    .HasForeignKey(x => x.PrimaryKitColorId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity
                    .HasOne(t => t.SecondaryKitColor)
                    .WithMany(c => c.SecondaryKitTeams)
                    .HasForeignKey(x => x.SecondaryKitColorId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity
                    .HasOne(t => t.Town)
                    .WithMany(c => c.Teams)
                    .HasForeignKey(x => x.TownId);
            });

            modelBuilder.Entity<Color>(entity =>
            {
                entity
                    .HasKey(x => x.ColorId);

                entity
                    .Property(n => n.Name)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(30);
            });

            modelBuilder.Entity<Town>(entity =>
            {
                entity
                    .HasKey(x => x.TownId);

                entity
                    .Property(x => x.Name)
                    .IsRequired()
                    .IsUnicode()
                    .HasMaxLength(50);

                entity
                    .HasOne(x => x.Country)
                    .WithMany(t => t.Towns)
                    .HasForeignKey(x => x.CountryId);
            });

            modelBuilder.Entity<Country>(entity =>
            {
                entity
                    .HasKey(x => x.CountryId);

                entity
                    .Property(x => x.Name)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(50);

            });

            modelBuilder.Entity<Player>(entity =>
            {
                entity
                    .HasKey(x => x.PlayerId);

                entity
                    .Property(x => x.Name)
                    .IsRequired()
                    .IsUnicode()
                    .HasMaxLength(80);

                entity
                    .HasOne(x => x.Team)
                    .WithMany(p => p.Players)
                    .HasForeignKey(x => x.TeamId);

                entity
                    .HasOne(p => p.Position)
                    .WithMany(p => p.Players)
                    .HasForeignKey(p => p.PositionId);
                    
            });

            modelBuilder.Entity<Position>(entity =>
            {
                entity
                    .HasKey(p => p.PositionId);

                entity
                    .Property(n => n.Name)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<PlayerStatistic>(entity =>
            {
                entity
                    .HasKey(pk => new { pk.PlayerId, pk.GameId });

                entity
                    .HasOne(p => p.Player)
                    .WithMany(ps => ps.PlayerStatistics)
                    .HasForeignKey(p => p.PlayerId);

                entity
                    .HasOne(g => g.Game)
                    .WithMany(ps => ps.PlayerStatistics)
                    .HasForeignKey(g => g.GameId);
            });

            modelBuilder.Entity<Game>(entity =>
            {
                entity
                    .HasKey(p => p.GameId);

                entity
                    .Property(r => r.Result)
                    .IsRequired(false)
                    .IsUnicode(false)
                    .HasMaxLength(7);

                entity
                    .HasOne(g => g.HomeTeam)
                    .WithMany(a => a.HomeGames)
                    .HasForeignKey(g => g.HomeTeamId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity
                    .HasOne(g => g.AwayTeam)
                    .WithMany(a => a.AwayGames)
                    .HasForeignKey(g => g.AwayTeamId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Bet>(entity =>
            {
                entity
                    .HasKey(e => e.BetId);

                entity
                    .HasOne(b => b.User)
                    .WithMany(u => u.Bets)
                    .HasForeignKey(b => b.UserId);

                entity
                    .HasOne(b => b.Game)
                    .WithMany(g => g.Bets)
                    .HasForeignKey(b => b.GameId);
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity
                    .HasKey(e => e.UserId);

                entity
                    .Property(e => e.Username)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(50);

                entity
                    .Property(e => e.Password)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(256);

                entity
                    .Property(e => e.Email)
                    .IsRequired()
                    .IsUnicode(false)
                    .HasMaxLength(50);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .IsUnicode()
                    .HasMaxLength(50);
            });
        }
    }
}
